import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../controllers/videos_controller.dart';

class VideoAppbar extends GetView<VideosController> {
  const VideoAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppBackButton(),
          addHorizontalSpace(10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: "Training",
                  weight: FontWeight.bold,
                  maxLines: 2,
                  color: Colors.white,
                ),
                AppText(
                  text: controller
                      .user.personalDetails!.firstName!.capitalizeFirst!,
                  size: 14,
                  color: kWhiteColor,
                )
              ],
            ),
          ),
        ],
      ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
    );
  }
}
