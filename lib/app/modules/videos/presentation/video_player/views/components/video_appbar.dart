import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../core/widgets/app_back_button.dart';
import '../../../../../../core/widgets/app_red_header.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../controllers/video_player_controller.dart';

class VideoPlayerAppbar extends GetView<VideoPlayerController> {
  const VideoPlayerAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppBackButton(),
          addHorizontalSpace(10),
          Expanded(
            child: AppText(
              text: controller.video.value?.title ?? '',
              weight: FontWeight.bold,
              maxLines: 2,
              color: Colors.white,
            ),
          ),
        ],
      ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
    );
  }
}
