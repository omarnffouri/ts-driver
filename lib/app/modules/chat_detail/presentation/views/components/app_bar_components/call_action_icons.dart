import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/agora_call_type.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

class CallActionIcons extends GetView<ChatDetailController> {
  const CallActionIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: (!controller.isSearchEnabled.value) &&
            (!controller.isMessageSelectionEnabled) &&
            controller.chatable,
        child: Obx(
          () => controller.isPlacingCall
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 4,
                  ),
                ).marginOnly(right: 15)
              : const _CallIcons(),
        ),
      ),
    );
  }
}

class _CallIcons extends GetView<ChatDetailController> {
  const _CallIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //
        //
        // audio call icon
        GestureDetector(
          onTap: () {
            if (!controller.isPlacingCall && controller.chatable) {
              controller.placeCall(AgoraCallType.audio);
            }
          },
          child: const Icon(
            Icons.call_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ).marginOnly(right: 15),

        //
        //
        // video call icon
        GestureDetector(
          onTap: () {
            if (!controller.isPlacingCall && controller.chatable) {
              controller.placeCall(AgoraCallType.video);
            }
          },
          child: const Icon(
            Icons.video_call_rounded,
            color: AppColors.primary,
            size: 25,
          ),
        ).marginOnly(right: 10),
      ],
    );
  }
}
