import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/input_utils.dart';
import 'package:ts_driver/app/core/widgets/app_checkbox.dart';
import 'package:ts_driver/app/core/widgets/sheet_drag_handle.dart';
import 'package:ts_driver/app/core/widgets/app_input_field.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/controllers/login_controller.dart';

Future<void> showLoginSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.panelColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _LoginSheet(),
  );
}

class _LoginSheet extends GetView<LoginController> {
  const _LoginSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // keyboard inset; SafeArea above handles the gesture/nav bar.
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetDragHandle(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: 'Get started,\nSign in to your account',
                size: 18,
                maxLines: 2,
                weight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            AppInputField(
              hintText: 'Social Security Number',
              icon: Icons.person,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                SocialSecurityNumberFormatter(),
              ],
              controller: controller.socialSecurityController,
            ),
            const SizedBox(height: 16),
            AppInputField(
              hintText: 'Mobile Number',
              icon: Icons.phone_android,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                UsNumberTextInputFormatter(),
              ],
              controller: controller.phoneController,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => CustomCheckbox(
                        text: 'Remember me',
                        value: controller.rememberMe.value,
                        onChange: (val) {
                          controller.rememberMe.value = val!;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Biometric option — only when it's set up on this device.
            Obx(
              () => controller.isBiometricAvaibale.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: OutlinedButton(
                        onPressed: controller.onBiometricLoginClicked,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Sign in with biometric',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
