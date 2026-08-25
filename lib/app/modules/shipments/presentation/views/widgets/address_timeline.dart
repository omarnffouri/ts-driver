import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/utils/functions.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../../controllers/shipments_controller.dart';

class AddressTimeline extends GetView<ShipmentsController> {
  const AddressTimeline({
    super.key,
    required this.tripType,
    required this.shipment,
  });

  final TripType tripType;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    TextSpan startAdddressSpan = const TextSpan(children: []);
    TextSpan endAdddressSpan = const TextSpan(children: []);

    startAdddressSpan = buildAddressTextSpan(
      location: shipment.startLocation?.location,
      tripColor: tripType.accentColor(context),
      transitDateTime: shipment.startLocation?.transitDateTime,
      textColor: context.primaryTextColor,
      dateColor: context.secondaryTextColor,
    );

    endAdddressSpan = buildAddressTextSpan(
      location: shipment.endLocation?.location,
      tripColor: tripType.accentColor(context),
      transitDateTime: shipment.endLocation?.transitDateTime,
      textColor: context.primaryTextColor,
      dateColor: context.secondaryTextColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  height: 12.h,
                  width: 12.w,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: tripType.accentColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(
                  height: getHeightOfText(startAdddressSpan),
                  width: 1.5.w,
                  child: DottedLine(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    lineLength: double.infinity,
                    lineThickness: 1.0,
                    dashLength: 3.0,
                    dashColor: tripType.accentColor(context),
                    dashRadius: 1.0,
                    dashGapRadius: 0.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.70),
              child: RichText(text: startAdddressSpan),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Column(
              children: [
                Container(
                  height: 12.h,
                  width: 12.w,
                  decoration: BoxDecoration(
                    color: tripType.accentColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.70),
              margin: const EdgeInsets.only(bottom: 5),
              child: RichText(text: endAdddressSpan),
            )
          ],
        ),
      ],
    );
  }
}

double getHeightOfText(TextSpan text) {
  final TextPainter textPainter =
      TextPainter(text: text, textDirection: TextDirection.ltr)
        ..layout(maxWidth: Get.width * 0.75);
  return textPainter.size.height;
}
