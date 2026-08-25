import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../domain/entities/tire.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';

/// A single tire's data cell with three honest states:
/// - **untouched** (still the 15/100 default): neutral fill, hollow dot, edit hint
/// - **checked & ok**: green outline + check
/// - **low / flagged**: red outline, red tint, red readings
class TireCell extends StatelessWidget {
  const TireCell({
    super.key,
    required this.tire,
    required this.label,
    required this.onTap,
  });

  final Rx<Tire> tire;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = tire.value;
      final low = t.isLow;
      final checked = t.checked;

      final Color accent = low
          ? AppColors.primary
          : (checked ? context.successTextColor : context.hintColor);
      final Color bg = low
          ? context.primaryTint
          : (checked ? context.cardColor : context.inputFillColor);
      final Color borderColor = low
          ? AppColors.primary
          : (checked ? context.successTextColor : context.dividerColor);
      final IconData stateIcon = low
          ? Icons.priority_high_rounded
          : (checked ? Icons.check_rounded : Icons.edit_outlined);
      final Color depthColor = t.depthLow
          ? AppColors.primary
          : (checked ? context.strongTextColor : context.secondaryTextColor);
      final Color psiColor = t.pressureLow
          ? AppColors.primary
          : (checked ? context.strongTextColor : context.secondaryTextColor);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: low ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: label,
                      size: 12,
                      weight: FontWeight.w700,
                      color: context.secondaryTextColor,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  _dot(context, accent, low || checked),
                  SizedBox(width: 6.w),
                  Icon(stateIcon, size: 14.w, color: accent),
                ],
              ),
              Row(
                children: [
                  AppText(
                    text: '${t.depth}/32',
                    size: 15,
                    weight: FontWeight.w700,
                    color: depthColor,
                  ),
                  AppText(text: '  ·  ', size: 12, color: context.hintColor),
                  AppText(
                    text: '${t.pressure} PSI',
                    size: 12,
                    weight: FontWeight.w600,
                    color: psiColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _dot(BuildContext context, Color color, bool filled) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1.2),
      ),
    );
  }
}
