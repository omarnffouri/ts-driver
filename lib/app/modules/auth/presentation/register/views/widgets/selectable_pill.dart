import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// A single selectable pill: brand red when selected, soft-filled + bordered
/// otherwise. Shared by [SelectableChipGroup] and [YesNoField].
class RegisterSelectablePill extends StatelessWidget {
  const RegisterSelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.padding,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : context.inputFillColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : context.dividerColor,
          ),
        ),
        child: AppText(
          text: label,
          size: 14,
          weight: FontWeight.w600,
          color: selected ? AppColors.onPrimary : context.primaryTextColor,
        ),
      ),
    );
  }
}
