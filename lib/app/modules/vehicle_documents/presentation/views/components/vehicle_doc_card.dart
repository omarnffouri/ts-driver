import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/file_helpers/file_type_visual.dart';
import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/theme_extensions.dart';

class VehicleDocCard extends StatelessWidget {
  const VehicleDocCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.iconSource,
  });

  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final IconData? icon;
  final String? iconSource;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.dividerColor),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.primaryTint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon ?? fileTypeOf(iconSource).icon,
                  size: 22.w,
                  color: AppColors.primary,
                ),
              ),
              addHorizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: title,
                      size: 14,
                      weight: FontWeight.w600,
                      maxLines: 2,
                      color: context.strongTextColor,
                    ),
                    if (subtitle?.isNotEmpty == true) ...[
                      addVerticalSpace(3.h),
                      AppText(
                        text: subtitle!,
                        size: 12,
                        maxLines: 1,
                        color: context.secondaryTextColor,
                      ),
                    ],
                  ],
                ),
              ),
              addHorizontalSpace(8.w),
              Icon(Icons.chevron_right_rounded,
                  size: 22.w, color: context.hintColor),
            ],
          ),
        ),
      ),
    );
  }
}
