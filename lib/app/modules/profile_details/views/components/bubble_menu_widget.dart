import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import '../../controllers/profile_details_controller.dart';

class BubbleMenuItems {
  static List<Bubble> buildBubbles(ProfileDetailsController controller) {
    return <Bubble>[
      Bubble(
        title: "Add Accident Review",
        iconColor: Colors.white,
        bubbleColor: kMainColor,
        icon: Icons.add_card_rounded,
        titleStyle: TextStyle(fontSize: 15.sp, color: Colors.white),
        onPress: () {
          Get.toNamed(
            Routes.PROFILE_ADD_ACCIDENT_HISTORY,
            arguments: 'accident',
          );
          controller.animationController!.reverse();
        },
      ),
      Bubble(
        title: "Add Traffic Conviction",
        iconColor: Colors.white,
        bubbleColor: kMainColor,
        icon: Icons.add_card_rounded,
        titleStyle: TextStyle(fontSize: 15.sp, color: Colors.white),
        onPress: () {
          Get.toNamed(
            Routes.PROFILE_ADD_ACCIDENT_HISTORY,
            arguments: 'traffict',
          );
          controller.animationController!.reverse();
        },
      ),
    ];
  }
}
