import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/notifications/domain/entities/notification_entity.dart';
import 'notification_image_card.dart';
import 'notification_tile.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.notifications,
    required this.refreshController,
    required this.onRefresh,
    required this.onTapNotification,
  });

  final List<NotificationEntity> notifications;
  final RefreshController refreshController;
  final Future<void> Function() onRefresh;
  final ValueChanged<NotificationEntity> onTapNotification;

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      header: const WaterDropMaterialHeader(),
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: notifications.length,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        itemBuilder: (BuildContext context, int index) {
          final notification = notifications[index];
          return InkWell(
            onTap: () => onTapNotification(notification),
            child: notification.image != null
                ? NotificationImageCard(notification: notification)
                : NotificationTile(notification: notification),
          ).marginOnly(
              top: index == 0 ? 14 : 0,
              bottom: index == (notifications.length - 1) ? 100 : 0);
        },
        separatorBuilder: (BuildContext context, int index) {
          return addVerticalSpace(14);
        },
      ),
    );
  }
}
