import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/icon_disc.dart';
import 'package:ts_driver/app/modules/notifications/domain/entities/notification_entity.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'notification_visuals.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // unread accent rail
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4.w,
              color: notification.isUnread ? accent : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 13.h, 14.w, 13.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // status icon in a tinted disc
                    AppIconDisc(
                      icon: notification.accentIcon,
                      color: accent,
                      circle: true,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppText(
                                  text: notification.title ?? '',
                                  size: 15,
                                  weight: notification.isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
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
                            SizedBox(height: 4.h),
                            AppText(
                              text: notification.preview,
                              size: 13,
                              height: 1.35,
                              color: context.secondaryTextColor,
                              maxLines: 3,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
