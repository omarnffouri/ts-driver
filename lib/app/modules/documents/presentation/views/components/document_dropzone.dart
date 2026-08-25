import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';

class DocumentDropzone extends StatelessWidget {
  const DocumentDropzone({super.key, required this.onTap, this.hint});

  final VoidCallback onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(14.r),
        color: AppColors.primary.withValues(alpha: 0.5),
        strokeWidth: 1.4,
        dashPattern: const [6, 4],
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: context.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 22.w,
                  color: AppColors.primary,
                ),
              ),
              addVerticalSpace(8.h),
              const AppText(
                text: 'Tap to attach file',
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.primary,
              ),
              if (hint != null) ...[
                addVerticalSpace(2.h),
                AppText(text: hint!, size: 11, color: context.hintColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
