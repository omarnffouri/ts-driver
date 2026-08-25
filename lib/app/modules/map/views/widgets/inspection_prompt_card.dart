import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../../../theme/app_colors.dart';

/// Inline alert shown over the map while the pre-trip trailer inspection is
/// still pending, with a Start action that opens the inspection flow.
class InspectionPromptCard extends StatelessWidget {
  const InspectionPromptCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(14.r),
      elevation: context.isDark ? 0 : 10,
      shadowColor: const Color(0x293E4958),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary.applyOpacity(.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: context.primaryTint,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.assignment_late_rounded,
                color: kMainColor,
                size: 21.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: 'Trailer inspection pending',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: context.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: 'Complete it before continuing this trip.',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.2,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              borderRadius: BorderRadius.circular(10.r),
              onTap: onPressed,
              child: Container(
                height: 38.r,
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kMainColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const AppText(
                  text: 'Start',
                  color: kWhiteColor,
                  weight: FontWeight.w700,
                  size: 12,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
