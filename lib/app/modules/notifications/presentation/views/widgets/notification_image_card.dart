import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/modules/notifications/domain/entities/notification_entity.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'notification_visuals.dart';

class NotificationImageCard extends StatelessWidget {
  const NotificationImageCard({super.key, required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final accent = notification.accentColor;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // banner image on a surface so transparent PNGs blend cleanly
          Container(
            width: double.infinity,
            height: 170.h,
            color: context.tileColor,
            child: ProfileImage.network(
              url: notification.image,
              width: double.infinity,
              height: 170.h,
              radius: 0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(notification.accentIcon, color: accent, size: 18.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: AppText(
                        text: notification.title ?? '',
                        size: 15,
                        weight: FontWeight.w700,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AppText(
                      text: notification.relativeTime,
                      size: 11,
                      color: context.hintColor,
                      maxLines: 1,
                    ),
                  ],
                ),
                if (notification.preview.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  AppText(
                    text: notification.preview,
                    size: 13,
                    height: 1.35,
                    color: context.secondaryTextColor,
                    maxLines: 4,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
