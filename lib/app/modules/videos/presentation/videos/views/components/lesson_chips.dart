import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/functions.dart';
import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Category pill — brand-red tint when active, neutral when the lesson is locked.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.muted = false,
    this.size = 10,
  });

  final String label;
  final bool muted;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: muted ? context.dividerColor : context.primaryTint,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: AppText(
        text: label,
        size: size,
        weight: FontWeight.w500,
        maxLines: 1,
        color: muted ? context.hintColor : AppColors.primary,
      ),
    );
  }
}

/// Duration badge laid over a thumbnail (white on a dark scrim — theme-agnostic).
class DurationBadge extends StatelessWidget {
  const DurationBadge({super.key, required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 11.w, color: Colors.white),
          addHorizontalSpace(3.w),
          AppText(
            text: formatedTime(timeInSecond: seconds),
            size: 10,
            weight: FontWeight.w500,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
