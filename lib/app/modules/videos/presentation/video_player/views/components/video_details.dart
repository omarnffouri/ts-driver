import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/functions.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';
import '../../../videos/views/components/lesson_chips.dart';
import '../../controllers/video_player_controller.dart';

class VideoDetails extends GetView<VideoPlayerController> {
  const VideoDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final video = controller.video.value;
    if (video == null) return const SizedBox.shrink();

    final category = video.firstCategory;
    final done = video.finishDate != null || video.isWatched == true;
    final description = video.description ?? '';
    final showAbout = description.isNotEmpty && description != video.title;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (done) ...[
            _CompletedBanner(date: video.finishDate),
            SizedBox(height: 14.h),
          ],
          const _ProgressModule(),
          SizedBox(height: 20.h),
          AppText(
            text: video.title ?? '',
            size: 18,
            weight: FontWeight.w700,
            maxLines: 2,
            color: context.primaryTextColor,
          ),
          if (category.isNotEmpty) ...[
            SizedBox(height: 8.h),
            CategoryChip(label: category.capitalizeFirst ?? category, size: 12),
          ],
          SizedBox(height: 16.h),
          const _MetaTiles(),
          if (showAbout) ...[
            SizedBox(height: 16.h),
            _About(text: description),
          ],
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({this.date});

  final String? date;

  @override
  Widget build(BuildContext context) {
    final green = context.successTextColor;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: green, size: 20.w),
          SizedBox(width: 10.w),
          AppText(
            text: date != null ? 'Completed · $date' : 'Completed',
            size: 13,
            weight: FontWeight.w600,
            color: green,
          ),
        ],
      ),
    );
  }
}

class _ProgressModule extends GetView<VideoPlayerController> {
  const _ProgressModule();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final video = controller.video.value!;
      final total = video.totalLength ?? 0;
      final watched = controller.videoTime.value;
      final done = video.finishDate != null || video.isWatched == true;
      final fraction = total == 0 ? 0.0 : (watched / total).clamp(0.0, 1.0);
      final remaining = (total - watched).clamp(0, total);

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            _Ring(fraction: done ? 1 : fraction, done: done),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    text:
                        '${controller.secondsToMinutes(watched)} / ${controller.secondsToMinutes(total)}',
                    size: 16,
                    weight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: done
                        ? 'Completed'
                        : '${formatedTime(timeInSecond: remaining)} left',
                    size: 13,
                    color: done
                        ? context.successTextColor
                        : context.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.fraction, required this.done});

  final double fraction;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? context.successTextColor : AppColors.primary;
    return SizedBox(
      width: 72.w,
      height: 72.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72.w,
            height: 72.w,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 7.w,
              backgroundColor: context.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          done
              ? Icon(Icons.check_rounded, size: 30.w, color: color)
              : AppText(
                  text: '${(fraction * 100).round()}%',
                  size: 16,
                  weight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
        ],
      ),
    );
  }
}

class _MetaTiles extends GetView<VideoPlayerController> {
  const _MetaTiles();

  @override
  Widget build(BuildContext context) {
    final video = controller.video.value!;
    final started = video.startDate;
    final finished = video.finishDate;
    final status = finished != null
        ? 'Completed'
        : (started != null ? 'In progress' : 'Not started');
    final statusColor = finished != null
        ? context.successTextColor
        : (started != null ? AppColors.primary : context.hintColor);

    return Row(
      children: [
        Expanded(child: _MetaTile(label: 'Started', value: started ?? '—')),
        SizedBox(width: 10.w),
        Expanded(child: _MetaTile(label: 'Completion', value: finished ?? '—')),
        SizedBox(width: 10.w),
        Expanded(
          child: _MetaTile(
            label: 'Status',
            value: status,
            valueColor: statusColor,
          ),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(text: label, size: 11, color: context.hintColor),
          SizedBox(height: 4.h),
          AppText(
            text: value,
            size: 13,
            weight: FontWeight.w700,
            maxLines: 1,
            color: valueColor ?? context.primaryTextColor,
          ),
        ],
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'ABOUT THIS LESSON',
          size: 11,
          weight: FontWeight.w600,
          color: context.hintColor,
        ),
        SizedBox(height: 8.h),
        AppText(
          text: text,
          size: 13,
          height: 1.5,
          maxLines: 8,
          color: context.secondaryTextColor,
        ),
      ],
    );
  }
}
