import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/modules/auth/domain/usecases/update_profile_usecase.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/forms/presintation/controllers/forms_controller.dart';
import 'package:ts_driver/app/modules/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../controllers/auth_controller.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/domain/usecases/firebase/send_user_location_usecase.dart';

class ProfileController extends GetxController {
  final authController = Get.find<AuthController>();
  final notificationController = Get.put(NotificationsController());
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  final Rxn<File> profileImage = Rxn<File>();

  HomeController get _homeController => Get.find<HomeController>();

  // Same pending_document_requests Home reads, so the badges can't disagree.
  int get pendingDocumentsCount => _homeController.pendingDocumentsCount;

  bool get isStatusLoading => _homeController.isLoading;

  UserEntity get user => _user.value;
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final RxBool isImageLoading = false.obs;

  PackageInfo? packageInfo;
  final RxString version = ''.obs;

  // --- Usecases ---
  final sendLocationUsecase = sl<SendUserLocationUsecase>();
  final updateProfileUseCase = sl<UpdateProfileUseCase>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadPackageInfo();
  }

  void sendLocation(MapBody body) async {
    final r = await sendLocationUsecase(body);

    r.fold(
      (l) => debugPrint("firebase user location sent"),
      (r) => debugPrint(r.toString()),
    );
  }

  Future<void> onRefresh() async {
    await _homeController.getApplicationState();
  }

  Future<void> openNotifications() async {
    await Get.toNamed(Routes.NOTIFICATIONS);
    for (final item in notificationController.notifications) {
      item.read = 1;
    }
  }

  Future<void> openDocuments() async {
    await Get.toNamed(Routes.DOCUMENTS);
  }

  void openProfileDetails() {
    Get.toNamed(Routes.PROFILE_DETAILS);
  }

  void openForms() {
    Get.replace<FormsController>(FormsController());
    Get.toNamed(Routes.FORMS);
  }

  void openSignedForms() {
    Get.toNamed(Routes.SIGNED_FORMS);
  }

  void openVideos() {
    Get.toNamed(Routes.VIDEOS);
  }

  void openTruckDocuments() {
    Get.toNamed(Routes.TRUCK_DOCUMENTS);
  }

  void openSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  Future<void> pickAndUpdateImage() async {
    final File? image = await pickFile();
    if (image != null) {
      var item = File(image.path);
      profileImage.value = image;
      Map<String, dynamic> body = {
        "profile": getFileBase64(item),
        "profile_extension": ".${getExtension(item.path)}",
      };

      try {
        isImageLoading(true);
        final Either<UserEntity, Failure> result =
            await updateProfileUseCase.call(body);
        isImageLoading(false);
        result.fold((user) {
          final updatedUser = authController.user.value.copyWith(
            personalDetails: user.personalDetails,
            profile: user.profile,
          );
          authController.user.value = updatedUser;
          authController.user.refresh();
          CommonVariables.userData.write(USER_DATA, updatedUser.toJson());
        }, (Failure r) {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: r.message,
          );
        });
      } catch (e) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: e.toString(),
        );
        debugPrint(e.toString());
        isImageLoading(false);
      }
    }
  }

  String getExtension(String path) {
    final String ext = path.split('.').last;
    debugPrint('extension is $ext');
    return ext;
  }

  Future<void> _loadPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo?.version ?? '';
  }
}
