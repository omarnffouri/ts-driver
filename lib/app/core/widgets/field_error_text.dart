import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

/// Inline validation error: a small error-tinted icon + message, shown beneath
/// a form field.
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 2.w),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14.w, color: AppColors.error),
          addHorizontalSpace(4.w),
          AppText(
            text: message,
            size: 11,
            weight: FontWeight.w500,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}
