import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/call_events_controller.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/native_calling/channels/native_calling_method_channel.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';

class BaseScreen extends GetView<CallEventsController> {
  final Widget child;

  /// Forwarded to the Scaffold; pass false to let the screen own keyboard space.
  final bool resizeToAvoidBottomInset;

  const BaseScreen({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          const CallingBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class CallingBanner extends GetView<CallEventsController> {
  const CallingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.currentCall.value != null,
        child: InkWell(
          onTap: () {
            if (controller.currentCall.value?.tempCallId != null) {
              NativeCallingMethodChannel.openNativeCallUI(
                  controller.currentCall.value!.tempCallId!);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsLight.mainColorDark,
                  AppColorsLight.mainColorLight,
                  Color.fromARGB(255, 183, 30, 35),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? AppColorsLight.mainColor
                    : Colors.white.applyOpacity(0.3),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  ProfileImage.network(
                    url: controller.receiverImage.value ??
                        controller.currentCall.value?.callerImage,
                    width: 30,
                    height: 30,
                    showLetterOnError: true,
                    letter: controller.getCallerNameFirstLetter(),
                  ).marginOnly(right: 10),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.receiverName.value ??
                                controller.currentCall.value?.callerName ??
                                'Call in progress',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),

                        //
                        // calling status
                        Obx(
                          () => Visibility(
                            visible: controller.isCalling.value,
                            child: const Text(
                              "calling...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ).marginOnly(right: 8),

                        //
                        // hours view
                        Obx(
                          () => Visibility(
                            visible: controller.callHours.value > 0,
                            child: Obx(
                              () => Text(
                                "${controller.callHours.value <= 9 ? '0' : ''}${controller.callHours.value.toString()} :",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ).marginOnly(right: 8),

                        //
                        // minutes view
                        Obx(
                          () => Visibility(
                            visible: controller.callMinutes.value > 0,
                            child: Text(
                              "${controller.callMinutes.value <= 9 ? '0' : ''}${controller.callMinutes.value.toString()} :",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ).marginOnly(right: 8),

                        //
                        // seconds view
                        Obx(
                          () => Visibility(
                            visible: controller.callSeconds.value > 0,
                            child: Obx(
                              () => Text(
                                "${controller.callSeconds.value <= 9 ? '0' : ''}${controller.callSeconds.value.toString()}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //
                  // end call button
                  InkWell(
                    onTap: () {
                      if (controller.currentCall.value?.tempCallId != null) {
                        NativeCallingMethodChannel.endCall(
                            controller.currentCall.value!.tempCallId!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: AppColorsLight.mainColor,
                        size: 20,
                      ),
                    ),
                  ).marginOnly(left: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
