import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/theme_extensions.dart';
import '../../../core/utils/input_utils.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_red_header.dart';
import '../../../core/widgets/app_screen.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/common_widget.dart';
import '../../profile_details/controllers/profile_details_controller.dart';
import '../controllers/settings_controller.dart';
import 'widgets/settings_dialogs.dart';
import 'widgets/settings_tiles.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final disableUpdate =
        (controller.applicantState.applicantStatus == "hired" ||
            controller.applicantState.applicantStatus == "approved");
    Divider tileDivider() => Divider(
          height: 1.h,
          thickness: 1.h,
          indent: 64.w,
          color: context.dividerColor,
        );
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Container(
          color: context.backgroundColor,
          child: Column(
            children: [
              //
              // top header
              AppRedHeader(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    addHorizontalSpace(10.w),
                    const AppBackButton(),
                    addHorizontalSpace(4.w),
                    const Expanded(
                      child: AppText(
                        text: "Settings",
                        weight: FontWeight.bold,
                        maxLines: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              addVerticalSpace(10.h),
              // appearance / theme mode (light <-> dark)
              CustomSection(
                title: 'Appearance',
                children: [
                  Obx(() {
                    final isDark =
                        controller.themeService.mode == ThemeMode.dark;
                    return CustomTile(
                      title: 'Dark Mode',
                      icon: isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      trailing: CupertinoSwitch(
                        value: isDark,
                        onChanged: (_) => controller.themeService.toggle(),
                      ),
                      onPressed: () => controller.themeService.toggle(),
                    );
                  }),
                ],
              ),
              CustomSection(
                title: 'Account',
                children: [
                  //
                  //
                  // finger print lock option
                  Obx(
                    () => Visibility(
                      visible: controller.biometricAvailable.value,
                      child: Column(
                        children: [
                          CustomTile(
                            title: 'Biometric',
                            icon: Icons.fingerprint_rounded,
                            trailing: CupertinoSwitch(
                              value: controller.biometricEnabled.value,
                              onChanged: (value) =>
                                  controller.toggleBiometric(),
                            ),
                            onPressed: controller.toggleBiometric,
                          ),
                          tileDivider(),
                        ],
                      ),
                    ),
                  ),

                  CustomTile(
                    title: 'Change SSN',
                    icon: Icons.security,
                    enabled: !disableUpdate,
                    onPressed: disableUpdate
                        ? null
                        : () async {
                            await showUpdateDialog(
                              context: context,
                              controller: Get.put(ProfileDetailsController())
                                  .socialSecurityController,
                              label: '"Social Security Number"',
                              title: AppText(
                                text: 'Update Social Security Number'.tr,
                                weight: FontWeight.bold,
                              ),
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                                SocialSecurityNumberFormatter()
                              ],
                              onTap: () {
                                Get.put(ProfileDetailsController())
                                    .updateProfile({
                                  "ss_no": Get.put(ProfileDetailsController())
                                      .socialSecurityController
                                      .text
                                      .trim()
                                });
                              },
                            );
                          },
                  ),
                  tileDivider(),
                  CustomTile(
                    title: 'Change Mobile Number',
                    icon: Icons.phone,
                    enabled: !disableUpdate,
                    onPressed: disableUpdate
                        ? null
                        : () async {
                            await showUpdateDialog(
                              context: context,
                              controller: Get.put(ProfileDetailsController())
                                  .phoneController,
                              label: '"Mobile Number"',
                              title: AppText(
                                text: 'Update Mobile Number'.tr,
                                weight: FontWeight.bold,
                              ),
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                                SocialSecurityNumberFormatter()
                              ],
                              onTap: () {
                                Get.put(ProfileDetailsController())
                                    .updateProfile({
                                  "mobile_number":
                                      Get.put(ProfileDetailsController())
                                          .phoneController
                                          .text
                                          .trim()
                                });
                              },
                            );
                          },
                  ),
                  tileDivider(),
                  CustomTile(
                    title: 'Privacy Policies',
                    icon: Icons.privacy_tip_outlined,
                    onPressed: () async {
                      Uri url = Uri.parse(
                          'https://transport-system.com/privacy-policy/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        CommonWidgets.showSnackBar(
                          title: 'Error',
                          message: 'Cannot launch url!'.tr,
                          isError: true,
                        );
                      }
                    },
                  ),
                  tileDivider(),
                  CustomTile(
                    title: 'Delete Account',
                    destructive: true,
                    icon: Icons.delete,
                    onPressed: () => showDeleteAccountDialog(context),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CustomTile(
                  title: 'Logout',
                  icon: Icons.logout,
                  showChevron: false,
                  onPressed: () => showLogoutDialog(context),
                ),
              ),
              const Spacer(),
              Obx(() => AppText(
                    text: "v${controller.version.value}",
                    size: 13,
                    color: context.secondaryTextColor,
                  )),
              addVerticalSpace(10.h),
            ],
          ),
        ),
      ),
    );
  }
}
