import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// A labelled group of form controls rendered on one themed card. The section
/// title sits above the card; children are spaced evenly inside it.
class RegisterSection extends StatelessWidget {
  const RegisterSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.gap = 16,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: gap.h));
      spaced.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 14.h,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              if (icon != null) ...[
                Icon(icon, size: 18.w, color: AppColors.primary),
                SizedBox(width: 6.w),
              ],
              AppText(
                text: title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4,
                  color: context.strongTextColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.dividerColor),
            boxShadow: context.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: spaced,
          ),
        ),
      ],
    );
  }
}
