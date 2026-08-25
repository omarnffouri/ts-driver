import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Themed empty state shown when no training lessons are assigned.
class TrainingEmpty extends StatelessWidget {
  const TrainingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64.w,
              color: context.hintColor,
            ),
            addVerticalSpace(18.h),
            AppText(
              text: 'No training yet',
              size: 16,
              weight: FontWeight.w700,
              color: context.primaryTextColor,
            ),
            addVerticalSpace(10.h),
            AppText(
              text:
                  'Your assigned lessons will appear here.\nPull down to refresh.',
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
