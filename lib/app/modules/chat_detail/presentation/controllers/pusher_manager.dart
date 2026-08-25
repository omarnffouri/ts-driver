// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/auth/data/models/realtime_configuration_model.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/realtime_configuration_entity.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/websocket_configuration_entity.dart';

class PusherManager {
  String get bearerToken =>
      CommonVariables.settings.read(TOKEN)?.toString() ?? '';

  String get userId =>
      CommonVariables.settings.read(APPLICANT_ID)?.toString() ?? '';

  RealtimeConfiguration _config = const RealtimeConfiguration();

  WebsocketConfiguration? get _ws => _config.websocket;

  String get _pusherKey => _ws?.key ?? '';

  String get _pusherHost {
    final host = _ws?.host ?? '';
    return host.replaceFirst(RegExp(r'^https?://'), '').split('/').first;
  }

  int get _pusherPort => _ws?.port ?? 0;

  String get _pusherPath {
    final path = _ws?.path;
    if (path == null || path.isEmpty) {
      return '';
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  String get _webSocketScheme {
    final scheme = _ws?.scheme?.toLowerCase();
    if (scheme == 'ws' || scheme == 'http') return 'ws';
    if (scheme == 'wss' || scheme == 'https') return 'wss';
    return _ws?.forceTls == false ? 'ws' : 'wss';
  }

  String get _authUrl => _ws?.authEndpoint ?? '';

  PusherChannelsClient? client;
  PublicChannel? _activeCountChannel;
  PresenceChannel? _onlineChannel;
  PrivateChannel? _messageNotificationChannel;
  PrivateChannel? _messageDataChannel;
  PrivateChannel? _callEventChannel;
  PusherChannelsClientLifeCycleState? connectionState;
  String? _appliedConfigVersion;

  /// Whether the app is foregrounded. While backgrounded we suppress the
  /// websocket reconnect loop (a backgrounded app can't resolve DNS, which
  /// otherwise floods logs with `Unable to resolve host`). Incoming calls are
  /// delivered via native push, not this socket, so backgrounding it is safe.
  bool _foreground = true;
  bool _restarting = false;
  int _consecutiveFailures = 0;

  /// After this many consecutive foreground failures, re-fetch the realtime
  /// config and rebuild the client — self-heals a backend config rotation
  /// (host/key/port change) without waiting for an app resume.
  static const int _refetchAfterFailures = 5;

  /// Set by [AuthController] to its `cacheRealtimeConfiguration`; lets the
  /// manager pull a fresh config on rotation without a circular dependency.
  Future<void> Function()? onConfigRefreshNeeded;

  void _log(String message) {
    if (kDebugMode) debugPrint('[Pusher] $message');
  }

  void setForeground(bool value) {
    if (_foreground == value) return;
    _foreground = value;
    if (value) _consecutiveFailures = 0;
    // Background: stay subscribed but suppress the reconnect loop (gated in
    // connectionErrorHandler); if the socket dies it's reconnected on resume.
    _log('setForeground($value)');
  }

  /// (Re)connect using the cached realtime config; no-op if already on it.
  Future<void> start() async {
    final stored =
        CommonVariables.settings.read(ApiConstants.realtimeConfigKey);
    final version = stored is Map ? stored['config_version']?.toString() : null;
    final isConnected = connectionState ==
        PusherChannelsClientLifeCycleState.establishedConnection;
    if (client != null && version == _appliedConfigVersion) {
      if (isConnected) return;
      // Same config, socket is down (e.g. returned from background). Reconnect
      // the EXISTING client so its channels + bound listeners survive — a full
      // rebuild would null them and the user would drop off the online channel.
      _log('start: socket down — reconnecting existing client');
      await _reconnect();
      return;
    }

    _log('start: (re)building client (version=$version)');
    await dispose();
    await initializePusher();
    _appliedConfigVersion = version;
  }

  /// Reconnect the existing client and re-subscribe its active channels, so
  /// presence/notification subscriptions (and their bound listeners) are
  /// preserved across a background→foreground cycle instead of being lost.
  Future<void> _reconnect() async {
    try {
      await client!.connect();
      _resubscribeActiveChannels();
    } catch (e) {
      _log('reconnect failed: $e');
    }
  }

  /// Single source of truth for which channels are re-subscribed after a
  /// (re)connect. Shared by [_reconnect] and [_ensureConnection] so the active
  /// channel set lives in one place.
  void _resubscribeActiveChannels() {
    _activeCountChannel?.subscribe();
    _onlineChannel?.subscribe();
    _messageNotificationChannel?.subscribe();
    _messageDataChannel?.subscribe();
    _callEventChannel?.subscribe();
  }

  Future<void> initializePusher() async {
    final stored =
        CommonVariables.settings.read(ApiConstants.realtimeConfigKey);
    try {
      _config = stored is Map
          ? RealtimeConfigurationModel.fromJson(
              Map<String, dynamic>.from(stored))
          : const RealtimeConfiguration();
    } catch (e) {
      _log('failed to parse realtime configuration: $e');
      _config = const RealtimeConfiguration();
    }

    if (!_config.isValid) {
      _log('config incomplete; skipping connection '
          '(key=${_ws?.key}, host=${_ws?.host}, port=${_ws?.port})');
      return;
    }

    final wsUri = Uri.parse(
      '$_webSocketScheme://$_pusherHost:$_pusherPort$_pusherPath/$_pusherKey',
    );
    final clusterOptions = PusherChannelsOptions.custom(
      uriResolver: (_) => wsUri,
    );

    _log('connecting to $wsUri');

    // creating client
    client = PusherChannelsClient.websocket(
      options: clusterOptions,
      connectionErrorHandler: (exception, trace, refresh) {
        // Don't retry while backgrounded — DNS lookups fail and spam logs.
        if (!_foreground) return;
        _consecutiveFailures++;
        _log('connectionError ($_consecutiveFailures): $exception');
        if (_consecutiveFailures % _refetchAfterFailures == 0) {
          // Likely a rotated/stale config; pull a fresh one and rebuild.
          _resyncConfigAndRestart();
          return;
        }
        refresh();
      },
      minimumReconnectDelayDuration: const Duration(seconds: 1),
      defaultActivityDuration: const Duration(seconds: 5),
      activityDurationOverride: const Duration(seconds: 5),
      waitForPongDuration: const Duration(seconds: 10),
    );

    client!.onConnectionEstablished.listen((_) {
      _consecutiveFailures = 0;
      _log('connection established');
    });

    client!.lifecycleStream.listen((state) {
      connectionState = state;
    });

    await client!.connect();
  }

  _ensureConnection() async {
    if (connectionState !=
        PusherChannelsClientLifeCycleState.establishedConnection) {
      await client!.disconnect();
      await client!.connect();
      _resubscribeActiveChannels();
    }
  }

  Future<PrivateChannel> subscribeToMessageNotificationChannel() async {
    try {
      await _ensureConnection();
      _messageNotificationChannel =
          _createMessageNotificationChannel(bearerToken, userId);
      _messageNotificationChannel!.subscribe();
      notifyPrivateEventStatus(_messageNotificationChannel!);
    } catch (_) {}
    return _messageNotificationChannel!;
  }

  Future<PrivateChannel> subscribeToMessageDataChannel(
      String conversationId) async {
    await _ensureConnection();
    _messageDataChannel =
        _createMessageDataChannel(bearerToken, conversationId);
    _messageDataChannel!.subscribe();
    notifyPrivateEventStatus(_messageDataChannel!);
    return _messageDataChannel!;
  }

  Future<PublicChannel> subscribeToActiveCountChannel() async {
    await _ensureConnection();
    _activeCountChannel ??= _createActiveCountChannel();
    _activeCountChannel!.subscribe();
    notifyPublicEventStatus(_activeCountChannel!);
    return _activeCountChannel!;
  }

  Future<PresenceChannel> subscribeToOnlineChannel() async {
    await _ensureConnection();
    _onlineChannel = _createOnlineChannel(bearerToken, userId);
    _onlineChannel!.subscribe();
    notifyPersenceEventStatus(_onlineChannel!);
    return _onlineChannel!;
  }

  Future<PrivateChannel> subscribeToCallEventChannel() async {
    await _ensureConnection();
    if (_callEventChannel != null) {
      _callEventChannel!.subscribeIfNotUnsubscribed();
      return _callEventChannel!;
    }
    _callEventChannel = _createCallEventChannel(bearerToken);
    _callEventChannel!.subscribe();
    notifyPrivateEventStatus(_callEventChannel!);
    return _callEventChannel!;
  }

  /////////////////// Unsubscribers
  void unsubscribeMessageNotificationChannel() {
    try {
      if (_messageNotificationChannel != null) {
        _messageNotificationChannel?.unsubscribe();
      }
      _messageNotificationChannel = null;
    } catch (_) {}
  }

  void unsubscribeMessageDataChannel() {
    try {
      if (_messageDataChannel != null) {
        _messageDataChannel?.unsubscribe();
      }
      _messageDataChannel = null;
    } catch (_) {}
  }

  void unsubscribeActiveCountChannel() {
    try {
      if (_activeCountChannel != null) {
        _activeCountChannel?.unsubscribe();
      }
      _activeCountChannel = null;
    } catch (_) {}
  }

  void unsubscribeOnlineChannel() {
    try {
      if (_onlineChannel != null) {
        _onlineChannel?.unsubscribe();
      }
      _onlineChannel = null;
    } catch (_) {}
  }

  /////////////////// private source creation functions

  PrivateChannel _createMessageNotificationChannel(
      String token, String userId) {
    return client!.privateChannel(
      'private-conversation-receiver-applicants-$userId',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  PrivateChannel _createMessageDataChannel(
      String token, String conversationId) {
    return client!.privateChannel(
      'private-conversation-$conversationId',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  PublicChannel _createActiveCountChannel() {
    return client!.publicChannel("active-count");
  }

  PresenceChannel _createOnlineChannel(String token, String userId) {
    return client!.presenceChannel(
      "presence-online-channel",
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPresenceChannel(
        // authorizationEndpoint: Uri.parse(AUTH_URL_STAGING),
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  PrivateChannel _createCallEventChannel(String token) {
    return client!.privateChannel(
      'private-call-receiver-applicants-$userId',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  //////////////////// public and private event status notifier functions

  void notifyPublicEventStatus(PublicChannel publicChannel) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint(
          '${publicChannel.name} channel subscription status ===> ${publicChannel.state?.status.name}');
      if (publicChannel.state?.status.name == "subscribed" || timer.tick == 5) {
        timer.cancel();
      }
    });
  }

  void notifyPersenceEventStatus(PresenceChannel presenceChannel) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint(
          '${presenceChannel.name} channel subscription status ===> ${presenceChannel.state?.status.name}');
      if (presenceChannel.state?.status.name == "subscribed" ||
          timer.tick == 5) {
        timer.cancel();
      }
    });
  }

  void notifyPrivateEventStatus(PrivateChannel privateChannel) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final status = privateChannel.state?.status.name;

      debugPrint(
          '${privateChannel.name} channel subscription status ===> $status');

      debugPrint(
          '${privateChannel.name} channel subscription status ===> ${privateChannel.state?.status.name}');
      if (privateChannel.state?.status.name == "subscribed" ||
          timer.tick == 5) {
        timer.cancel();
      }
    });
  }

  //////////////////// Event emitters
  void emitTypingEvent(Map<String, dynamic> eventData) {
    if (_messageDataChannel != null) {
      _messageDataChannel?.trigger(eventName: "client-typing", data: eventData);
    }
  }

  /// Re-fetch the realtime config and rebuild the client. Used to self-heal a
  /// backend config rotation during a long foreground session. Guarded against
  /// re-entrancy and backed off so it can't storm.
  Future<void> _resyncConfigAndRestart() async {
    if (_restarting) return;
    _restarting = true;
    _log('resync: re-fetching config + rebuilding (backoff 2s)…');
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!_foreground) return;
      await onConfigRefreshNeeded?.call();
      _appliedConfigVersion = null; // force rebuild with the latest settings
      await start();
    } catch (e) {
      _log('resync failed: $e');
    } finally {
      _restarting = false;
      _consecutiveFailures = 0;
    }
  }

  dispose() async {
    await client?.disconnect();
    client?.dispose();
    client = null;
    _appliedConfigVersion = null;
    _activeCountChannel = null;
    _onlineChannel = null;
    _messageNotificationChannel = null;
    _messageDataChannel = null;
    _callEventChannel = null;
  }
}
