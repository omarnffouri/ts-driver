import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as video_player;

import '../../controllers/video_player_controller.dart';
import 'video_controls_overlay.dart';

class FullScreenVideoPlayer extends StatelessWidget {
  const FullScreenVideoPlayer({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.playerController.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: player,
        child: video_player.VideoPlayer(player),
        builder: (_, value, child) {
          if (!value.isInitialized) return const SizedBox.shrink();

          return GestureDetector(
            onTap: controller.toggleVideoPlayerControls,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: child,
                  ),
                ),
                VideoControlsOverlay(
                  controller: controller,
                  showFullScreenButton: false,
                  onFullScreen: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
