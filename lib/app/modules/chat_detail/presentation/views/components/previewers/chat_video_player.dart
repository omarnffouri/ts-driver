import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';
import 'package:video_player/video_player.dart';

import '../bottom_sheets/speed_bottom_sheet.dart';

// ignore: must_be_immutable
class ChatVideoPlayer extends GetView<ChatDetailController> {
  ChatVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoFile,
  }) {
    Get.find<ChatDetailController>().initializeChatVideoPlayer(
      videoUrl: videoUrl,
      title: title,
      videoFile: videoFile,
    );
  }

  final String videoUrl;
  File? videoFile;
  final String title;

  void _showSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SpeedBottomSheet(
        speeds: ChatDetailController.chatVideoSpeedOptions,
        currentSpeed: controller.chatVideoPlaybackSpeed,
        onSelect: (speed) {
          controller.setChatVideoSpeed(speed);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _enterFullScreen(BuildContext context) async {
    final videoController = controller.chatVideoController;
    if (videoController == null || !videoController.value.isInitialized) return;

    final navigator = Navigator.of(context);
    await controller.enterChatVideoFullScreenMode();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => _FullScreenPlayer(controller: controller),
      ),
    );
    await controller.exitChatVideoFullScreenMode();
  }

  void _close(BuildContext context) {
    controller.disposeChatVideoPlayer();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          controller.disposeChatVideoPlayer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 70,
          leading: IconButton(
            onPressed: () => _close(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            Obx(
              () => TextButton(
                onPressed: () => _showSpeedSheet(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    controller.chatVideoSpeedLabel(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => IconButton(
                onPressed: controller.toggleChatVideoMute,
                icon: Icon(
                  controller.chatVideoIsMuted.value
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
            if (videoFile != null || videoUrl.isNotEmpty)
              Obx(
                () => controller.chatVideoIsDownloading.value
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(controller.chatVideoDownloadProgress.value * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(color: Colors.white),
                          ).marginOnly(right: 5),
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              value: controller.chatVideoDownloadProgress.value,
                              color: Colors.white,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 4,
                            ),
                          ),
                        ],
                      ).marginOnly(right: 15)
                    : IconButton(
                        onPressed: controller.handleChatVideoDownloadOrOpen,
                        icon: const Icon(
                          Icons.download_rounded,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
              ),
          ],
        ),
        body: Obx(
          () {
            final videoController = controller.chatVideoController;

            if (controller.chatVideoIsLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (controller.chatVideoIsError.value) {
              return Center(
                child: Text(
                  "Error while loading the video",
                  style: Get.theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            if (videoController == null ||
                !videoController.value.isInitialized) {
              return Center(
                child: Text(
                  "Video not available",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              );
            }

            return GestureDetector(
              onTap: controller.onTapChatVideoControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: videoController.value.aspectRatio,
                      child: VideoPlayer(videoController),
                    ),
                  ),
                  _VideoControlsOverlay(
                    controller: controller,
                    showFullScreenButton: true,
                    onFullScreen: () => _enterFullScreen(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FullScreenPlayer extends StatelessWidget {
  const _FullScreenPlayer({required this.controller});

  final ChatDetailController controller;

  void _showSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SpeedBottomSheet(
        speeds: ChatDetailController.chatVideoSpeedOptions,
        currentSpeed: controller.chatVideoPlaybackSpeed,
        onSelect: (speed) {
          controller.setChatVideoSpeed(speed);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoController = controller.chatVideoController;

    if (videoController == null) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: controller.onTapChatVideoControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              ),
            ),
            _VideoControlsOverlay(
              controller: controller,
              showFullScreenButton: false,
              onFullScreen: () => Navigator.of(context).pop(),
            ),
            Positioned(
              top: 16,
              right: 8,
              child: Row(
                children: [
                  Obx(
                    () => TextButton(
                      onPressed: () => _showSpeedSheet(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          controller.chatVideoSpeedLabel(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      onPressed: controller.toggleChatVideoMute,
                      icon: Icon(
                        controller.chatVideoIsMuted.value
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  const _VideoControlsOverlay({
    required this.controller,
    required this.showFullScreenButton,
    required this.onFullScreen,
  });

  final ChatDetailController controller;
  final bool showFullScreenButton;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    final videoController = controller.chatVideoController;
    if (videoController == null) return const SizedBox.shrink();

    return Obx(
      () => AnimatedOpacity(
        opacity: controller.chatVideoShowControls.value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black54,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.seekChatVideoBackward,
                    icon: const Icon(
                      Icons.replay_10_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => IconButton(
                      onPressed: controller.toggleChatVideoPlay,
                      icon: Icon(
                        controller.chatVideoIsPlaying.value
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: AppColors.primary,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: controller.seekChatVideoForward,
                    icon: const Icon(
                      Icons.forward_10_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: videoController,
                      builder: (_, value, __) => Text(
                        controller.formatChatVideoDuration(value.position),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: videoController,
                        builder: (_, value, __) {
                          final total =
                              value.duration.inMilliseconds.toDouble();
                          final current = value.position.inMilliseconds
                              .toDouble()
                              .clamp(0.0, total > 0 ? total : 1.0);
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              trackHeight: 3,
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: Colors.white38,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            child: Slider(
                              value: current,
                              min: 0,
                              max: total > 0 ? total : 1.0,
                              onChanged: controller.seekChatVideoToMilliseconds,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: videoController,
                      builder: (_, value, __) => Text(
                        controller.formatChatVideoDuration(value.duration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onFullScreen,
                      icon: Icon(
                        showFullScreenButton
                            ? Icons.fullscreen_rounded
                            : Icons.fullscreen_exit_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
