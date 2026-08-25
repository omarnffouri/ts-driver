import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/functions.dart';
import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';
import '../../../../domain/entities/video_entity.dart';
import '../../controllers/videos_controller.dart';
import 'lesson_network_image.dart';
import 'lesson_progress_bar.dart';
import 'pressable.dart';

/// Primary CTA — the lesson to resume (or start), shown large and tappable.
class ContinueHeroCard extends GetView<VideosController> {
  const ContinueHeroCard({
    super.key,
    required this.index,
    required this.video,
  });

  final int index;
  final VideoEntity video;

  @override
  Widget build(BuildContext context) {
    final watched = video.time ?? 0;
    final total = video.totalLength ?? 0;
    final started = watched > 0;
    final remaining = (total - watched).clamp(0, total);
    final category = video.firstCategory;
    final subline = started
        ? '${formatedTime(timeInSecond: remaining)} left'
        : 'Start lesson';

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            started ? 'CONTINUE WATCHING' : 'START NEXT LESSON',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: context.secondaryTextColor,
            ),
          ),
          addVerticalSpace(10.h),
          Pressable(
            onTap: () => controller.openLesson(index),
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: context.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _thumbnail(context, total, category),
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: video.title ?? '',
                            size: 16,
                            weight: FontWeight.w600,
                            maxLines: 1,
                            color: context.primaryTextColor,
                          ),
                          addVerticalSpace(6.h),
                          AppText(
                            text: category.isEmpty
                                ? subline
                                : '$subline · $category',
                            size: 12,
                            color: context.secondaryTextColor,
                          ),
                          addVerticalSpace(10.h),
                          LessonProgressBar(
                            fraction: video.watchedFraction,
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(BuildContext context, int total, String category) {
    return SizedBox(
      height: 168.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
              child:
                  LessonNetworkImage(url: video.videoThumb, cacheHeight: 504)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.40),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          if (category.isNotEmpty)
            Positioned(
              top: 12.h,
              left: 12.w,
              child: _OverlayPill(label: category),
            ),
          Positioned(
            top: 12.h,
            right: 12.w,
            child: _OverlayPill(
              label: formatedTime(timeInSecond: total),
              icon: Icons.schedule_rounded,
            ),
          ),
          Center(child: _PlayButton()),
        ],
      ),
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.w, color: context.primaryTextColor),
            addHorizontalSpace(4.w),
          ],
          AppText(
            text: label,
            size: 10,
            weight: FontWeight.w500,
            color: context.primaryTextColor,
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.3), width: 2.5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Icon(Icons.play_arrow_rounded, size: 30.w, color: Colors.white),
    );
  }
}

/// Celebratory hero shown when every lesson is finished.
class CourseCompleteCard extends StatelessWidget {
  const CourseCompleteCard({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 18.w),
        decoration: BoxDecoration(
          gradient: AppColors.brandHeaderGradient,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 28.w,
                color: Colors.white,
              ),
            ),
            addHorizontalSpace(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Course complete',
                    size: 17,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  addVerticalSpace(4.h),
                  AppText(
                    text: 'All $total lessons finished — nice work.',
                    size: 12.5,
                    maxLines: 2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
