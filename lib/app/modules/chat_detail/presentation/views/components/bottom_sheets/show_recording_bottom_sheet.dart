import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

void showRecordingBottomSheet(ChatDetailController controller) {
  Get.bottomSheet(
      ShowRecordingBottomSheetContent(
        controller: controller,
      ),
      isDismissible: false,
      enableDrag: false);
}

class ShowRecordingBottomSheetContent extends StatelessWidget {
  final ChatDetailController controller;
  const ShowRecordingBottomSheetContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),
              color: context.sheetColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // close button
              GestureDetector(
                onTap: () {
                  controller.stopRecording();
                  Get.back();
                },
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              AudioWaveforms(
                size: Size(Get.width * .9, 50),
                recorderController: controller.recorder.controller,
                enableGesture: true,
                waveStyle: const WaveStyle(
                  waveColor: AppColors.primary,
                  showDurationLabel: true,
                  spacing: 8.0,
                  showBottom: true,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              ),

              SizedBox(
                height: 50.h,
              ),

              ///  row of options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.stopRecording();
                      Get.back();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: context.hintColor),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.onPrimary,
                          size: 30,
                        )),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await controller.stopRecording();
                      controller.sendVoiceMessage();
                      Get.back();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.primary),
                        child: const Icon(
                          Icons.send,
                          color: AppColors.onPrimary,
                          size: 30,
                        )),
                  )
                ],
              ),
              if (Platform.isIOS)
                const SizedBox(
                  height: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
