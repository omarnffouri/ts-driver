import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../theme/app_colors.dart';
import '../../../../domain/entities/video_entity.dart';
import '../../../../domain/enum/lesson_state.dart';
import 'lesson_chips.dart';
import 'lesson_network_image.dart';

const ColorFilter _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Lesson artwork with a duration badge and a state-driven overlay
/// (play / lock / completed seal). Used by the up-next lesson cards.
class LessonThumbnail extends StatelessWidget {
  const LessonThumbnail({
    super.key,
    required this.video,
    required this.state,
    required this.width,
    required this.height,
  });

  final VideoEntity video;
  final LessonState state;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget image = LessonNetworkImage(
        url: video.videoThumb, cacheHeight: (height * 3).round());

    if (state.isLocked) {
      image = ColorFiltered(colorFilter: _greyscale, child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: image),
            if (state.isLocked)
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
              ),
            if (state.isAvailable || state.isInProgress)
              Center(child: _PlayDisc()),
            if (state.isLocked)
              Center(
                child:
                    Icon(Icons.lock_rounded, size: 22.w, color: Colors.white),
              ),
            Positioned(
              left: 6.w,
              bottom: 6.h,
              child: DurationBadge(seconds: video.totalLength ?? 0),
            ),
            if (state.isCompleted)
              Positioned(right: 6.w, bottom: 6.h, child: _CheckSeal()),
          ],
        ),
      ),
    );
  }
}

class _PlayDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
      ),
      child:
          Icon(Icons.play_arrow_rounded, size: 20.w, color: AppColors.primary),
    );
  }
}

class _CheckSeal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, size: 13.w, color: Colors.white),
    );
  }
}
