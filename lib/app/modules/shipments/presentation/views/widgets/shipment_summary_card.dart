import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../domain/entities/shipment_entity.dart';
import 'address_timeline.dart';

class ShipmentSummaryCard extends StatelessWidget {
  const ShipmentSummaryCard(
      {super.key, required this.tripType, required this.shipment});

  final TripType tripType;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final accent = tripType.accentColor(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: accent.applyOpacity(
                    context.statusTintAlpha(isTransit: false),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    size: 17.w, color: accent),
              ),
              SizedBox(width: 8.w),
              AppText(
                text: "${shipment.shipmentNumber}",
                size: 16,
                weight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
              const Spacer(),
              AppText(
                text: shipment.formattedAmount,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: context.dividerColor, height: 1, thickness: 1),
          AddressTimeline(tripType: tripType, shipment: shipment),
        ],
      ),
    );
  }
}
