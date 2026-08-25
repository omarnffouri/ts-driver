import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as video_player;

import '../../controllers/video_player_controller.dart';
import 'full_screen_video_player.dart';
import 'video_controls_overlay.dart';

class VideoWidget extends GetView<VideoPlayerController> {
  const VideoWidget({super.key});

  Future<void> _enterFullScreen(BuildContext context) async {
    final navigator = Navigator.of(context);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(controller: controller),
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    // The view only mounts this once the player is initialized (it shows the
    // skeleton until then), so the size is stable and no per-tick rebuild is
    // needed — the texture updates itself and the overlay owns its reactivity.
    final player = controller.playerController.value;
    final size = player.value.size;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
        child: GestureDetector(
          onTap: controller.toggleVideoPlayerControls,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: video_player.VideoPlayer(player),
                    ),
                  ),
                ),
              ),
              VideoControlsOverlay(
                controller: controller,
                showFullScreenButton: true,
                onFullScreen: () => _enterFullScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
