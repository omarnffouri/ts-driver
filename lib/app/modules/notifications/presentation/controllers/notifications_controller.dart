import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

import '../../../../core/data/error/failures.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/services/injection_service.dart';
import '../../../../core/helpers/base_use_case.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_all_notifications_usecase.dart';
import '../../domain/usecases/update_notification_usecase.dart';

class NotificationsController extends GetxController {
  final Rx<UserEntity> _user = Get.put(AuthController()).user;
  UserEntity get user => _user.value;

  final getAllNotificationsUsecase = sl<GetAllNotificationsUsecase>();
  final updateNotificationUsecase = sl<UpdateNotificationUsecase>();

  final _notifications = <NotificationEntity>[].obs;
  List<NotificationEntity> get notifications => _notifications.toList();
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isUpdating = false.obs;
  bool get isUpdating => _isUpdating.value;

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  @override
  void onInit() {
    super.onInit();
    getAllNotifications();
  }

  Future<void> getAllNotifications() async {
    await _runWithFlag(_isLoading, () async {
      final Either<List<NotificationEntity>, Failure> result =
          await getAllNotificationsUsecase.call(const NoParams());
      result.fold((List<NotificationEntity> list) {
        _notifications.assignAll(list);
        log('Notification list length: ${list.length}');
      }, _handleFailure);
    });
  }

  Future<void> updateAllNotifications() async {
    if (notifications.isEmpty) {
      return;
    }
    await _runWithFlag(_isUpdating, () async {
      final body = {"update_all": 1};
      final Either<bool, Failure> result =
          await updateNotificationUsecase.call(body);
      result.fold((bool succ) {
        log('updateAllNotifications: $succ');
      }, _handleFailure);
    });
  }

  Future<void> handleClicking(String type) async {
    switch (type) {
      case "forms":
        Get.toNamed(Routes.FORMS);
        break;
      case "applicant_status_change":
        await Get.put(HomeController()).init();
        break;
      case "driver_license" ||
            "medical_card" ||
            "social_security" ||
            "ss_4" ||
            "upload":
        Get.toNamed(
          Routes.DOCUMENTS,
          arguments: true,
        );
        break;

      default:
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> _runWithFlag(
    RxBool flag,
    Future<void> Function() action,
  ) async {
    flag.value = true;
    try {
      await action();
    } catch (e) {
      _handleError(e);
    } finally {
      flag.value = false;
    }
  }

  void _handleFailure(Failure failure) {
    CommonWidgets.showSnackBar(
      title: ''.tr,
      message: failure.message,
      isError: false,
    );
  }

  void _handleError(Object error) {
    CommonWidgets.showSnackBar(
      title: 'Error'.tr,
      message: error.toString(),
    );
    debugPrint(error.toString());
  }
}
