import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../domain/entities/tire.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';

/// Section-header summary pill for a tire grid: shows "n flagged" (red) when any
/// tire is low, else "All checked" (green) once every tire is confirmed, else
/// "checked/total" progress. Reads any [List<Rx<Tire>>].
class TireSummary extends StatelessWidget {
  const TireSummary({super.key, required this.tires});

  final List<Rx<Tire>> tires;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = tires.length;
      final checked = tires.where((t) => t.value.checked).length;
      final low = tires.where((t) => t.value.isLow).length;

      if (low > 0) {
        return _pill(context, '$low low', AppColors.primary,
            context.primaryTint, Icons.priority_high_rounded);
      }
      if (checked == total) {
        return _pill(
          context,
          'All checked',
          context.successTextColor,
          context.successTextColor.withValues(alpha: 0.14),
          Icons.check_circle_rounded,
        );
      }
      return _pill(context, '$checked/$total', context.secondaryTextColor,
          context.inputFillColor, null);
    });
  }

  Widget _pill(
    BuildContext context,
    String label,
    Color color,
    Color bg,
    IconData? icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.w, color: color),
            SizedBox(width: 4.w),
          ],
          AppText(text: label, size: 11, weight: FontWeight.w700, color: color),
        ],
      ),
    );
  }
}
