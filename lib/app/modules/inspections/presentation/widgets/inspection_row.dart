import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Settings-style list row: a brand-tinted leading icon chip + label + a
/// trailing widget, with an optional chevron when [onTap] is set. Used for both
/// the read-only identity rows (Trailer#/Trip#) and the tappable reefer rows.
class InspectionRow extends StatelessWidget {
  const InspectionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.primaryTint,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.w, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              text: label,
              size: 13.5,
              weight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          trailing,
          if (onTap != null) ...[
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded,
                size: 20.w, color: context.hintColor),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: row,
    );
  }
}

/// A compact value chip. Neutral by default; [warn] tints it amber for a
/// caution value (low oil / empty fuel).
class ValuePill extends StatelessWidget {
  const ValuePill({super.key, required this.value, this.warn = false});

  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: warn ? context.warningSurfaceColor : context.inputFillColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: AppText(
        text: value,
        size: 13,
        weight: FontWeight.w700,
        color: warn ? context.warningTextColor : context.strongTextColor,
      ),
    );
  }
}
