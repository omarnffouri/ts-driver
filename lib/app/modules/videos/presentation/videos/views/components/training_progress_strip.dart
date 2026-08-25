import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';
import '../../controllers/videos_controller.dart';
import 'lesson_progress_bar.dart';

/// Slim course-progress header that frames the list as one sequential course.
class TrainingProgressStrip extends GetView<VideosController> {
  const TrainingProgressStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text:
                    '${controller.completedCount} of ${controller.totalCount} lessons',
                size: 13,
                weight: FontWeight.w500,
                color: context.secondaryTextColor,
              ),
              AppText(
                text: '${controller.progressPercent}%',
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ],
          ),
          addVerticalSpace(8.h),
          LessonProgressBar(fraction: controller.progressFraction),
        ],
      ),
    );
  }
}
