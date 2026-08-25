import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../domain/entities/shipment_entity.dart';

/// Tinted status badge (NEW LOAD, COMPLETED, …) keyed on the shipment's [TripType].
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.tripType, required this.shipment});

  final TripType tripType;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final color = tripType.pillTextColor(context, shipment);
    final alpha =
        context.statusTintAlpha(isTransit: tripType == TripType.transit);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.applyOpacity(alpha),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: AppText(
        text: tripType.pillLabel(shipment),
        maxLines: 1,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
          color: color,
        ),
      ),
    );
  }
}
