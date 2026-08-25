import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';

class DocumentsEmpty extends StatelessWidget {
  const DocumentsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 40.w,
                color: AppColors.primary,
              ),
            ),
            addVerticalSpace(20.h),
            AppText(
              text: "You're all caught up",
              size: 18,
              weight: FontWeight.w700,
              color: context.primaryTextColor,
            ),
            addVerticalSpace(8.h),
            AppText(
              text:
                  'No documents requested from HR right now.\nPull down to refresh.',
              size: 13,
              maxLines: 3,
              textAlign: TextAlign.center,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
