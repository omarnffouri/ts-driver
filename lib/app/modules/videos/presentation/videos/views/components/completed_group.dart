import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/theme_extensions.dart';
import '../../../../domain/enum/lesson_state.dart';
import '../../controllers/videos_controller.dart';
import 'lesson_card.dart';

/// Collapsible group holding finished lessons, tucked below the active list.
class CompletedGroup extends GetView<VideosController> {
  const CompletedGroup({super.key, required this.indices});

  final List<int> indices;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isCompletedExpanded;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: controller.toggleCompleted,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 20.w, color: context.successTextColor),
                    addHorizontalSpace(8.w),
                    AppText(
                      text: 'Completed (${indices.length})',
                      size: 14,
                      weight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22.w, color: context.hintColor),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      children: [
                        for (final i in indices)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: LessonCard(
                              index: i,
                              video: controller.videos[i],
                              state: LessonState.completed,
                            ),
                          ),
                      ],
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      );
    });
  }
}
