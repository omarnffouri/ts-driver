import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../controllers/documents_controller.dart';

class DocumentsProgressStrip extends StatelessWidget {
  const DocumentsProgressStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Obx(() {
        final ready = controller.readyCount;
        final total = controller.totalCount;
        final fraction = total == 0 ? 0.0 : (ready / total).clamp(0.0, 1.0);
        final percent = (fraction * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Requested from HR',
                        size: 11,
                        weight: FontWeight.w600,
                        color: context.hintColor,
                      ),
                      addVerticalSpace(3.h),
                      AppText(
                        text: '$ready of $total ready',
                        size: 16,
                        weight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                    ],
                  ),
                ),
                AppText(
                  text: '$percent%',
                  size: 15,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ],
            ),
            addVerticalSpace(10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6.h,
                  backgroundColor: context.dividerColor,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
