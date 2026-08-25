import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import '../controllers/notifications_controller.dart';
import 'widgets/notifications_header.dart';
import 'widgets/notifications_list.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        backgroundColor: kMainColor,
        body: Container(
          color: context.backgroundColor,
          child: Column(
            children: [
              //
              //
              //
              // top header
              NotificationsHeader(
                profileUrl: controller.user.profile,
                onBack: () async {
                  Get.back();
                  await controller.updateAllNotifications();
                  await controller.getAllNotifications();
                },
              ),

              //
              //
              // body
              Expanded(
                child: Obx(
                  () {
                    final isBusy =
                        controller.isLoading || controller.isUpdating;
                    if (isBusy) {
                      return Center(
                        child: SizedBox(
                          height: 200.h,
                          child: Lottie.asset(Assets.json.pageLoader),
                        ),
                      );
                    }

                    if (controller.notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(22.r),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications_off_rounded,
                                  size: 38.sp,
                                  color: context.hintColor,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              const AppText(
                                text: "You're all caught up",
                                size: 16,
                                weight: FontWeight.w700,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6.h),
                              AppText(
                                text:
                                    'New announcements and application updates will appear here.',
                                size: 13,
                                color: context.secondaryTextColor,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return NotificationsList(
                      notifications: controller.notifications,
                      refreshController: controller.refreshController,
                      onRefresh: () async {
                        await controller.updateAllNotifications();
                        await controller.getAllNotifications();
                        controller.refreshController.refreshCompleted();
                      },
                      onTapNotification: (notification) {
                        controller.handleClicking(notification.type!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
