import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_section.dart';

import '../../../../../domain/entities/settlement_details_entity.dart';
import '../../controllers/settlement_details_controller.dart';

class DeductionsInfoWidget extends GetView<SettlementDetailsController> {
  const DeductionsInfoWidget({
    super.key,
    required this.title,
    required this.total,
    required this.dudectionData,
    required this.infoIndex,
  });
  final String total;
  final String title;
  final int? infoIndex;
  final List<DeductionEntity>? dudectionData;

  @override
  Widget build(BuildContext context) {
    if (dudectionData == null || dudectionData?.isEmpty == true) {
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
            itemCount: dudectionData?.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              final deduction = dudectionData![index];
              return Obx(
                () => Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        deduction.isExpanded.value ? null : context.tileColor,
                    border: Border.all(
                      color: deduction.isExpanded.value
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
                    controller: deduction.deductionTileCtrl,
                    shape: Border.all(color: Colors.transparent),
                    clipBehavior: Clip.antiAlias,
                    onExpansionChanged: (value) {
                      if (infoIndex == null) {
                        controller.onTruckDeductionExpantionChanged(
                          index,
                          value,
                        );
                      } else {
                        controller.onDeductionExpantionChanged(
                          index,
                          value,
                        );
                      }
                    },
                    initiallyExpanded: false,
                    title: Row(
                      children: [
                        Text(
                          deduction.deductionType ?? '',
                          style: Get.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                deduction.isExpanded.value ? kMainColor : null,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "\$${deduction.amount}",
                          style: Get.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                deduction.isExpanded.value ? kMainColor : null,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 5),
                            decoration: BoxDecoration(
                              color: context.tileColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: MiniTableHeader("ID"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: MiniTableHeader("Description"),
                                ),
                                Expanded(
                                  child: MiniTableHeader("Amount"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Data Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        deduction.deductionNumber ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        deduction.description ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "\$${deduction.amount}",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
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
