import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:upgrader/upgrader.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/helpers/biometric_helper.dart';
import 'package:ts_driver/app/modules/auth/domain/usecases/login_usecase.dart';
import 'package:ts_driver/app/modules/auth/domain/usecases/firebase/sign_in_to_firebase_usecase.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/views/bottom_sheets/biometric_suggestion_bs.dart';
import '../../../../../controllers/auth_controller.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../../../core/data/error/failures.dart';
import '../../../../../core/values/constants.dart';
import '../../../../../core/transitions/circular_reveal_transition.dart';
import '../../../../../routes/app_pages.dart';
import '../../../domain/entities/user_entity.dart';

class LoginController extends GetxController {
  final authController = Get.put(AuthController(), permanent: true);

  // usecases
  final loginUseCase = sl<LoginUseCase>();
  final signInToFirebaseUseCase = sl<SignInToFirebaseUseCase>();

  // storage
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final GetStorage storage = GetStorage();

  // controllers
  TextEditingController socialSecurityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // variables
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  RxBool rememberMe = false.obs;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  // biometric state
  RxBool isBiometricAvaibale = false.obs;

  //
  final pageController = PageController().obs;
  final currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      Upgrader.clearSavedSettings();
    }
    // Load saved login data from storage (if any)
    initStorage();
    initDeviceInfo();
  }

  @override
  void onClose() {
    socialSecurityController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> initDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
      debugPrint(_deviceData.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> initStorage() async {
    // Read all secure-storage keys in parallel (each hits the platform
    // keystore/keychain, so serial reads add up on screen load).
    final values = await Future.wait([
      secureStorage.read(key: SSN),
      secureStorage.read(key: MOBILE),
    ]);
    final savedSSN = values[0];
    final savedPhoneNumber = values[1];

    final savedRememberMe = CommonVariables.userData.read(REMEMBERME);
    if (savedSSN != null &&
        savedPhoneNumber != null &&
        savedRememberMe != null) {
      socialSecurityController.text = savedSSN;
      phoneController.text = savedPhoneNumber;
      rememberMe.value = savedRememberMe;
    }

    // The enabled flag and stored credentials always move together, so the
    // flag alone tells us whether to offer the biometric button.
    isBiometricAvaibale(BiometricHelper.isEnabled);
  }

  Future<void> login({
    String ssn = "",
    String mobile = "",
    bool isBiometricLogin = false,
  }) async {
    // Drop repeat taps while a login is in flight.
    if (_isLoading.value) return;

    // Dismiss the keyboard — a button tap wins the gesture arena, so the
    // app-wide tap-to-dismiss handler never fires for it.
    FocusManager.instance.primaryFocus?.unfocus();

    final actualSsn = isBiometricLogin ? ssn : socialSecurityController.text;
    final actualMobile = isBiometricLogin ? mobile : phoneController.text;

    if (actualMobile.isEmpty) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: 'Phone Number'.tr + 'required'.tr,
      );
      return;
    }
    if (actualSsn.isEmpty) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: 'Social Security Number'.tr + 'required'.tr,
      );
      return;
    }

    _isLoading(true); // before the first await, so the guard trips on re-taps
    try {
      final String? token = await getFCMToken();
      debugPrint("FCM token: $token");

      final body = <String, dynamic>{
        "ss_no": actualSsn.trim(),
        "mobile_number": actualMobile.trim(),
        "fcm": token,
        "platform": Platform.isAndroid ? 'Android' : 'iOS',
        "device_id": _deviceData['id'] ?? "",
        "device_name": _deviceData['name'] ?? "",
      };

      final Either<UserEntity, Failure> result = await loginUseCase.call(body);

      // Awaited so loading holds through the async success path, not just the API.
      await result.fold((UserEntity userEntity) async {
        // Fire-and-forget Firebase sign-in (enables secure database rules)
        unawaited(signInToFirebaseUseCase.fireAndForget(userEntity));

        // save token to firebase
        if (token != null) {
          await sendTokenToServer(
            userEntity.personalDetails?.applicantId ?? 0,
            token,
          );
        }

        saveCredintials();

        if (!isBiometricLogin) {
          await _showBiometricSuggestion();
        }

        //save user data
        await authController.saveUser(userEntity);
        // Background — chat subscriptions await authController.realtimeReady,
        // so navigation isn't blocked on the websocket handshake.
        unawaited(authController.setupRealtimeServices());

        // Remove the login sheet instantly (no dismiss animation) so the reveal
        // blooms over the clean login screen, not the sheet's scrim.
        final sheetRoute = Get.rawRoute;
        final navigator = sheetRoute?.navigator;
        if (navigator != null && navigator.canPop()) {
          navigator.removeRoute(sheetRoute!);
        }

        Get.offAllNamed(
          Routes.MAIN_SCREEN,
          arguments: const {
            CircularRevealTransition.argKey: MainEntrance.reveal,
          },
        );
      }, (Failure e) async {
        final isValidation = e.code == 302;
        if (isValidation) {
          // account is not verified, go to otp screen
          Get.toNamed(Routes.OTP, arguments: body);
        }
        debugPrint(e.toString());
        String t = e.title ?? "";
        if (t.contains("hold")) {
          CommonWidgets.buildHoldRejectDialog(
              "ON HOLD", 'Please contact the HR for further assistance.');
        } else if (t.contains("rejected")) {
          CommonWidgets.buildHoldRejectDialog(
              "REJECTED", 'Please contact the HR for further assistance.');
        } else if (t.contains("terminated")) {
          CommonWidgets.buildHoldRejectDialog("TERMINATED", '');
        } else {
          CommonWidgets.showSnackBar(
            title: isValidation ? "Validation" : 'Error'.tr,
            message: e.message,
            isError: isValidation ? false : true,
          );
        }
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
    } finally {
      _isLoading(false);
    }
  }

  Future<void> saveCredintials() async {
    if (rememberMe.value) {
      await secureStorage.write(key: SSN, value: socialSecurityController.text);
      await secureStorage.write(key: MOBILE, value: phoneController.text);
      CommonVariables.userData.write(REMEMBERME, rememberMe.value);
    } else {
      // If "Remember Me" is unchecked, clear saved login data from storage.
      await secureStorage.delete(key: SSN);
      await secureStorage.delete(key: MOBILE);
      CommonVariables.userData.remove(REMEMBERME);
    }
  }

  Future<void> sendTokenToServer(int id, String token) async {
    final firestore = FirebaseDatabase.instance.ref();
    final rootCollection =
        ApiConstants.isProduction ? "FCM_tokens" : "FCM_tokens_staging";
    final logsRef = firestore.child(rootCollection).child(id.toString());

    try {
      await logsRef.push().set(
        {
          "id": id,
          "token": token,
          "is_refreshed": false,
          "timestamp": {".sv": "timestamp"},
        },
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<String?> getFCMToken() async {
    try {
      final result = await FirebaseMessaging.instance.requestPermission();

      switch (result.authorizationStatus) {
        case AuthorizationStatus.authorized:
          // Permission granted
          String? token = await FirebaseMessaging.instance.getToken();
          return token;

        case AuthorizationStatus.denied:
          // Permission denied
          debugPrint('FCM permission denied');
          // Consider UI feedback or log message
          return null;

        case AuthorizationStatus.notDetermined:
          // User hasn't determined permission yet
          // Optionally, retry permission request or guide user
          return null;

        case AuthorizationStatus.provisional:
          // Provisional permission granted
          String? token = await FirebaseMessaging.instance.getToken();
          return token;
      }
    } catch (e) {
      debugPrint('Cannot get token: $e');
      return null;
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'id': build.id,
      'name': build.brand,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'id': data.identifierForVendor,
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'utsname.sysname:': data.utsname.sysname,
    };
  }

  // ── Biometric ──────────────────────────────────────────────────────────

  _showBiometricSuggestion() async {
    try {
      if (!(await BiometricHelper.isBiometricAvailable())) {
        return;
      }
    } catch (_) {
      return;
    }

    // Suggest only once, and never if biometric is already enabled.
    final alreadyEnabled = BiometricHelper.isEnabled;
    final promptSeen =
        storage.read(AuthenticationPrefKeys.biometricPromptSeen) == true;
    if (alreadyEnabled || promptSeen) return;
    storage.write(AuthenticationPrefKeys.biometricPromptSeen, true);

    await showBiometricSuggestionSheet(Get.context!);
  }

  /// User dismissed the one-time suggestion (X / Skip). Nothing is persisted —
  /// credentials are only stored when biometric is explicitly enabled, and the
  /// one-time `biometricPromptSeen` flag was already written before showing it.
  declineBiometricSuggestion() {
    Get.back();
  }

  enableBiometric() async {
    try {
      if (await BiometricHelper.isBiometricAvailable()) {
        if (!(await BiometricHelper.authenticate())) {
          return;
        }
      } else {
        return;
      }

      await BiometricHelper.saveCredentials(
        ssn: socialSecurityController.text,
        mobile: phoneController.text,
      );
    } catch (_) {}

    Get.back();
  }

  onBiometricLoginClicked() async {
    try {
      if (isLoading) {
        return;
      }

      if (await BiometricHelper.isBiometricAvailable()) {
        if (await BiometricHelper.authenticate()) {
          //
          // fetching biometric ssn and mobile
          final creds = await BiometricHelper.readCredentials();
          final biometricSSN = creds.ssn;
          final biometricMobile = creds.mobile;

          // Saved creds out of sync with the enabled flag — fall back to the
          // password form instead of crashing on a null force-unwrap.
          if (biometricSSN == null || biometricMobile == null) {
            isBiometricAvaibale(false);
            CommonWidgets.showSnackBar(
              title: 'Error'.tr,
              message: 'Please log in with your credentials.',
            );
            return;
          }

          //
          // calling login api
          login(
            ssn: biometricSSN,
            mobile: biometricMobile,
            isBiometricLogin: true,
          );
        }
      }
    } catch (_) {}
  }
}
