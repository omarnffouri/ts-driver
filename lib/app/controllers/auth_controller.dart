import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/access_level.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/helpers/shared_preferences_helper.dart';
import 'package:ts_driver/app/modules/chat_detail/data/repositories/messages_db_manager.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/pusher_manager.dart';
import 'package:ts_driver/app/modules/chat/data/repositories/conversations_db_manager.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../core/data/connection/api_constants.dart';
import '../core/values/constants.dart';
import '../modules/auth/data/models/realtime_configuration_model.dart';
import '../modules/auth/domain/entities/realtime_configuration_entity.dart';
import '../modules/auth/domain/entities/user_entity.dart';
import '../modules/auth/domain/usecases/get_realtime_configuration_usecase.dart';
import '../modules/auth/domain/usecases/logout_usecase.dart';
import '../modules/auth/domain/usecases/update_fcm_token_usecase.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  // usecases
  final logoutUseCase = sl.get<LogoutUseCase>();
  final getRealtimeConfigurationUseCase =
      sl.get<GetRealtimeConfigurationUseCase>();

  // variables
  final RxBool _isAuthenticated = false.obs;
  bool get isAuthenticated => _isAuthenticated.value;
  set isAuthenticated(bool value) => _isAuthenticated.value = value;

  // final profileUseCase = sl<GetProfileUseCase>();
  final updateFcmTokenUseCase = sl<UpdateFcmTokenUseCase>();

  Rx<UserEntity> user = const UserEntity().obs;

  Rxn<AccessLevel> accessLevel = Rxn<AccessLevel>();

  final _remoteConfig = FirebaseRemoteConfig.instance;
  final RxBool isOtpEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.instance.onTokenRefresh.listen((fcm) async {
      debugPrint('A new onTokenRefresh event was published! $fcm');
      final String? id = CommonVariables.settings.read(APPLICANT_ID);
      if (id != null) {
        try {
          sendTokenToFirebase(id, fcm);
          sendTokentoBackend(fcm);
        } catch (_) {
          debugPrint('Failed to send token to Firebase $_');
        }
      }
    });

    fetchRemoteConfig();

    //
    // auth state listener
    _isAuthenticated.listen((auth) async {
      if (!auth) {
        await clearUserData();
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  Future<void> logout({bool isServerException = false}) async {
    /// in case of [Autherization] exception we don't need to call logout usecase
    /// because we dont have the user token to call the logout api
    if (isServerException == false) {
      await attemptLogoutUsecase();
    }

    if (user.value.token == null || _isAuthenticated.value == false) {
      return;
    }
    _isAuthenticated.value = false;
  }

  Future<bool> fetchRemoteConfig() async {
    debugPrint('Initial isOtpEnabled: ${isOtpEnabled.value}');
    try {
      // Fetch and activate remote config values
      bool updated = await _remoteConfig.fetchAndActivate();

      if (updated) {
        debugPrint('Remote Config values were updated.');
      } else {
        debugPrint('Remote Config values are already up-to-date.');
      }

      // Update isOtpEnabled with the fetched value
      isOtpEnabled.value = _remoteConfig.getBool('is_otp_enabled');
    } catch (e) {
      debugPrint('Failed to fetch remote config: $e');
    }

    debugPrint('Final isOtpEnabled: ${isOtpEnabled.value}');
    return isOtpEnabled.value;
  }

  Future<void> saveUser(UserEntity user) async {
    this.user.value = user;
    isAuthenticated = true;
    accessLevel.value = AccessLvlExt.getAccessLevel(user);

    await CommonVariables.settings.write(TOKEN, user.token);
    await CommonVariables.userData.write(IS_AUTHENTICATED, true);
    await CommonVariables.userData.write(USER_DATA, user.toJson());
    await CommonVariables.settings.write(
        APPLICANT_ID, user.personalDetails?.applicantId.toString() ?? "");
    await CommonVariables.settings
        .write(USER_ID, user.personalDetails?.userId.toString() ?? "");

    await SharedPrefrencesHelper.storeMyDetails(
      user,
      user.token!,
    );
  }

  Future<void>? _realtimeSetup;
  bool _realtimeRunning = false;

  /// Completes once post-login realtime (config fetch + Pusher connect) is
  /// ready — chat subscriptions await this so navigation isn't blocked on it.
  Future<void> get realtimeReady => _realtimeSetup ?? Future<void>.value();

  /// Idempotent: re-entrant calls (e.g. rapid resume events from opening the
  /// camera) return the in-flight future instead of racing a second
  /// fetch+connect cycle against the first.
  Future<void> setupRealtimeServices() {
    if (_realtimeRunning) return _realtimeSetup ?? Future<void>.value();
    _realtimeRunning = true;
    return _realtimeSetup =
        _runRealtimeSetup().whenComplete(() => _realtimeRunning = false);
  }

  Future<void> _runRealtimeSetup() async {
    final level = accessLevel.value;
    if (level != AccessLevel.both && level != AccessLevel.driverOnly) {
      return;
    }
    try {
      final pusher = sl<PusherManager>();
      // Let the manager self-heal a backend config rotation without a circular
      // dependency back onto this controller.
      pusher.onConfigRefreshNeeded = cacheRealtimeConfiguration;
      await cacheRealtimeConfiguration();
      await pusher.start();
    } catch (e) {
      debugPrint('[Realtime] setup failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isAuthenticated) return;
    if (state != AppLifecycleState.resumed &&
        state != AppLifecycleState.paused) {
      return;
    }
    final resumed = state == AppLifecycleState.resumed;
    // Background: suppress the reconnect loop (it can't resolve DNS while
    // backgrounded and floods logs). Incoming calls use native push.
    if (sl.isRegistered<PusherManager>()) {
      sl<PusherManager>().setForeground(resumed);
    }
    if (resumed) setupRealtimeServices();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  static const _configFetchMaxAttempts = 2;
  static const _configFetchRetryDelay = Duration(seconds: 2);

  Future<void> cacheRealtimeConfiguration() async {
    for (int attempt = 1; attempt <= _configFetchMaxAttempts; attempt++) {
      try {
        final result = await getRealtimeConfigurationUseCase(const NoParams());
        final RealtimeConfiguration? config =
            result.fold<RealtimeConfiguration?>(
          (cfg) => cfg,
          (failure) {
            debugPrint(
                'Failed to fetch realtime configuration (attempt $attempt/$_configFetchMaxAttempts): ${failure.message}');
            return null;
          },
        );

        if (config != null) {
          await CommonVariables.settings.write(
            ApiConstants.realtimeConfigKey,
            RealtimeConfigurationModel.fromEntity(config).toJson(),
          );
          // Mirror to SharedPreferences so the native call-event Pusher uses
          // the same server-driven config (keys can rotate at any time).
          await SharedPrefrencesHelper.storeRealtimeConfig(
            key: config.websocket?.key,
            host: config.websocket?.host,
            port: config.websocket?.port,
            authUrl: config.websocket?.authEndpoint,
            agoraAppId: config.agora?.appId,
            configVersion: config.configVersion,
          );
          debugPrint(
              '[Realtime] config cached under ${ApiConstants.realtimeConfigKey} '
              '→ host=${config.websocket?.host}, port=${config.websocket?.port}, version=${config.configVersion}');
          return;
        }
      } catch (e) {
        debugPrint(
            'Failed to cache realtime configuration (attempt $attempt/$_configFetchMaxAttempts): $e');
      }

      if (attempt < _configFetchMaxAttempts) {
        await Future.delayed(_configFetchRetryDelay);
      }
    }
  }

  Future<int?> getTokenInfo(String applicantId) async {
    final firestore = FirebaseDatabase.instance.ref();
    final rootCollection =
        ApiConstants.isProduction ? "FCM_tokens" : "FCM_tokens_staging";
    final tokenRef = firestore.child(rootCollection).child(applicantId);

    try {
      // Get the data once
      DataSnapshot snapshot = await tokenRef.get();
      List<int> timestamps = [];

      // Check if data exists
      if (snapshot.exists) {
        Map<dynamic, dynamic> items = snapshot.value as Map<dynamic, dynamic>;
        items.forEach((key, value) {
          if (value["timestamp"] != null) {
            timestamps.add(int.parse(value["timestamp"].toString()));
          }
        });
        // Return the latest timestamp
        return timestamps.reduce((curr, next) => curr > next ? curr : next);
      } else {
        debugPrint("No data available for ID: $applicantId");
        return null;
      }
    } catch (error) {
      debugPrint("Error fetching token info: $error");
      return null;
    }
  }

  Future<void> sendTokenToFirebase(String id, String token) async {
    final firestore = FirebaseDatabase.instance.ref();
    final rootCollection =
        ApiConstants.isProduction ? "FCM_tokens" : "FCM_tokens_staging";
    final logsRef = firestore.child(rootCollection).child(id.toString());
    try {
      await logsRef.push().set(
        {
          "id": id,
          "token": token,
          "is_refreshed": true,
          "timestamp": {".sv": "timestamp"},
        },
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> sendTokentoBackend(String fcm) async {
    if (fcm.isEmpty) {
      return;
    }
    final body = {"fcm": fcm};
    final r = await updateFcmTokenUseCase(body);

    r.fold(
      (l) => debugPrint("fcm token updated successfully"),
      (r) => debugPrint(r.toString()),
    );
  }

  Future<void> clearUserData() async {
    // Sign out from Firebase Auth
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Firebase Auth signOut failed: $e');
    }

    await CommonVariables.userData.remove(USER_DATA);
    await CommonVariables.userData.remove(IS_AUTHENTICATED);
    await CommonVariables.settings.remove(TOKEN);
    await CommonVariables.settings.remove(ApiConstants.realtimeConfigKey);
    await CommonVariables.settings
        .remove(REALTIME_CONFIGURATION); // legacy unscoped key
    await CommonVariables.settings.remove(APPLICANT_ID);
    await CommonVariables.settings.remove(USER_ID);

    await SharedPrefrencesHelper.clearMyDetails();
    await SharedPrefrencesHelper.clearClockInOutSessionId();
    //
    // disposing pusher of chat
    if (sl.isRegistered<PusherManager>()) {
      sl<PusherManager>().dispose();
    }

    //
    // deleting all group and oto converstions
    try {
      final converstionsDatabase = ConversationsDatabase();
      await converstionsDatabase.deleteAllConversation();
      await converstionsDatabase.deleteAllGroupConversation();
    } catch (_) {}

    //
    // delete all converstions messages
    try {
      MessagesDatabase().deleteAllMessages();
    } catch (_) {}
  }

  Future<void> attemptLogoutUsecase() async {
    try {
      await logoutUseCase.call(const NoParams());
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }
}
