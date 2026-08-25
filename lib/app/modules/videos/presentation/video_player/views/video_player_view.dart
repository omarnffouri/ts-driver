import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controllers/video_player_controller.dart';
import 'components/player_skeleton.dart';
import 'components/video_appbar.dart';
import 'components/video_details.dart';
import 'components/video_widget.dart';

class VideoPlayerView extends GetView<VideoPlayerController> {
  const VideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            const VideoPlayerAppbar(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.playerController.value,
                builder: (_, value, __) {
                  if (!value.isInitialized) return const PlayerSkeleton();
                  return Column(
                    children: [
                      SizedBox(height: 12.h),
                      const VideoWidget(),
                      const Expanded(
                        child: SingleChildScrollView(
                          child: VideoDetails(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
