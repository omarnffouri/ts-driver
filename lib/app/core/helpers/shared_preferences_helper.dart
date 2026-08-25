// ignore_for_file: constant_identifier_names

import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/values/constants.dart';

import '../../modules/auth/domain/entities/user_entity.dart';

/// if you update any thing in this file this may cause a issue in native codes and logics
class SharedPrefrencesHelper {
  /// please dont change these values this may ccause native values issues
  /// pref name = ''

  static const Token = "token";
  static const FirstName = "firstName";
  static const LastName = "lastName";
  static const UserId = "userId";
  static const ApplicantId = "applicantId";
  static const ModelType = "modelType";
  static const Image = "image";
  static const ServerUrl = "serverUrl";
  static const IsStagingServer = "isStagingServer";

  // realtime (Pusher/Reverb) config — mirrored from the server's
  // realtime-configuration so native call-event code uses the same source of
  // truth as Dart instead of hardcoded keys/hosts.
  static const RealtimeKey = "realtimeKey";
  static const RealtimeHost = "realtimeHost";
  static const RealtimePort = "realtimePort";
  static const RealtimeAuthUrl = "realtimeAuthUrl";
  static const RealtimeAgoraAppId = "realtimeAgoraAppId";
  static const RealtimeConfigVersion = "realtimeConfigVersion";

  // clock in/out perf names
  static const SessionId = "sessionId";
  static const SessionStartedAt = "sessionStartedAt";

  // call perf names
  static const ChannelName = "channelName";
  static const ConversationId = "conversationId";
  static const CallType = "callType";
  static const ConversationType = "conversationType";
  static const CallerId = "callerId";
  static const CallerModelType = "callerModelType";
  static const CallerName = "callerName";
  static const CallerImage = "callerImage";

  //
  static Future<void> storeMyDetails(UserEntity user, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Token, token);
    await prefs.setString(FirstName, user.personalDetails?.firstName ?? "");
    await prefs.setString(LastName, user.personalDetails?.lastName ?? "");
    await prefs.setInt(UserId, user.personalDetails?.userId ?? 0);
    await prefs.setInt(ApplicantId, user.personalDetails?.applicantId ?? 0);
    await prefs.setString(ModelType, "applicants");
    await prefs.setString(Image, user.profile ?? "");
    await prefs.setString(ServerUrl, ApiConstants.kServerURL);
    await prefs.setBool(IsStagingServer, !ApiConstants.isProduction);
  }

  /// Mirror the server-fetched realtime config into SharedPreferences so the
  /// native call-event Pusher reads host/key/port/auth-url from the API
  /// instead of hardcoded values (the keys can rotate at any time).
  static Future<void> storeRealtimeConfig({
    String? key,
    String? host,
    int? port,
    String? authUrl,
    String? agoraAppId,
    String? configVersion,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.wait([
      if (key != null && key.isNotEmpty) prefs.setString(RealtimeKey, key),
      if (host != null && host.isNotEmpty) prefs.setString(RealtimeHost, host),
      if (port != null && port > 0) prefs.setInt(RealtimePort, port),
      if (authUrl != null && authUrl.isNotEmpty)
        prefs.setString(RealtimeAuthUrl, authUrl),
      if (agoraAppId != null && agoraAppId.isNotEmpty)
        prefs.setString(RealtimeAgoraAppId, agoraAppId),
      if (configVersion != null && configVersion.isNotEmpty)
        prefs.setString(RealtimeConfigVersion, configVersion),
    ]);
  }

  //
  static Future<void> clearMyDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Token);
    await prefs.remove(FirstName);
    await prefs.remove(LastName);
    await prefs.remove(UserId);
    await prefs.remove(ApplicantId);
    await prefs.remove(ModelType);
    await prefs.remove(Image);
    await prefs.remove(ServerUrl);
    await prefs.remove(IsStagingServer);
    await prefs.remove(RealtimeKey);
    await prefs.remove(RealtimeHost);
    await prefs.remove(RealtimePort);
    await prefs.remove(RealtimeAuthUrl);
    await prefs.remove(RealtimeAgoraAppId);
    await prefs.remove(RealtimeConfigVersion);
    // Biometric enrollment (creds + enabled flag) intentionally SURVIVES logout
    // so the user can biometric-login next time. It's controlled only by the
    // Settings toggle / the enable sheet — not by logout.
    // We only reset the one-time suggestion so a user who *skipped* it gets
    // offered again after a fresh password login (an enrolled user is skipped
    // by the alreadyEnabled guard anyway).
    await GetStorage().remove(AuthenticationPrefKeys.biometricPromptSeen);
  }

  static Future<void> storeClockInOutSessionId(
      String sessionId, bool writeIfNull) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (writeIfNull) {
        final id = prefs.getString(SessionId);
        if (id == null) {
          await prefs.setString(SessionId, sessionId);
        }
      } else {
        await prefs.setString(SessionId, sessionId);
      }
      await prefs.setBool(IsStagingServer, !ApiConstants.isProduction);
      await prefs.setInt(
          SessionStartedAt, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  static Future<void> clearClockInOutSessionId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(SessionId);
    await prefs.remove(SessionStartedAt);
  }
}
