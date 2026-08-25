import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/input_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';

import '../../controllers/register_controller.dart';
import 'otp_dialog.dart';
import 'register_field.dart';

class MobileNumberSection extends StatelessWidget {
  final RegisterController controller;
  const MobileNumberSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final personalInfoForm = controller.personalInfoForm;

    return Obx(() {
      final verified =
          controller.isVerified.value && controller.isNextBtnEnabled.value;
      final otpEnabled = controller.isOtpEnabled.value;
      final hasNumber = controller.mobileText.value.isNotEmpty;

      Widget? suffix;
      if (controller.showOtpDialog.value) {
        suffix = TextButton(
          onPressed: () => showOtpDialog(controller),
          child: const AppText(
            text: 'OTP',
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
        );
      } else if (otpEnabled && hasNumber) {
        suffix = Icon(
          verified ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: verified ? AppColors.success : AppColors.error,
        );
      }

      return RegisterField(
        controller: personalInfoForm.mobileController,
        label: 'Mobile No',
        hint: '(313)-111-1111',
        icon: Icons.phone_android_rounded,
        validatorMsg: 'Mobile Number Required',
        keyboardType: TextInputType.phone,
        formatters: [UsNumberInputFormatter()],
        readOnly: otpEnabled ? verified : false,
        suffix: suffix,
        onChanged: (val) async {
          controller.mobileText.value = val;
          if (val.length == 12 && !controller.isVerified.value) {
            if (!otpEnabled) return;
            await controller.sendOtp();
            showOtpDialog(controller);
          }
        },
      );
    });
  }
}
