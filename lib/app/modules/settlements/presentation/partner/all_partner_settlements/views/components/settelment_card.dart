import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../../../../domain/entities/partner_settlement_data_entity.dart';
import '../../controllers/partner_settlements_controller.dart';
import 'settelment_widget.dart';

class SettelmentCard extends GetView<PartnerSettlementsController> {
  final List<PartnerSettlementEntity> monthSettlements;
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
    return Obx(() => Container(
          margin: const EdgeInsets.only(
            left: 14,
            right: 14,
            top: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: controller.expandedIndex.value == index
                ? null
                : context.cardColor,
            border: Border.all(
              color: context.dividerColor,
              width: 1,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: Border.all(
              color: Colors.transparent,
            ),
            clipBehavior: Clip.antiAlias,
            onExpansionChanged: (value) {},
            initiallyExpanded: index == 0,
            title: Text(
              month.month,
              style: const TextStyle(
                fontSize: 24,
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
        ));
  }
}
