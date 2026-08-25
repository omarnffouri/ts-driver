import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

/// Full-screen submit overlay shown while the registration request is in
/// flight. Theme-aware scrim so it dims correctly in light and dark.
class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.backgroundColor.withValues(alpha: 0.94),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            text: 'Please wait...',
            weight: FontWeight.w700,
            color: AppColors.primary,
            size: 24,
          ),
          addVerticalSpace(6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: AppText(
              text: 'We are processing your request, do not close the App!',
              color: context.secondaryTextColor,
              weight: FontWeight.w600,
              size: 15,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 200.h,
            child: Lottie.asset(Assets.json.pageLoader),
          ),
        ],
      ),
    );
  }
}
