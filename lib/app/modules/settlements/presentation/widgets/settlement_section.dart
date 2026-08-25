import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

/// A settlement section's header: a small brand accent bar, the section title,
/// an optional [trailing] (usually the total), and a hairline rule beneath.
/// Replaces the old filled grey strips so sections read flat and theme-aware.
class SettlementSectionHeader extends StatelessWidget {
  const SettlementSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AppText(
                text: title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Container(
            height: 1.4,
            color: context.hintColor.applyOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

/// The amount shown on the right of a [SettlementSectionHeader].
class SettlementTotal extends StatelessWidget {
  const SettlementTotal(this.amount, {super.key});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: amount,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: context.primaryTextColor,
      ),
    );
  }
}

/// A column header for the small detail tables (Type/Amount/Rate/Payment,
/// ID/Description/Amount, …). Shrinks to fit its column so labels never wrap
/// mid-word or clip when the column is narrow.
class MiniTableHeader extends StatelessWidget {
  const MiniTableHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: AppText(
        text: label,
        size: 14,
        weight: FontWeight.bold,
        color: context.primaryTextColor,
      ),
    );
  }
}

/// Amber "highlight" strip (e.g. Total Mileage) that stays legible in both
/// themes — a warning-tinted surface with warning-toned text, instead of a flat
/// pastel orange bar that clashes in dark mode.
class SettlementHighlightStrip extends StatelessWidget {
  const SettlementHighlightStrip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: context.warningSurfaceColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            size: 13,
            weight: FontWeight.w700,
            color: context.warningTextColor,
          ),
          AppText(
            text: value,
            size: 13,
            weight: FontWeight.w700,
            color: context.warningTextColor,
          ),
        ],
      ),
    );
  }
}
