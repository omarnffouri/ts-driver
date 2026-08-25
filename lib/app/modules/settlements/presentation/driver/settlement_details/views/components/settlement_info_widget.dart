import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/detail_row.dart';

import '../../controllers/settlement_details_controller.dart';

class SettlementInfoWidget extends GetView<SettlementDetailsController> {
  const SettlementInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dividerColor, width: 0.9),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            decoration: BoxDecoration(
              color: kMainColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Text(
                  controller.settlemetDetails.value.settlementNumber ?? 'N/A',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  controller.settlemetDetails.value.batchNumber ?? 'N/A',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          _buildRow(
            context,
            'Earnings:',
            '${controller.settlemetDetails.value.earnings}',
          ),
          const SizedBox(height: 8.0),
          _buildRow(
            context,
            'Reimbursements:',
            '${controller.settlemetDetails.value.reimbursementTotal}',
          ),
          const SizedBox(height: 8.0),
          _buildRow(
            context,
            'Deductions:',
            '${controller.settlemetDetails.value.deductionTotal}',
          ),
          const SizedBox(height: 8.0),
          _buildRow(
            context,
            'Additional Payments:',
            '${controller.settlemetDetails.value.additionalPaymentsTotal}',
          ),
          const Divider(height: 10, color: kMainColor),
          Row(
            children: [
              Text(
                'Total:',
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColorsLight.mainColor.applyOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColorsLight.mainColor, width: 0.8),
                ),
                child: Text(
                  '\$${num.parse(controller.settlemetDetails.value.total ?? '0').toStringAsFixed(2)}',
                  style: Get.theme.textTheme.bodyLarge?.copyWith(
                    color: AppColorsLight.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String? value) =>
      DetailRow(
        label: label,
        value: '\$${num.parse(value ?? '0').toStringAsFixed(2)}',
      );
}
