import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/sheet_drag_handle.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/controllers/login_controller.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

/// Shows the one-time "enable biometric" suggestion sheet. The sheet owns its
/// own presentation (non-dismissible, white-based surface handled by the body).
Future<void> showBiometricSuggestionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BiometricSuggestionSheet(),
  );
}

class _BiometricSuggestionSheet extends GetView<LoginController> {
  const _BiometricSuggestionSheet();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.panelColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetDragHandle(),
              SizedBox(height: 20.h),
              Row(
                children: [
                  AppText(
                    text: "Biometric Login",
                    size: 16,
                    weight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.declineBiometricSuggestion,
                    child: Icon(
                      Icons.close_rounded,
                      size: 24.sp,
                      color: context.hintColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: controller.enableBiometric,
                child: Container(
                  width: 130.w,
                  height: 130.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.applyOpacity(0.16),
                        AppColors.primary.applyOpacity(0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(6.w),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      context.primaryTextColor,
                      BlendMode.srcIn,
                    ),
                    child: Transform.scale(
                      scale: 1.5,
                      child: Lottie.asset(Assets.json.biometricAnimation),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              AppText(
                text:
                    "Use your fingerprint or face to sign in faster next time.",
                size: 13,
                maxLines: 2,
                textAlign: TextAlign.center,
                color: context.secondaryTextColor,
              ),
              SizedBox(height: 24.h),
              AppButton(
                text: "Enable",
                bgColor: AppColors.primary,
                onPressed: controller.enableBiometric,
              ),
              SizedBox(height: 6.h),
              TextButton(
                onPressed: controller.declineBiometricSuggestion,
                child: AppText(
                  text: "Skip",
                  size: 14,
                  weight: FontWeight.w600,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
