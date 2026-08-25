// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/profile_details/views/components/personal_info_card.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../../../routes/app_pages.dart';
import '../../controllers/profile_details_controller.dart';
import '../components/custom_container.dart';

class EmploymentHistoryView extends GetView<ProfileDetailsController> {
  const EmploymentHistoryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kMainColor,
        onPressed: () {
          Get.toNamed(
            Routes.PROFILE_ADD_ACCIDENT_HISTORY,
            arguments: 'history',
          );
        },
        child: const Icon(
          Icons.add,
          color: kWhiteColor,
        ),
      ),
      body: Obx(() {
        final histories = controller
                .user.personalDetails?.activeApplication?.employmentHistories ??
            [];

        if (histories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.work_off_outlined, size: 64.r, color: kHintColor),
                SizedBox(height: 12.h),
                const AppText(
                  text: 'No employment history available',
                  size: 15,
                  weight: FontWeight.w500,
                  color: kHintColor,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final employment = histories[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 15.h,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.all(Radius.circular(20.r)),
                          border: Border.all(color: context.dividerColor),
                          boxShadow: context.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AppText(
                                  text: '(${index + 1}/${histories.length})',
                                  size: 14,
                                ),
                              ],
                            ),
                            addVerticalSpace(10.h),
                            customContainer(
                              title: '* Employer History',
                            ),
                            addVerticalSpace(20.h),
                            infoWidget("Company", employment.companyName),
                            infoWidget(
                                "Supervisor's Name", employment.supervisorName),
                            infoWidget("Supervisor Phone",
                                employment.empSupervisorPhone),
                            addVerticalSpace(20.h),
                            infoWidget(
                                "Street Address", employment.empStreetAddress),
                            infoWidget("City", employment.empCity),
                            infoWidget("State/Province", employment.empState),
                            infoWidget("Zip Code", employment.empZipcode),
                            addVerticalSpace(20.h),
                            infoWidget(
                                "Position Held", employment.positionHeld),
                            infoWidget(
                              "Still Working Here",
                              employment.stillWorking == true ? "Yes" : "No",
                            ),
                            infoWidget("From Date",
                                employment.fromDate ?? "........."),
                            infoWidget(
                                "To Date", employment.toDate ?? "........."),
                            addVerticalSpace(20.h),
                            customContainer(
                              title:
                                  '* Driving/Hauling Experience With This Employer',
                            ),
                            addVerticalSpace(10.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoWidget(
                                  "Hauling What?",
                                  employment.haulingWhat,
                                ),
                                const SizedBox(height: 10),
                                infoWidget(
                                  "Number of Months",
                                  employment.haulingExperience,
                                ),
                                addVerticalSpace(20.h),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    'Was your job designated as a safety sensitive function in any DOT regulated mode subject to alcohol and controlled substances testing requirements as required by 49 CFR part 40?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryTextColor),
                                  ),
                                ),
                                addVerticalSpace(10.h),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child:
                                      Text("${employment.employerDesignated}"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      addVerticalSpace(5),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
