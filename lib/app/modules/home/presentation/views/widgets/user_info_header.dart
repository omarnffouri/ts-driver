import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/clock_in_section.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

class UserInfoHeader extends GetView<HomeController> {
  const UserInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Container(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            color: Colors.white,
          ),
          child: Obx(
            () => ProfileImage.network(
              url: controller.user.value.profile,
              height: 50,
              width: 50,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Obx(
          () => LoadingWrapperWidget(
            isLoading: controller.isLoading,
            // White-based shimmer (the neutral one reads blue on red).
            baseColor: AppColors.onColoredShimmerBase,
            highlightColor: AppColors.onColoredShimmerHighlight,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.PROFILE_DETAILS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: "Hello,",
                    size: 14,
                    maxLines: 2,
                    color: context.onHeaderTextColor,
                  ),
                  AppText(
                    text:
                        "${controller.user.value.personalDetails?.firstName.toString().capitalizeFirst}",
                    weight: FontWeight.bold,
                    size: 20,
                    maxLines: 2,
                    color: context.onHeaderTextColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        const ClockInSection(),
        const SizedBox(width: 24),
      ],
    );
  }
}
