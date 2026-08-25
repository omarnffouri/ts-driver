import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_section.dart';

import '../../../../../domain/entities/partner_settlement_details_entity.dart';
import '../../controllers/partner_settlement_details_controller.dart';

class ShipmentsInfoWidget extends GetView<PartnerSettlementDetailsController> {
  const ShipmentsInfoWidget({super.key, required this.infoIndex});

  final int infoIndex;

  @override
  Widget build(BuildContext context) {
    final info = controller.settlemetDetails.value.info?[infoIndex];
    final shipments = info?.shipments;
    if (shipments == null || shipments.isEmpty) {
      return const SizedBox.shrink();
    }

    Map<String, String> truckDetails = controller.extractTruckDetails(
      controller.settlemetDetails.value.carrierDetails ?? '',
    );

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
            title: 'Shipments',
            trailing:
                SettlementTotal('\$${info?.paymentTotal?.decimalPattern()}'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            decoration: BoxDecoration(
              color: context.tileColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  Assets.svg.shipments,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColorsLight.disabledColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(
                  '${truckDetails["truckNumber"]}',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    color: AppColorsLight.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${truckDetails["customerkName"]}',
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    color: AppColorsLight.mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemCount: shipments.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, shipmentIndex) {
              final ShipmentEntity shipment = shipments[shipmentIndex];
              return Obx(
                () => Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: shipment.isExpanded.value ? null : context.tileColor,
                    border: Border.all(
                      color: shipment.isExpanded.value
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
                    controller: shipment.shipmentsTileCtrl,
                    shape: Border.all(
                      color: Colors.transparent,
                    ),
                    clipBehavior: Clip.antiAlias,
                    onExpansionChanged: (value) {
                      controller.onShipmentsExpantionChanged(
                        infoIndex: infoIndex,
                        shipmentIndex: shipmentIndex,
                        expanded: value,
                      );
                    },
                    initiallyExpanded: false,
                    title: Row(
                      children: [
                        Text(
                          "${shipment.shipmentNumber}",
                          style: Get.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                shipment.isExpanded.value ? kMainColor : null,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "\$${shipment.shipmentTotal?.decimalPattern()}",
                          style: Get.theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                shipment.isExpanded.value ? kMainColor : null,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              // Location Section
                              const Text(
                                "Location Information",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              StepItem(
                                index: 1,
                                time: shipment.pickupDate ?? '',
                                location: shipment.pickupAddress ?? '',
                                isFirst: true,
                                isLast: false,
                                isPickup: true,
                              ),
                              StepItem(
                                index: 1,
                                time: shipment.deliveryDate ?? '',
                                location: shipment.deliveryAddress ?? '',
                                isFirst: false,
                                isLast: true,
                                isPickup: true,
                              ),
                              const Divider(height: 10),

                              //! Payment Section
                              PaymentSection(shipment: shipment),

                              const SizedBox(height: 10),
                            ],
                          ),
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

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key, required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final paymentInfo = shipment.paymentInfo;
    if (paymentInfo == null || paymentInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        // Header Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: context.tileColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Row(
            children: [
              Expanded(child: MiniTableHeader("Type")),
              SizedBox(width: 10),
              Expanded(child: MiniTableHeader("Amount")),
              SizedBox(width: 10),
              Expanded(child: MiniTableHeader("Rate")),
              Expanded(child: MiniTableHeader("Payment")),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ListView.separated(
          itemCount: shipment.paymentInfo!.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            final info = shipment.paymentInfo![i];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(info.amountType?.capitalizeFirst ?? ''),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "\$${(info.amount != null) ? num.parse(info.amount!).toStringAsFixed(2) : '0.00'}",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(getPaymentRate(info)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "\$${(info.payment != null) ? num.parse(info.payment!).toStringAsFixed(2) : '0.00'}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 5),
        ),
        const Divider(height: 10),
        SettlementHighlightStrip(
          label: "Total Mileage",
          value: "${shipment.totalMileage ?? 0}",
        ),
      ],
    );
  }
}

String getPaymentRate(PaymentInfoEntity info) {
  final type = info.paymentType;
  final rate = info.rate;

  if (type == null) {
    return '';
  }
  switch (type.toLowerCase()) {
    case 'percentage':
      return '${rate?.decimalPattern()}%';
    case 'mileage':
      return '${rate?.decimalPattern()}Mi';
    case 'hourly':
      return '${rate?.dollar()}/hr';
    case 'fixed':
      return 'Fix';
    default:
      return '';
  }
}

class StepItem extends GetView<PartnerSettlementDetailsController> {
  final int index;
  final String time;
  final String location;
  final bool isFirst;
  final bool isLast;
  final bool isPickup;

  const StepItem({
    super.key,
    required this.index,
    required this.time,
    required this.location,
    this.isFirst = false,
    this.isLast = false,
    this.isPickup = true,
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
    final city = location.split(',').last;
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
        Expanded(child: Text(city, style: Get.textTheme.bodyMedium)),
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
    Map<String, String> dateDetails = controller.extractDateDetails(
      time,
    );

    return [
      if (time.isNotEmpty)
        buildBadge(
          context,
          val: dateDetails['date'],
          icon: const Icon(
            Icons.date_range,
            size: 16,
          ),
        ),
      if (time.isNotEmpty)
        buildBadge(
          context,
          val: dateDetails['time'],
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
