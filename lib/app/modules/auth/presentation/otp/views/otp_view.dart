import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: context.backgroundColor,
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: context.illustrationOpacity,
                    child: SvgPicture.asset(
                      Assets.svg.otp,
                      height: 250.h,
                      width: 250.w,
                    ),
                  ),
                  const AppText(
                    text: 'Verification',
                    weight: FontWeight.bold,
                    size: 18,
                  ),
                  const SizedBox(height: 10),
                  const AppText(
                    text: 'Enter your OTP code number',
                    weight: FontWeight.normal,
                    size: 13,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      margin: const EdgeInsets.all(20.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Pinput(
                        length: 4,
                        onCompleted: (value) {
                          controller.verifyOtp();
                        },
                        onChanged: (value) {
                          controller.pinController.text = value;
                          controller.pinText.value = value;
                        },
                        focusNode: controller.pinPutFocusNode,
                        autofocus: true,
                        controller: controller.pinController,
                        defaultPinTheme: PinTheme(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.inputFillColor,
                            border: Border.all(color: context.hintColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.inputFillColor,
                            border: Border.all(color: context.primaryTextColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.inputFillColor,
                            border: Border.all(color: kMainColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () {
                      final ready = controller.pinText.value.length == 4;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: AppButton(
                          text: 'Verify',
                          width: double.infinity,
                          hight: 48,
                          isLoading: controller.isVerifing.value,
                          bgColor:
                              ready ? AppColors.primary : context.dividerColor,
                          textColor:
                              ready ? AppColors.onPrimary : context.hintColor,
                          onPressed: () {
                            if (ready) controller.verifyOtp();
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const AppText(
                    text: "Didn't receive the code?",
                    size: 14,
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.start > 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: AppText(
                          text: 'Resend in ${controller.start} seconds',
                          color: context.secondaryTextColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.start == 0,
                      child: TextButton(
                        onPressed: () {
                          controller.sendOtp();
                        },
                        child: const AppText(
                          text: 'Resent code',
                          color: kMainColor,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
