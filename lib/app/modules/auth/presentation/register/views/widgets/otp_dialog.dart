import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/controllers/register_controller.dart';

void showOtpDialog(RegisterController controller) {
  final context = Get.context!;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: context.panelColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OtpDialogContent(controller: controller),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: context.hintColor),
                  onPressed: () {
                    controller.showOtpDialog.value = true;
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class OtpDialogContent extends StatefulWidget {
  final RegisterController controller;
  const OtpDialogContent({super.key, required this.controller});

  @override
  State<OtpDialogContent> createState() => _OtpDialogContentState();
}

class _OtpDialogContentState extends State<OtpDialogContent> {
  @override
  void initState() {
    super.initState();
    SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Obx(() {
        if (widget.controller.isVerifying.value) {
          return SizedBox(
            height: Get.size.height * 0.2,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (widget.controller.isVerified.value) {
          return SizedBox(
            height: Get.size.height * 0.2,
            child: const Center(
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 80,
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              text: 'OTP Verification',
              weight: FontWeight.bold,
              size: 22,
              color: context.primaryTextColor,
            ),
            const SizedBox(height: 10),
            AppText(
              text:
                  'Enter the OTP code sent to\n${widget.controller.formatMaskedNumber(widget.controller.personalInfoForm.mobileController.text)}',
              weight: FontWeight.normal,
              textAlign: TextAlign.center,
              size: 13,
              color: context.secondaryTextColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: PinFieldAutoFill(
                codeLength: 4,
                controller: widget.controller.pinController,
                focusNode: widget.controller.pinPutFocusNode,
                autoFocus: true,
                onCodeChanged: (code) {
                  final controller = widget.controller;
                  if (code?.length == 4 && !controller.isVerifying.value) {
                    controller.pinText.value = code!;
                    controller.verifyOtp();
                  }
                },
                decoration: BoxLooseDecoration(
                  strokeColorBuilder:
                      const FixedColorBuilder(AppColors.primary),
                  radius: const Radius.circular(8),
                  gapSpace: 12,
                  strokeWidth: 1,
                  textStyle: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            AppText(
              text: "Didn't receive the code?",
              size: 14,
              color: context.secondaryTextColor,
            ),
            Obx(() => Visibility(
                  visible: widget.controller.start > 0,
                  child: TextButton(
                    onPressed: () {},
                    child: AppText(
                      text: 'Resend in ${widget.controller.start} seconds',
                      color: context.hintColor,
                      size: 14,
                    ),
                  ),
                )),
            Obx(() => Visibility(
                  visible: widget.controller.start == 0,
                  child: TextButton(
                    onPressed: () {
                      widget.controller.sendOtp();
                    },
                    child: const AppText(
                      text: 'Resend code',
                      color: AppColors.primary,
                      weight: FontWeight.bold,
                    ),
                  ),
                )),
          ],
        );
      }),
    );
  }
}
