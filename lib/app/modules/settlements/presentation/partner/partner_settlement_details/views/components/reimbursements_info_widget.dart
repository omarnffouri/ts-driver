import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_section.dart';
import 'package:ts_driver/app/modules/settlements/domain/entities/partner_settlement_details_entity.dart';

import '../../controllers/partner_settlement_details_controller.dart';

class ReimbursementsInfoWidget
    extends GetView<PartnerSettlementDetailsController> {
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
                          infoIndex: infoIndex,
                          reimbursementIndex: index,
                          expanded: value,
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
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${reimbursement.reimbursementType}"),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Text("${reimbursement.description}"),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      flex: 1,
                                      child: Text("\$${reimbursement.amount}")),
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

class StepItem extends StatelessWidget {
  final int index;
  final String time;
  final String location;
  final bool isFirst;
  final bool isLast;
  final bool isPickup;
  final DateTime? dateTime;

  const StepItem({
    super.key,
    required this.index,
    required this.time,
    required this.location,
    this.isFirst = false,
    this.isLast = false,
    this.isPickup = true,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildRowTop(context),
        buildRowBottom(context),
      ],
    );
  }

  Row buildRowTop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 20.0,
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isFirst
                ? Colors.blue
                : isLast
                    ? Colors.red
                    : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: isFirst
              ? const Icon(
                  Icons.home,
                  size: 16,
                  color: Colors.white,
                )
              : isLast
                  ? const Icon(
                      Icons.flag,
                      size: 16,
                      color: Colors.white,
                    )
                  : Center(
                      child: Text(
                        "$index",
                        style: Get.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text("Ansar Mall", style: Get.textTheme.bodyMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isFirst
                ? Colors.blue
                : isLast
                    ? Colors.red
                    : Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            isFirst
                ? 'Pickup'
                : isLast
                    ? 'Delivery'
                    : 'Stop',
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  IntrinsicHeight buildRowBottom(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildVerticalLine(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: Get.textTheme.bodySmall),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: buildBadges(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Opacity buildVerticalLine(BuildContext context) {
    return Opacity(
      opacity: isLast ? 0.0 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        width: 2.0,
        color: context.dividerColor,
      ),
    );
  }

  List<Widget> buildBadges(BuildContext context) {
    return [
      if (dateTime != null)
        buildBadge(
          context,
          val: "02/03/24",
          icon: const Icon(
            Icons.date_range,
            size: 16,
          ),
        ),
      if (dateTime != null)
        buildBadge(
          context,
          val: "00:00",
          icon: const Icon(
            Icons.timer_outlined,
            size: 16,
          ),
        ),
    ];
  }

  Widget buildBadge(BuildContext context, {Widget? icon, String? val}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.tileColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon?.marginOnly(right: 5) ?? const SizedBox.shrink(),
          Text(
            val ?? '',
            style: Get.theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
