import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_red_header.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/profile_image.dart';
import '../../controllers/signed_forms_controller.dart';

class SignedFormsAppBar extends GetView<SignedFormsController> {
  const SignedFormsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      child: Row(
        children: [
          const AppBackButton(),
          addHorizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  text: 'Signed Forms',
                  weight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 2,
                ),
                AppText(
                  text: controller
                          .user.personalDetails?.firstName?.capitalizeFirst ??
                      '',
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          ProfileImage.network(
            url: controller.user.profile,
            height: 40,
            width: 40,
          ),
        ],
      ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
    );
  }
}
