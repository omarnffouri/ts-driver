import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Rounded, brand-red progress track that grows in from zero on build.
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.fraction,
    this.height = 6,
  });

  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          minHeight: height.h,
          backgroundColor: context.dividerColor,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}
