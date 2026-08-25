import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/app_update_dialog.dart';
import '../../../../core/utils/input_utils.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_details_controller.dart';
import '../components/personal_info_card.dart';

class PersonalInfoView extends GetView<ProfileDetailsController> {
  const PersonalInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final application = controller.user.personalDetails?.activeApplication;

    if (application == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined, size: 64.r, color: kHintColor),
            SizedBox(height: 12.h),
            const AppText(
              text: 'No personal info available',
              size: 15,
              weight: FontWeight.w500,
              color: kHintColor,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // -----------------------------------------------------------
          // ------------------- INFORMATION CARD ----------------------
          // -----------------------------------------------------------

          PersonalInfoCard(
            title: 'General',
            children: [
              /// Job Applied For
              infoWidget("Job Applied For", application.jobAppliedFor),
              addVerticalSpace(12.h),

              /// First Name
              infoWidget(
                  "First Name", controller.user.personalDetails?.firstName),
              addVerticalSpace(12.h),

              /// Social Security (Tappable)
              infoWidget(
                "Social Security",
                controller.ssn.value,
                isUpdateable: true,
                onTap: (controller.applicantState.applicantStatus == "hired" ||
                        controller.applicantState.applicantStatus == "approved")
                    ? null
                    : () async {
                        await showUpdateDialog(
                          context: context,
                          controller: controller.socialSecurityController,
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
                            controller.updateProfile({
                              "ss_no": controller.socialSecurityController.text
                                  .trim()
                            });
                          },
                        );
                      },
              ),
              addVerticalSpace(12.h),

              /// Middle Name
              infoWidget(
                  "Middle Name", controller.user.personalDetails?.middleName),
              addVerticalSpace(12.h),

              /// Last Name
              infoWidget(
                  "Last Name", controller.user.personalDetails?.lastName),
              addVerticalSpace(12.h),

              /// Date of Birth
              infoWidget(
                  "Date of Birth", controller.user.personalDetails?.dob ?? ''),
              addVerticalSpace(12.h),

              /// Mobile (Tappable)
              Obx(
                () => infoWidget(
                  "Mobile",
                  controller.mobile.value,
                  isUpdateable: true,
                  onTap: () async {
                    await showUpdateDialog(
                      context: context,
                      controller: controller.phoneController,
                      label: 'Mobile Number',
                      title: AppText(
                        text: 'Update Mobile Number'.tr,
                        weight: FontWeight.bold,
                      ),
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                        UsNumberTextInputFormatter(),
                      ],
                      onTap: () {
                        controller.updateProfile({
                          "mobile_number":
                              controller.phoneController.text.trim()
                        });
                      },
                    );
                  },
                ),
              ),
              addVerticalSpace(12.h),

              /// Email
              infoWidget("Email", controller.user.personalDetails?.email ?? ''),
            ],
          ),

          // -----------------------------------------------------------
          // ---------------------- ADDRESS CARD -----------------------
          // -----------------------------------------------------------

          PersonalInfoCard(
            title: 'Address',
            children: [
              infoWidget("Present Address", application.presentAddress ?? ''),
              addVerticalSpace(12.h),
              infoWidget("Address 2", "${application.presentAddress2 ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("Country", application.presentCountry ?? ''),
              addVerticalSpace(12.h),
              infoWidget("State", "${application.presentState ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("City", "${application.presentCity ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("Years at this Address",
                  application.yearsAtThisAddress ?? ''),
              addVerticalSpace(12.h),
              infoWidget("Previous Country", application.presentCountry ?? ''),
              addVerticalSpace(12.h),
              infoWidget(
                  "Previous State", "${application.previousState ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("Previous City", "${application.previousCity ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("Previous Address", application.presentAddress ?? ''),
              addVerticalSpace(12.h),
              infoWidget("Previous ZIP", "${application.previousZip ?? ''}"),
              addVerticalSpace(12.h),
              infoWidget("Years at Previous Address",
                  "${application.previousYearsAtThisAddress ?? ''}"),
            ],
          ),
        ],
      ),
    );
  }
}
