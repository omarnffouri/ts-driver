import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class BiometricHelper {
  static const String _ssnKey = AuthenticationPrefKeys.biometricSSN;
  static const String _mobileKey = AuthenticationPrefKeys.biometricMobile;
  static const String _enabledKey = AuthenticationPrefKeys.biometricEnabled;

  static bool get isEnabled => GetStorage().read(_enabledKey) == true;

  static Future<bool> isBiometricAvailable() async {
    try {
      // Gate on hardware capability, not on the enrolled-biometrics list. On iOS
      // canCheckBiometrics stays true even when Face ID was denied for the app
      // (biometryType != .none), whereas getAvailableBiometrics() returns an
      // empty list and would wrongly hide the toggle. Enrollment / permission is
      // resolved at authenticate() time.
      return await LocalAuthentication().canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: 'Please authenticate to proceed further.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          break;
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.noBiometricsEnrolled:
          // On iOS a denied Face ID permission surfaces here too; the toggle is
          // only shown when hardware exists, so send the user to Settings.
          _promptOpenSettings(
              'Enable Face ID / Touch ID for this app in Settings to use biometric login.');
          break;
        case LocalAuthExceptionCode.noCredentialsSet:
          _promptOpenSettings(
              'Set a device passcode in Settings to use biometric login.');
          break;
        case LocalAuthExceptionCode.temporaryLockout:
          _showError('Too many attempts. Please try again in a moment.');
          break;
        case LocalAuthExceptionCode.biometricLockout:
          _showError(
              'Biometrics are locked. Unlock your device with your passcode, then try again.');
          break;
        default:
          _showError(
              'Something went wrong with biometric. Please try after few minutes.');
      }
      return false;
    } catch (_) {
      _showError(
          'Something went wrong with biometric. Please try after few minutes.');
      return false;
    }
  }

  static void _showError(String message) {
    CommonWidgets.showSnackBar(
      title: 'Biometric Error',
      message: message,
      isError: true,
    );
  }

  static void _promptOpenSettings(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Biometric Login',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => AppSettings.openAppSettings(),
        child: const Text('Open Settings'),
      ),
    );
  }

  static Future<void> saveCredentials({
    required String ssn,
    required String mobile,
  }) async {
    const secure = FlutterSecureStorage();
    await Future.wait([
      secure.write(key: _ssnKey, value: ssn),
      secure.write(key: _mobileKey, value: mobile),
    ]);
    await GetStorage().write(_enabledKey, true);
  }

  static Future<({String? ssn, String? mobile})> readCredentials() async {
    const secure = FlutterSecureStorage();
    final values = await Future.wait([
      secure.read(key: _ssnKey),
      secure.read(key: _mobileKey),
    ]);
    return (ssn: values[0], mobile: values[1]);
  }

  static Future<void> clearCredentials() async {
    const secure = FlutterSecureStorage();
    await Future.wait([
      secure.delete(key: _ssnKey),
      secure.delete(key: _mobileKey),
    ]);
    await GetStorage().write(_enabledKey, false);
  }
}
