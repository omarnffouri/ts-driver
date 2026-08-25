import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ts_driver/app/core/helpers/biometric_helper.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/services/injection_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/helpers/base_use_case.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/domain/usecases/delete_account_usecase.dart';

class SettingsController extends GetxController {
  final authController = Get.find<AuthController>();
  final deleteAccountUseCase = sl.get<DeleteAccountUseCase>();
  final applicantState = Get.find<HomeController>().applicantState;
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;
  final isChecked = false.obs;
  // theme mode (delegated to the single ThemeService source of truth)
  final ThemeService themeService = Get.find<ThemeService>();
  final biometricAvailable = false.obs;
  final biometricEnabled = false.obs;
  PackageInfo? packageInfo;
  RxString version = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo!.version;
    _checkBiometricAvailable();
  }

  Future<void> deleteAccount() async {
    final result = await deleteAccountUseCase.call(const NoParams());
    result.fold(
      (success) {
        authController.logout();
      },
      (failure) {
        Get.snackbar(
          'Error'.tr,
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> logout() async {
    await authController.logout();
  }

  _checkBiometricAvailable() async {
    try {
      // The row is offered whenever the hardware supports biometric. Whether
      // it's currently on is reflected by the persisted enabled flag below.
      final available = await BiometricHelper.isBiometricAvailable();
      if (!available) {
        return;
      }
      biometricAvailable(true);
      biometricEnabled(BiometricHelper.isEnabled);
    } catch (_) {}
  }

  /// Toggles biometric login. The OS biometric prompt is the confirmation —
  /// the switch only flips after the user successfully authenticates.
  /// Enabling stores the credentials; disabling clears them.
  Future<void> toggleBiometric() async {
    try {
      if (!(await BiometricHelper.authenticate())) return;
      if (biometricEnabled.value) {
        await _disableBiometric();
      } else {
        await _enableBiometric();
      }
    } catch (_) {}
  }

  Future<void> _enableBiometric() async {
    final ssn = user.personalDetails?.ssNo;
    final mobile = user.personalDetails?.mobileNumber;
    if (ssn == null || mobile == null) {
      Get.snackbar(
        'Error'.tr,
        'Your account is missing the details needed for biometric login.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await BiometricHelper.saveCredentials(ssn: ssn, mobile: mobile);
    biometricEnabled(true);
  }

  Future<void> _disableBiometric() async {
    await BiometricHelper.clearCredentials();
    biometricEnabled(false);
  }
}
