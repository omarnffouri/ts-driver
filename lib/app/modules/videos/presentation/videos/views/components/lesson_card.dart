import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';
import '../../../../domain/entities/video_entity.dart';
import '../../../../domain/enum/lesson_state.dart';
import '../../controllers/videos_controller.dart';
import 'lesson_chips.dart';
import 'lesson_progress_bar.dart';
import 'lesson_thumbnail.dart';
import 'pressable.dart';

/// A single lesson row in the "Up next" / "Completed" lists, styled per state.
class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.index,
    required this.video,
    required this.state,
  });

  final int index;
  final VideoEntity video;
  final LessonState state;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  final VideosController controller = Get.find<VideosController>();

  // Allocated only for locked cards — the only ones that shake.
  AnimationController? _shake;
  AnimationController get _shakeController => _shake ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );

  @override
  void dispose() {
    _shake?.dispose();
    super.dispose();
  }

  void _onLockedTap() {
    _shakeController.forward(from: 0);
    controller.openLesson(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final card = _card(context);
    if (widget.state.isLocked) {
      return AnimatedBuilder(
        animation: _shakeController,
        builder: (_, child) {
          final v = _shakeController.value;
          final dx = sin(v * pi * 4) * 8.w * (1 - v);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: GestureDetector(onTap: _onLockedTap, child: card),
      );
    }
    return Pressable(
      onTap: () => controller.openLesson(widget.index),
      child: card,
    );
  }

  Widget _card(BuildContext context) {
    final locked = widget.state.isLocked;
    final inProgress = widget.state.isInProgress;
    final category = widget.video.firstCategory;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonThumbnail(
            video: widget.video,
            state: widget.state,
            width: 96.w,
            height: 64.h,
          ),
          addHorizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Lesson ${widget.index + 1}',
                  size: 10,
                  weight: FontWeight.w500,
                  color: context.hintColor,
                ),
                addVerticalSpace(2.h),
                AppText(
                  text: widget.video.title ?? '',
                  size: 14,
                  weight: FontWeight.w600,
                  maxLines: 2,
                  color: locked
                      ? context.secondaryTextColor
                      : context.strongTextColor,
                ),
                addVerticalSpace(6.h),
                Row(
                  children: [
                    if (category.isNotEmpty)
                      CategoryChip(label: category, muted: locked),
                    const Spacer(),
                    _trailing(context),
                  ],
                ),
                if (inProgress) ...[
                  addVerticalSpace(8.h),
                  LessonProgressBar(
                    fraction: widget.video.watchedFraction,
                    height: 3,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    switch (widget.state) {
      case LessonState.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 14.w, color: context.successTextColor),
            addHorizontalSpace(4.w),
            AppText(
              text: 'Completed',
              size: 10,
              weight: FontWeight.w600,
              color: context.successTextColor,
            ),
          ],
        );
      case LessonState.inProgress:
        return const AppText(
          text: 'Resume',
          size: 10,
          weight: FontWeight.w600,
          color: AppColors.primary,
        );
      case LessonState.available:
        return AppText(
          text: 'Start',
          size: 10,
          weight: FontWeight.w600,
          color: context.secondaryTextColor,
        );
      case LessonState.locked:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              text: 'Locked',
              size: 10,
              weight: FontWeight.w500,
              color: context.hintColor,
            ),
            addHorizontalSpace(4.w),
            Icon(Icons.lock_rounded, size: 13.w, color: context.hintColor),
          ],
        );
    }
  }
}
