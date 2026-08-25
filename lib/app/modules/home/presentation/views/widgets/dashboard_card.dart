import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/dashboard_stats.dart';

class DashboardCard extends GetView<HomeController> {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppText(
              text: "Profile Completion:",
              size: 14,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 8),
            Obx(
              () => LoadingWrapperWidget(
                isLoading: controller.isLoading,
                child: CircularPercentIndicator(
                  radius: 46.0,
                  lineWidth: 8.0,
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 600,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: context.dividerColor,
                  percent: double.parse(
                          controller.applicantState.profileCompletion ?? "0") /
                      100,
                  center: AppText(
                    text:
                        "${controller.applicantState.profileCompletion ?? 0}%",
                    size: 16,
                    weight: FontWeight.bold,
                    color: context.primaryTextColor,
                  ),
                  progressColor: AppColors.primary,
                ),
              ),
            ),
            const Divider(height: 32),
            Obx(
              () {
                return controller.isHired
                    ? LoadingWrapperWidget(
                        isLoading: controller.isLoading,
                        child: const DashboardStats(),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
