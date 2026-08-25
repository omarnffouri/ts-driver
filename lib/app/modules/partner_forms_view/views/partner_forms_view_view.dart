import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import 'package:ts_driver/app/core/services/theme_service.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controllers/partner_forms_view_controller.dart';

class PartnerFormsViewView extends GetView<PartnerFormsViewController> {
  const PartnerFormsViewView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                //
                //
                // top header
                AppRedHeader(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //
                      //
                      Obx(
                        () => ProfileImage.network(
                          url: controller.user.profile,
                        ),
                      ),

                      //
                      //
                      addHorizontalSpace(10.w),

                      //
                      //
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text:
                                  "${controller.user.personalDetails?.firstName!.toString().capitalizeFirst}",
                              weight: FontWeight.bold,
                              color: context.onHeaderTextColor,
                              maxLines: 2,
                            ),
                            AppText(
                              text:
                                  "${controller.user.personalDetails?.activeApplication?.jobCategory!.replaceAll("Owner Partner", "Partner")}",
                              size: 14,
                              color: context.onHeaderTextColor,
                            )
                          ],
                        ),
                      ),

                      //
                      //
                      const _ThemeToggleButton(),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuItem(
                        title: 'Forms',
                        subtitle: 'Complete and sign available forms',
                        icon: Assets.svg.forms,
                        onTap: () {
                          Get.toNamed(Routes.FORMS);
                        },
                      ),

                      addVerticalSpace(16),
                      //
                      //
                      _MenuItem(
                        title: 'Signed Forms',
                        subtitle: 'Review forms you\'ve already signed',
                        icon: Assets.svg.signedForms,
                        onTap: () {
                          Get.toNamed(Routes.SIGNED_FORMS);
                        },
                      ),
                    ],
                  ),
                )

                //
                //
                // body
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.find<ThemeService>().toggle(),
      child: Container(
        width: 40.r,
        height: 40.r,
        margin: EdgeInsets.only(right: 6.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.segmentedTrackColor,
          border: Border.all(color: context.segmentedTrackBorderColor),
        ),
        child: Icon(
          context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 20.r,
          color: context.onHeaderTextColor,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radius,
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // ghost echo of the destination icon, bleeding off the corner
                Positioned(
                  right: -14.w,
                  bottom: -18.h,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: SvgPicture.asset(
                      icon,
                      width: 104.r,
                      height: 104.r,
                      colorFilter: ColorFilter.mode(
                        context.primaryTextColor.withValues(alpha: .06),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
                  child: Row(
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: context.primaryTint,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icon,
                            width: 26.r,
                            height: 26.r,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      addHorizontalSpace(14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: title,
                              size: 16,
                              weight: FontWeight.w600,
                              color: context.strongTextColor,
                            ),
                            addVerticalSpace(4),
                            AppText(
                              text: subtitle,
                              size: 12,
                              maxLines: 2,
                              color: context.secondaryTextColor,
                            ),
                          ],
                        ),
                      ),
                      addHorizontalSpace(8.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.r,
                        color: context.hintColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
