import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/modules/auth/data/models/application_status.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class ApplicationTab extends GetView<HomeController> {
  const ApplicationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        // Shimmer the real step list instead of a parallel skeleton.
        child: LoadingWrapperWidget(
          isLoading: controller.isLoading,
          child: controller.currentState.value.name == "on_hold" ||
                  controller.currentState.value.name == "rejected"
              ? Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 10.w,
                  ),
                  child: AppText(
                    text:
                        "Your Application is: ${controller.getStatusName(controller.currentState.value.name!)}",
                    color: AppColors.primary,
                    weight: FontWeight.bold,
                    size: 14,
                  ),
                )
              : Column(
                  children: controller.myList
                      .map((e) => _StatusStep(step: e))
                      .toList(),
                ),
        ),
      ),
    );
  }
}

class _StatusStep extends GetView<HomeController> {
  const _StatusStep({required this.step});

  final ApplicationState step;

  @override
  Widget build(BuildContext context) {
    final currentId = controller.currentState.value.id!;
    final isCompleted = step.id! < currentId;
    final isCurrent = currentId == step.id!;

    // Completed steps carry the brand red, the step in progress is amber,
    // upcoming ones stay grey.
    final checkAsset = isCompleted
        ? Assets.svg.redCheck
        : isCurrent
            ? Assets.svg.amberCheck
            : Assets.svg.greyCheck;
    final labelColor = isCompleted
        ? context.primaryTextColor
        : isCurrent
            ? context.warningTextColor
            : context.hintColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        addVerticalSpace(6.h),
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              addHorizontalSpace(Get.width > 500 ? 19.w : 16.w),
              SizedBox(
                child: SvgPicture.asset(
                  checkAsset,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              addHorizontalSpace(8.w),
              AppText(
                text: controller.getStatusName(step.name!),
                color: labelColor,
                size: 13,
              ),
              const Spacer(),
              if (controller.showWatchButton(step))
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.VIDEOS);
                  },
                  child: SvgPicture.asset(
                    Assets.svg.watch,
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              addHorizontalSpace(16.w),
            ],
          ),
        ),
        addVerticalSpace(6.h),
        if (step.id! < 5)
          Padding(
            padding: EdgeInsets.only(left: 25.w),
            child: Container(
              width: 0.7.w,
              color: context.dividerColor,
              height: 20.h,
            ),
          )
      ],
    );
  }
}
