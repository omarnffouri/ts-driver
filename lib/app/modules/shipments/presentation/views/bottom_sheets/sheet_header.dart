import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

/// Shared bottom-sheet header: accent icon chip + title + trailer pill.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.trailerId,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final String? trailerId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: accent.applyOpacity(
              context.statusTintAlpha(isTransit: false),
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.w, color: accent),
        ),
        addHorizontalSpace(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                addVerticalSpace(2.h),
                AppText(
                  text: subtitle!,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailerId != null && trailerId!.isNotEmpty) ...[
          addHorizontalSpace(8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: context.tileColor,
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: accent.applyOpacity(.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_rounded, size: 15.w, color: accent),
                addHorizontalSpace(5.w),
                AppText(
                  text: trailerId!,
                  size: 13,
                  weight: FontWeight.w600,
                  color: accent,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
