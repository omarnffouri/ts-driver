import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Titled section in the inspection flow: a 3px red rail + optional icon +
/// UPPERCASE label (with an optional trailing widget) sitting above a themed
/// card. Mirrors the onboarding `RegisterSection` language so both flows read
/// as one app.
class InspectionSection extends StatelessWidget {
  const InspectionSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.padding,
  });

  final String title;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectionSectionHeader(title: title, icon: icon, trailing: trailing),
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.dividerColor),
            boxShadow: context.cardShadow,
          ),
          child: child,
        ),
      ],
    );
  }
}

/// The section title row on its own — for groups whose body is a stack of
/// sub-cards (e.g. damage sides) that shouldn't sit inside another card.
class InspectionSectionHeader extends StatelessWidget {
  const InspectionSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Expanded(
            child: AppText(
              text: title.toUpperCase(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: .4,
                color: context.strongTextColor,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Small brand-tinted count pill (e.g. "3" damages) used in section headers.
class InspectionCountBadge extends StatelessWidget {
  const InspectionCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.primaryTint,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: '$count',
        size: 11,
        weight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}
