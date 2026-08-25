import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';

class PdfBadge extends StatelessWidget {
  const PdfBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        'PDF',
        style: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SignedAtLabel extends StatelessWidget {
  const SignedAtLabel(this.signedAt, {super.key});

  final String? signedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 12.w, color: context.hintColor),
        SizedBox(width: 4.w),
        Expanded(
          child: AppText(
            text: signedAt ?? '',
            maxLines: 1,
            size: 11,
            color: context.hintColor,
          ),
        ),
      ],
    );
  }
}
