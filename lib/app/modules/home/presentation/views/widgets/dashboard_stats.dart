import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../controllers/home_controller.dart';

class DashboardStats extends GetView<HomeController> {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final state = controller.applicantState;
    return Row(
      children: [
        _StatItem(
          label: "Total Earnings",
          value: state.totalEarnings?.decimalPattern().dollar() ?? "0",
        ),
        _StatItem(
          label: "Total Trips",
          value: state.totalTrips?.toString() ?? "0",
        ),
        _StatItem(
          label: "Last Settlement",
          value: state.lastSettlement?.decimalPattern().dollar() ?? "0",
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 2.h),
            AppText(
              text: label,
              size: 12,
              maxLines: 1,
              textAlign: TextAlign.center,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
