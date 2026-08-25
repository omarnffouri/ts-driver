import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as pl;

import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../controllers/video_player_controller.dart';
import 'anti_skip_scrubber.dart';

/// Auto-hiding control layer painted over the video — center transport cluster
/// plus a bottom scrubber row. Shared by the inline and fullscreen players.
class VideoControlsOverlay extends StatelessWidget {
  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.showFullScreenButton,
    required this.onFullScreen,
  });

  final VideoPlayerController controller;
  final bool showFullScreenButton;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    final player = controller.playerController.value;
    return Obx(() {
      final show = controller.showControls.value;
      return IgnorePointer(
        ignoring: !show,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          // Mount the controls only while visible — keeping the scrubber's
          // per-frame ValueListenableBuilder out of the tree when hidden.
          child: show
              ? Stack(
                  key: const ValueKey<bool>(true),
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ),
                    Center(child: _CenterControls(controller: controller)),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomBar(
                        controller: controller,
                        player: player,
                        showFullScreenButton: showFullScreenButton,
                        onFullScreen: onFullScreen,
                      ),
                    ),
                  ],
                )
              : const SizedBox.expand(key: ValueKey<bool>(false)),
        ),
      );
    });
  }
}

class _CenterControls extends StatelessWidget {
  const _CenterControls({required this.controller});

  final VideoPlayerController controller;

  Widget _seek(IconData icon, double size, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 24.r,
      icon: Icon(icon, size: size, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _seek(Icons.keyboard_double_arrow_left_rounded, 22.w, Colors.white70,
            controller.rewindOneMinute),
        SizedBox(width: 6.w),
        _seek(Icons.replay_10, 28.w, Colors.white, controller.rewind10seconds),
        SizedBox(width: 14.w),
        _PlayButton(controller: controller),
        SizedBox(width: 14.w),
        _seek(
            Icons.forward_10, 28.w, Colors.white, controller.forward10seconds),
        SizedBox(width: 6.w),
        _seek(Icons.keyboard_double_arrow_right_rounded, 22.w, Colors.white70,
            controller.forwardOneMinute),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final playing = controller.isPlaying.value;
      return GestureDetector(
        onTap: controller.togglePlayPause,
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(playing),
              size: 32.w,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    });
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.controller});

  final VideoPlayerController controller;

  String _label(double speed) =>
      speed == speed.roundToDouble() ? '${speed.toInt()}x' : '${speed}x';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.playbackSpeed.value;
      return PopupMenuButton<double>(
        onSelected: controller.setPlaybackSpeed,
        initialValue: current,
        color: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        itemBuilder: (_) => VideoPlayerController.playbackSpeeds
            .map(
              (speed) => PopupMenuItem<double>(
                value: speed,
                height: 36.h,
                child: AppText(
                  text: _label(speed),
                  size: 12,
                  color: speed == current ? AppColors.primary : Colors.white,
                  weight: speed == current ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            )
            .toList(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: AppText(
            text: _label(current),
            size: 12,
            color: Colors.white,
            weight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.controller,
    required this.player,
    required this.showFullScreenButton,
    required this.onFullScreen,
  });

  final VideoPlayerController controller;
  final pl.VideoPlayerController player;
  final bool showFullScreenButton;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 4.w, 6.h),
      child: ValueListenableBuilder(
        valueListenable: player,
        builder: (_, value, __) {
          return Row(
            children: [
              AppText(
                text: controller.formatDuration(value.position),
                size: 11,
                color: Colors.white,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AntiSkipScrubber(
                  position: value.position,
                  duration: value.duration,
                  maxAllowedMs: controller.maxAllowedSeekMilliseconds(),
                  onSeek: controller.seekToMilliseconds,
                ),
              ),
              SizedBox(width: 8.w),
              AppText(
                text: controller.formatDuration(value.duration),
                size: 11,
                color: Colors.white,
              ),
              _SpeedButton(controller: controller),
              IconButton(
                onPressed: onFullScreen,
                splashRadius: 22.r,
                icon: Icon(
                  showFullScreenButton
                      ? Icons.fullscreen_rounded
                      : Icons.fullscreen_exit_rounded,
                  color: Colors.white,
                  size: 22.w,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
