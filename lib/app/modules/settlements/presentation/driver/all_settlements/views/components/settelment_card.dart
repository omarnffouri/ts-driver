import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_data_entiity.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/views/components/settelment_widget.dart';

class SettelmentCard extends GetView<SettlementsController> {
  final List<SettlementDataEntity> monthSettlements;
  final SettlementsMonthEntity month;
  final int index;
  const SettelmentCard({
    required this.month,
    required this.index,
    required this.monthSettlements,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Card(
        elevation: 2,
        // margin: const EdgeInsets.only(
        //   left: 14,
        //   right: 14,
        //   top: 10,
        // ),
        // padding: const EdgeInsets.symmetric(horizontal: 8),
        // decoration: BoxDecoration(
        //   color: controller.expandedIndex.value == index
        //       ? null
        //       : Colors.grey.applyOpacity(0.1),
        //   border: Border.all(
        //     color: Colors.grey.shade500,
        //     width: 1,
        //   ),
        //   borderRadius: const BorderRadius.all(
        //     Radius.circular(15),
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            controller: month.tileController,
            shape: Border.all(
              color: Colors.transparent,
            ),
            clipBehavior: Clip.antiAlias,
            onExpansionChanged: (value) {
              controller.onTileExpantionChanged(index, value);
            },
            initiallyExpanded: index == 0,
            title: Text(
              month.month,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            //
            //
            children: [
              for (var settelment in monthSettlements)
                SettelementWidget(settelment: settelment)
            ],
          ),
        ),
      ),
    );
  }
}
