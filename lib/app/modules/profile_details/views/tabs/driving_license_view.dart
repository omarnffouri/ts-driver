// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_details_controller.dart';
import '../components/personal_info_card.dart';

class DrivingLicenseView extends GetView<ProfileDetailsController> {
  const DrivingLicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = controller.user.personalDetails?.activeApplication;

    if (app == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 64.r, color: kHintColor),
            SizedBox(height: 12.h),
            const AppText(
              text: 'No license data available',
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
          // ======================================================
          // ===================== License Info ====================
          // ======================================================
          PersonalInfoCard(
            title: "Driving License",
            children: [
              infoWidget("Name", controller.user.personalDetails?.firstName),
              addVerticalSpace(12.h),
              infoWidget("CDL Type", app.cdlType),
              addVerticalSpace(12.h),
              infoWidget("License Expiration Date", app.cdlLicenseExpiration),
              addVerticalSpace(12.h),
              infoWidget("Years of CDL Experience", app.cdlExp),
              addVerticalSpace(12.h),
              infoWidget(
                  "Current Driver's License Number", app.currentLicenseNum),
              addVerticalSpace(12.h),
              infoWidget(
                  "Issuing State/Province", app.cdlIssuingState.toString()),
              addVerticalSpace(12.h),
              infoWidget("Current DOT Medical Card", app.cdlDotMc),
              addVerticalSpace(12.h),
              infoWidget("DOT Medical Card Exp. Date", app.cdlDotMcExpireDate),
            ],
          ),

          // ======================================================
          // ===================== Experience ======================
          // ======================================================
          PersonalInfoCard(
            title: "Equipment Experience",
            children: [
              infoWidget("Dry Van", "5"),
              addVerticalSpace(12.h),
              infoWidget("Flatbed", "1"),
              addVerticalSpace(12.h),
              infoWidget("Reefer", "3"),
            ],
          ),

          // ======================================================
          // ===================== Questions =======================
          // ======================================================
          PersonalInfoCard(
            title: "Safety & History",
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: RichText(
                  text: TextSpan(
                    text:
                        'Have you ever tested positive or refused a pre-employment drug/alcohol test in the last 2 years?    ',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: app.refused ?? '....',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              addVerticalSpace(12.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: RichText(
                  text: TextSpan(
                    text:
                        "Has any license, permit, or privilege ever been suspended, revoked, or denied?      ",
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: app.hasAnyLicense ?? '....',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              addVerticalSpace(12.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: RichText(
                  text: TextSpan(
                    text:
                        "Have you ever been convicted of a felony or misdemeanor?      ",
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: app.convictedMisdemeanor ?? '....',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              addVerticalSpace(12.h),
            ],
          ),

          // ======================================================
          // ======================= Documents =====================
          // ======================================================
          PersonalInfoCard(
            title: "Uploaded Documents",
            children: [
              addVerticalSpace(10.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _documentCard(
                        title: "Medical Card",
                        imageUrl: app.medicalCardFile,
                      ),
                    ),
                    addHorizontalSpace(15.w),
                    Expanded(
                      child: _documentCard(
                        title: "Driver License",
                        imageUrl: app.driverLicenseFile,
                      ),
                    ),
                  ],
                ),
              ),
              addVerticalSpace(10.h),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ==================== Document Thumbnail =====================
  // =============================================================
  Widget _documentCard({
    required String title,
    required String? imageUrl,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Column(
          children: [
            AppText(text: title, size: 15),
            addVerticalSpace(10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 140.h,
                width: double.infinity,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover, cacheHeight: 420)
                    : Image.network(
                        "https://i.redd.it/this-truck-makes-my-heart-flutter-1987-hilux-crew-cab-2-4l-v0-4j7gvlaw9ca81.jpg",
                        fit: BoxFit.cover,
                        cacheHeight: 420,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
