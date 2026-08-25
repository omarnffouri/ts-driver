import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../theme/app_colors.dart';

/// Seek bar that visualises the anti-skip rule: a brand-red played region, a
/// lighter "seekable" region up to the furthest-watched point, then a dimmed
/// locked-ahead region marked with a lock. Dragging into the locked region is
/// clamped by the controller, so the thumb visibly stops at the boundary.
class AntiSkipScrubber extends StatelessWidget {
  const AntiSkipScrubber({
    super.key,
    required this.position,
    required this.duration,
    required this.maxAllowedMs,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final int maxAllowedMs;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final totalMs = duration.inMilliseconds;
    final dur = (totalMs > 0 ? totalMs : 1).toDouble();
    final playedFrac = (position.inMilliseconds / dur).clamp(0.0, 1.0);
    final seekFrac = (maxAllowedMs / dur).clamp(0.0, 1.0);
    final locked = seekFrac < 0.995;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final maxLeft = (w - 12.w).clamp(0.0, w);

        return SizedBox(
          height: 24.h,
          width: w,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: SizedBox(
                  height: 4.h,
                  width: w,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      SizedBox(
                        width: w * seekFrac,
                        height: 4.h,
                        child: ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      SizedBox(
                        width: w * playedFrac,
                        height: 4.h,
                        child: const ColoredBox(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              if (locked)
                Positioned(
                  left:
                      (w * seekFrac - 5.w).clamp(0.0, (w - 10.w).clamp(0.0, w)),
                  child: Icon(
                    Icons.lock,
                    size: 10.w,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              Positioned(
                left: (w * playedFrac - 6.w).clamp(0.0, maxLeft),
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.w),
                  ),
                ),
              ),
              Positioned.fill(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: position.inMilliseconds.toDouble().clamp(0.0, dur),
                    max: dur,
                    onChanged: onSeek,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
