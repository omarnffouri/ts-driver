import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/core/widgets/icon_disc.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import '../controllers/profile_controller.dart';
import 'package:badges/badges.dart' as badges;

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
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
          child: Column(
            children: [
              header(context),
              SizedBox(height: 24.h),
              Expanded(
                child: SmartRefresher(
                  controller: controller.refreshController,
                  header: const WaterDropMaterialHeader(),
                  onRefresh: () async {
                    await controller.onRefresh();
                    controller.refreshController.refreshCompleted();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: context.dividerColor),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _MenuItem(
                              title: 'Application Profile',
                              icon: Assets.svg.profileNew,
                              onTap: controller.openProfileDetails,
                            ),
                            _MenuItem(
                              title: 'Forms',
                              icon: Assets.svg.forms,
                              onTap: controller.openForms,
                            ),
                            _MenuItem(
                              title: 'Signed Forms',
                              icon: Assets.svg.signedForms,
                              onTap: controller.openSignedForms,
                            ),
                            _MenuItem(
                              title: 'Videos',
                              icon: Assets.svg.videos,
                              onTap: controller.openVideos,
                            ),
                            _documentsItem(),
                            _MenuItem(
                              title: 'Vehicle Docs',
                              icon: Assets.svg.truckNew,
                              onTap: controller.openTruckDocuments,
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 12.h),
                  child: Center(
                    child: AppText(
                      text: "v${controller.version.value}",
                      size: 12,
                      color: context.hintColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentsItem() {
    return Obx(() {
      final loading = controller.isStatusLoading;
      return LoadingWrapperWidget(
        isLoading: loading,
        child: _MenuItem(
          title: 'Documents',
          icon: Assets.svg.documents,
          badgeCount: loading ? null : controller.pendingDocumentsCount,
          onTap: controller.openDocuments,
        ),
      );
    });
  }

  Widget header(BuildContext context) {
    final theme = Get.theme;
    return SizedBox(
      height: 190,
      child: Stack(
        children: [
          AppRedHeader(
            height: 140,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.authController.user.value.personalDetails
                                    ?.name ??
                                "",
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            "Profile",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(() => GestureDetector(
                          onTap: () async {
                            await controller.openNotifications();
                          },
                          child: badges.Badge(
                            badgeContent: AppText(
                              text:
                                  "${controller.notificationController.notifications.where((element) => element.read == 0).length}",
                              color: kMainColor,
                              size: 11,
                            ),
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.circle,
                              padding: const EdgeInsets.all(3),
                              borderRadius: BorderRadius.circular(4),
                              badgeColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Icon(
                              Icons.notifications_on_outlined,
                              size: 25.w,
                              color: Colors.white,
                            ),
                          ),
                        ).marginOnly(right: 16)),
                    IconButton(
                      icon: SvgPicture.asset(
                        Assets.svg.setting,
                        width: 25,
                        height: 25,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        controller.openSettings();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Obx(
              () => GestureDetector(
                onTap: controller.pickAndUpdateImage,
                child: CircleAvatar(
                  radius: 57,
                  backgroundColor: context.panelColor,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: context.tileColor,
                    child: Stack(
                      children: [
                        (controller.user.profile?.isNotEmpty ?? false)
                            ? ProfileImage.network(
                                url: controller.user.profile,
                                width: double.infinity,
                                height: 150,
                                showLetterOnError: true,
                              )
                            : const Center(
                                child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              )),
                        Positioned(
                          right: 2,
                          bottom: 6,
                          child: GestureDetector(
                            onTap: controller.pickAndUpdateImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: context.backgroundColor, width: 2.5),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeCount,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  _iconDisc(context),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AppText(
                      text: title,
                      size: 15,
                      weight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: context.hintColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 70.w,
            color: context.dividerColor,
          ),
      ],
    );
  }

  Widget _iconDisc(BuildContext context) {
    final disc = AppIconDisc(
      svgAsset: icon,
      color: context.secondaryTextColor,
      size: 44,
      iconSize: 22,
      radius: 13,
    );
    if (badgeCount == null || badgeCount! <= 0) return disc;
    return badges.Badge(
      badgeContent: AppText(
        text: '$badgeCount',
        color: AppColors.onPrimary,
        size: 10,
      ),
      badgeStyle: const badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: AppColors.primary,
        padding: EdgeInsets.all(5),
        elevation: 0,
      ),
      child: disc,
    );
  }
}
