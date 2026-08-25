import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Soft-filled upload tile: leading icon chip (or thumbnail once picked), the
/// document label + status, and an Upload/Change action. Sits inside a section
/// card without nesting a second card.
class DocumentUploadWidget extends StatelessWidget {
  final File? imageFile;
  final String label;
  final VoidCallback onUpload;

  const DocumentUploadWidget({
    super.key,
    required this.imageFile,
    required this.label,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = imageFile != null;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.inputFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: hasFile
                ? Image.file(
                    imageFile!,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                    cacheWidth: 132,
                  )
                : Container(
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    color: context.primaryTint,
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 22.w,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: label,
                  size: 14,
                  weight: FontWeight.w600,
                  color: context.strongTextColor,
                ),
                SizedBox(height: 2.h),
                AppText(
                  text: hasFile ? 'Selected' : 'Required',
                  size: 12,
                  color: hasFile ? context.successTextColor : context.hintColor,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
              minimumSize: Size(0, 38.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: AppText(
              text: hasFile ? 'Change' : 'Upload',
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
