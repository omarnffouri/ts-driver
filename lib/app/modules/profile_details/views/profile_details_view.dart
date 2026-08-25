import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/theme_extensions.dart';
import '../../../core/widgets/profile_image.dart';
import '../controllers/profile_details_controller.dart';

import 'tabs/accident_review_view.dart';
import 'tabs/documents_view.dart';
import 'tabs/driving_license_view.dart';
import 'tabs/personal_info_view.dart';
import 'tabs/employment_history_view.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    log('ProfileDetailsView');
    return Container(
      decoration: BoxDecoration(
        gradient: context.headerGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            color: context.backgroundColor,
            child: Column(
              children: [
                //
                // top header
                AppRedHeader(
                  radius: 0,
                  child: Column(
                    children: [
                      //
                      //
                      Row(
                        children: [
                          const AppBackButton(),
                          addHorizontalSpace(10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  text: "Application Profile",
                                  weight: FontWeight.bold,
                                  color: context.onHeaderTextColor,
                                  maxLines: 2,
                                ),
                                AppText(
                                  text:
                                      "${controller.user.personalDetails?.firstName!.toString().capitalizeFirst!}",
                                  size: 14,
                                  color: context.onHeaderTextColor,
                                )
                              ],
                            ),
                          ),
                          ProfileImage.network(
                            url: controller.user.profile,
                          ),
                        ],
                      ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
                    ],
                  ),
                ),

                Expanded(
                  child: Obx(
                    () => controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: kMainColor),
                          )
                        : DefaultTabController(
                            length: 5,
                            child: Column(
                              children: [
                                AppRedHeader(
                                    radius: 0,
                                    child: TabBar(
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      indicatorColor:
                                          context.onHeaderTextColor,
                                      dividerColor: Colors.transparent,
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      labelColor: context.onHeaderTextColor,
                                      unselectedLabelColor:
                                          context.onHeaderMutedTextColor,
                                      labelStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      unselectedLabelStyle: TextStyle(
                                        fontSize: 14.sp,
                                      ),
                                      tabs: const [
                                        Tab(text: "Personal Details"),
                                        Tab(text: "Driving License"),
                                        Tab(text: "Accident Review"),
                                        Tab(text: "Employment History"),
                                        Tab(text: "Documents"),
                                      ],
                                    )),
                                const Expanded(
                                  child: TabBarView(
                                    children: [
                                      PersonalInfoView(),
                                      DrivingLicenseView(),
                                      AccidentReviewView(),
                                      EmploymentHistoryView(),
                                      DocumentsView(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
