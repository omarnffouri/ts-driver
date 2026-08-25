import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

/// Small red count pill (e.g. "5"). Pass [borderColor] to draw a cutout ring
/// when the pill overlaps other content (like an icon badge).
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count, this.borderColor});

  final int count;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      constraints: BoxConstraints(minWidth: 18.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10.r),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.5),
      ),
      child: AppText(
        text: '$count',
        size: 9,
        textAlign: TextAlign.center,
        weight: FontWeight.bold,
        color: AppColors.onPrimary,
      ),
    );
  }
}
