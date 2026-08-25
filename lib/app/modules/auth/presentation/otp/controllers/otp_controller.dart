import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/user_entity.dart';
import 'package:ts_driver/app/modules/auth/presentation/login/controllers/login_controller.dart';
import 'package:ts_driver/app/core/transitions/circular_reveal_transition.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

import '../../../domain/usecases/firebase/sign_in_to_firebase_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/otp_verify_usecase.dart';

class OtpController extends GetxController {
  final authController = Get.find<AuthController>();

  // UseCases
  final loginUseCase = sl<LoginUseCase>();
  final signInToFirebaseUseCase = sl<SignInToFirebaseUseCase>();
  final OtpVerifyUseCase otpVerifyUseCase = sl<OtpVerifyUseCase>();

  //variables
  final pinController = TextEditingController();
  final pinPutFocusNode = FocusNode();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> body = {};

  final isVerifing = false.obs;

  final pinText = ''.obs;

  final _start = 60.obs;
  int get start => _start.value;
  set start(int value) => _start.value = value;
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      body = Get.arguments as Map<String, dynamic>;
      debugPrint("body: ${body.toString()}");
    }
  }

  @override
  void onReady() {
    super.onReady();
    startTimer();
  }

  Future<void> sendOtp() async {
    start = 60;
    debugPrint("start send otp");
    try {
      final Either<UserEntity, Failure> result = await loginUseCase.call(body);
      result.fold((UserEntity success) {
        CommonWidgets.showSnackBar(
          title: 'Success',
          message:
              'OTP Sent Successfully to ${body['mobile_number']}, Please check your inbox',
          isError: false,
        );
      }, (Failure e) {
        CommonWidgets.showSnackBar(title: 'Error', message: e.message);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error', message: e.toString());
    } finally {
      startTimer();
    }
  }

  Future<void> verifyOtp() async {
    // Drop repeat triggers (onCompleted + button can both fire).
    if (isVerifing.value) return;

    body['code'] = pinController.text;
    isVerifing.value = true;
    try {
      final result = await otpVerifyUseCase.call(body);
      await result.fold((UserEntity userEntity) async {
        CommonWidgets.showSnackBar(
          title: 'Success',
          message: 'OTP Verified',
          isError: false,
        );

        // Fire-and-forget Firebase sign-in (enables secure database rules)
        unawaited(signInToFirebaseUseCase.fireAndForget(userEntity));

        final id = userEntity.personalDetails?.applicantId ?? 0;
        final fcmToken = body['fcm'] as String?;
        if (Get.isRegistered<LoginController>()) {
          final loginController = Get.find<LoginController>();
          if (fcmToken != null) {
            unawaited(loginController.sendTokenToServer(id, fcmToken));
          }
          await loginController.saveCredintials();
        }

        await authController.saveUser(userEntity);
        // Background — chat subscriptions await authController.realtimeReady,
        // so navigation isn't blocked on the websocket handshake.
        unawaited(authController.setupRealtimeServices());

        Get.offAllNamed(
          Routes.MAIN_SCREEN,
          arguments: const {
            CircularRevealTransition.argKey: MainEntrance.reveal,
          },
        );
      }, (Failure e) async {
        CommonWidgets.showSnackBar(title: 'Error', message: e.message);
      });
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error', message: e.toString());
    } finally {
      isVerifing.value = false;
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          timer.cancel();
        } else {
          _start.value--;
        }
      },
    );
  }

  @override
  void onClose() {
    timer.cancel();
    pinController.dispose();
    pinPutFocusNode.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
