import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/controllers/call_events_controller.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/enum/access_level.dart';
import 'package:ts_driver/app/core/transitions/circular_reveal_transition.dart';
import 'package:ts_driver/app/modules/home/data/home_prewarm.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/local_notification.dart';

import '../../../core/services/injection_service.dart';
import '../../../core/helpers/base_use_case.dart';
import '../../auth/domain/usecases/get_profile_usecase.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  final authController = Get.put(AuthController(), permanent: true);
  final getProfileUseCase = sl<GetProfileUseCase>();

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  void nextPage() async {
    Get.put(CallEventsController(), permanent: true);

    // Run the profile fetch and the min-splash delay concurrently, so the
    // splash shows for max(minSplash, network) and the logo fade-in can play.
    final profileFuture = getProfileUseCase(const NoParams());
    final minSplashFuture =
        Future<void>.delayed(const Duration(milliseconds: 1200));
    final result = await profileFuture;

    await result.fold(
      (user) async {
        debugPrint('✅ Splash: User authenticated with fresh data');
        authController.isAuthenticated = true;
        authController.user.value = user;
        authController.accessLevel.value = AccessLvlExt.getAccessLevel(user);

        const mainArgs = {
          CircularRevealTransition.argKey: MainEntrance.reveal,
          CircularRevealTransition.originKey: Alignment.center,
        };
        final isPartnerOnly =
            authController.accessLevel.value == AccessLevel.partnerOnly;

        if (isPartnerOnly) {
          await minSplashFuture;
        } else {
          unawaited(authController.setupRealtimeServices());
          await Future.wait([minSplashFuture, HomePrewarm.warm()]);
        }

        Get.offAllNamed(Routes.MAIN_SCREEN, arguments: mainArgs);

        if (!isPartnerOnly) {
          FirebaseMessaging.instance.getInitialMessage().then((message) async {
            RemoteNotification? notification = message?.notification!;
            if (message != null && notification != null) {
              debugPrint(
                  'A new getInitialMessage event was published! $message');
              debugPrint("title ${notification.title}");
              await Future.delayed(const Duration(seconds: 1));
              LocalNotification.handleMessage(message.data);
            }
          });
        }
      },
      (failure) async {
        if (failure is AuthFailure) {
          debugPrint('❌ Splash: Not authenticated - ${failure.message}');
        } else if (failure is NetworkFailure || failure is OfflineFailure) {
          debugPrint('📡 Splash: Network error - ${failure.message}');
        } else {
          debugPrint('❌ Splash: Error - ${failure.message}');
        }
        await minSplashFuture;
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();

    nextPage();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
