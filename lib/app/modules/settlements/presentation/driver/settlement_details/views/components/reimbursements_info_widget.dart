import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_section.dart';

import '../../../../../domain/entities/settlement_details_entity.dart';
import '../../controllers/settlement_details_controller.dart';

class ReimbursementsInfoWidget extends GetView<SettlementDetailsController> {
  const ReimbursementsInfoWidget({
    super.key,
    required this.title,
    required this.total,
    required this.reimbursementsData,
    required this.infoIndex,
  });

  final String total;
  final String title;
  final int? infoIndex;
  final List<ReimbursementEntity>? reimbursementsData;

  @override
  Widget build(BuildContext context) {
    if (reimbursementsData == null || reimbursementsData?.isEmpty == true) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dividerColor, width: 0.9),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettlementSectionHeader(
            title: title,
            trailing: SettlementTotal('\$${total.decimalPattern()}'),
          ),
          ListView.builder(
            itemCount: reimbursementsData?.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              final reimbursement = reimbursementsData![index];
              return Obx(
                () => Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: reimbursement.isExpanded.value
                        ? null
                        : context.tileColor,
                    border: Border.all(
                      color: reimbursement.isExpanded.value
                          ? context.hintColor
                          : context.dividerColor,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    dense: true,
                    controller: reimbursement.reimbursementTileCtrl,
                    shape: Border.all(
                      color: Colors.transparent,
                    ),
                    clipBehavior: Clip.antiAlias,
                    onExpansionChanged: (value) {
                      if (infoIndex == null) {
                        controller.onTruckReimbursementExpantionChanged(
                          index,
                          value,
                        );
                      } else {
                        controller.onReimbursementExpantionChanged(
                          index,
                          value,
                        );
                      }
                    },
                    initiallyExpanded: false,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${reimbursement.reimbursementType}",
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: reimbursement.isExpanded.value
                                  ? kMainColor
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          "\$${reimbursement.amount}",
                          style: Get.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: reimbursement.isExpanded.value
                                ? kMainColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                    //
                    //
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          // Header Row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: context.tileColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: MiniTableHeader("Fee Type"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: MiniTableHeader("Description"),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: MiniTableHeader("Amount"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Data Row
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${reimbursement.reimbursementType}"),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text("${reimbursement.description}"),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Text("\$${reimbursement.amount}"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
