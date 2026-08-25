// ignore_for_file: invalid_use_of_protected_member

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';

import '../../../core/data/error/failures.dart';
import '../../../core/values/constants.dart';
import '../../../core/services/injection_service.dart';
import '../../../core/widgets/common_widget.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/domain/usecases/update_profile_usecase.dart';

class ProfileDetailsController extends GetxController
    with GetTickerProviderStateMixin {
  final applicantState = Get.find<HomeController>().applicantState;
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;
  final updateProfileUseCase = sl<UpdateProfileUseCase>();
  AuthController authController = Get.put(
    AuthController(),
    permanent: true,
  );
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString mobile = ''.obs;
  final RxString ssn = ''.obs;

  TextEditingController socialSecurityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: animationController!);
    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    mobile.value = user.personalDetails!.mobileNumber!;
    ssn.value = user.personalDetails!.ssNo!;
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    try {
      Get.back();
      phoneController.clear();
      socialSecurityController.clear();
      _isLoading(true);
      final Either<UserEntity, Failure> result =
          await updateProfileUseCase.call(body);
      _isLoading(false);
      result.fold((UserEntity user) {
        //save user data
        final updatedUser = authController.user.value
            .copyWith(personalDetails: user.personalDetails);
        authController.user.value = updatedUser;
        authController.user.value.personalDetails!.mobileNumber =
            updatedUser.personalDetails!.mobileNumber;
        authController.user.refresh();
        mobile.value = user.personalDetails!.mobileNumber!;
        ssn.value = user.personalDetails!.ssNo!;
        CommonVariables.userData.write(USER_DATA, updatedUser.toJson());
        CommonWidgets.showSnackBar(
            title: ''.tr,
            message: 'Profile updated successfully'.tr,
            isError: false);
        // Get.back();
      }, (Failure e) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: e.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoading(false);
    }
  }
}
