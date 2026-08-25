import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/count_pill.dart';
import 'package:ts_driver/app/core/widgets/icon_disc.dart';

/// A tinted icon disc with a count pill in the corner. Used on the home cards
/// (pending forms, document requests) to signal an actionable count.
class CountIconBadge extends StatelessWidget {
  const CountIconBadge({super.key, required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconDisc(
          color: AppColors.primary,
          icon: icon,
          size: 48,
          iconSize: 24,
          radius: 14,
        ),
        if (count > 0)
          Positioned(
            right: -4.w,
            top: -4.h,
            // Border matches the card surface so the pill reads as a cutout.
            child: CountPill(count: count, borderColor: context.cardColor),
          ),
      ],
    );
  }
}
