import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/file_helpers/file_type_visual.dart';
import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';

class AttachedFileTile extends StatelessWidget {
  const AttachedFileTile({
    super.key,
    required this.file,
    required this.name,
    required this.size,
    required this.isImage,
    required this.extension,
    required this.onRemove,
  });

  final File file;
  final String name;
  final String size;
  final bool isImage;
  final String? extension;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: context.tileColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          _thumb(context),
          addHorizontalSpace(12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  size: 13,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  color: context.strongTextColor,
                ),
                addVerticalSpace(3.h),
                AppText(text: size, size: 11, color: context.hintColor),
              ],
            ),
          ),
          addHorizontalSpace(8.w),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Icon(
                Icons.close_rounded,
                size: 18.w,
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(BuildContext context) {
    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.file(
          file,
          width: 46.w,
          height: 46.w,
          fit: BoxFit.cover,
          cacheWidth: 138,
        ),
      );
    }
    return Container(
      width: 46.w,
      height: 46.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.primaryTint,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(fileTypeOf(extension).icon,
          size: 22.w, color: AppColors.primary),
    );
  }
}
