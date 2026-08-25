import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Top/bottom gradient scrim that keeps the floating controls legible over the
/// map without a hard edge.
class MapScrim extends StatelessWidget {
  const MapScrim({super.key, required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment == Alignment.topCenter;
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          height: isTop ? 150.h : 170.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [
                (context.isDark
                        ? const Color(0xFF0C0D10)
                        : const Color(0xFF1B1C1F))
                    .applyOpacity(
                  context.isDark ? (isTop ? .42 : .52) : (isTop ? .22 : .28),
                ),
                const Color(0xFF1B1C1F).applyOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
