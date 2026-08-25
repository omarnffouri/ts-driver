import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/services/theme_service.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/views/widgets/custom_loader.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/views/widgets/register_stepper.dart';
import '../controllers/register_controller.dart';
import 'tabs/acciden_conviction_review_view.dart';
import 'tabs/authorization_agreement_view.dart';
import 'tabs/driver_license_view.dart';
import 'tabs/employment_history_view.dart';
import 'tabs/personal_info_view.dart';
import 'tabs/present_address_view.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RegisterHeader(),
                SizedBox(height: 10.h),
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      PersonalInfoView(),
                      PresentAddressView(),
                      DriverLicenseView(),
                      AccidenConvictionReviewView(),
                      EmploymentHistoryView(),
                      AuthorizationAgreementView(),
                    ],
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.isRegistering.value
                  ? const Positioned.fill(child: CustomLoader())
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterHeader extends GetView<RegisterController> {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      width: double.infinity,
      radius: 28,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Obx(() {
            final count = controller.stepHeaderTitles.length;
            final index = controller.pageIndex.value;
            final fraction = (index + 1) / count;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BackWithProgress(
                      fraction: fraction,
                      onTap: controller.onBackPressed,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: controller.currentStepTitle,
                            size: 19,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            maxLines: 1,
                          ),
                          SizedBox(height: 3.h),
                          AppText(
                            text:
                                '${controller.currentJobTitle} · Step ${index + 1} of $count',
                            size: 12.5,
                            weight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: .85),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.find<ThemeService>().toggle(),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Icon(
                          context.isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.white,
                          size: 22.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                RegisterStepper(controller: controller),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _BackWithProgress extends StatelessWidget {
  const _BackWithProgress({required this.fraction, required this.onTap});

  final double fraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46.w,
      height: 46.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, value, __) => SizedBox(
              width: 46.w,
              height: 46.w,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: .22),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: .15),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(7.w),
                child: Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
