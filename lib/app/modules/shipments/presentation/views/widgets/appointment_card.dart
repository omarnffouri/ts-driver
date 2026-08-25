import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/detail_row.dart';

import '../../../domain/entities/shipment_entity.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.shipment,
    required this.tripType,
  });

  final ShipmentEntity shipment;
  final TripType tripType;

  @override
  Widget build(BuildContext context) {
    final accent = tripType.accentColor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: accent.applyOpacity(
                    context.statusTintAlpha(isTransit: false),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.event_rounded, size: 16.w, color: accent),
              ),
              SizedBox(width: 8.w),
              AppText(
                text: 'APPOINTMENT',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                  color: context.secondaryTextColor,
                ),
              ),
            ],
          ),
          Divider(height: 16.h, color: context.dividerColor),
          _buildRow(
            context,
            'Pickup Date:',
            _formatDate(shipment.startLocation?.transitDateTime),
          ),
          SizedBox(height: 5.h),
          _buildRow(
            context,
            'Delivery Date:',
            _formatDate(shipment.endLocation?.transitDateTime),
          ),
          SizedBox(height: 5.h),
          _buildRow(
            context,
            'Estimated Distance:',
            shipment.estimatedDistance == null
                ? null
                : '${shipment.estimatedDistance} MI',
          ),
          SizedBox(height: 5.h),
          _buildRow(context, 'Estimated Duration:', shipment.estimatedDuration),
        ],
      ),
    );
  }

  String? _formatDate(DateTime? date) =>
      date == null ? null : DateFormat('EEEE, MMMM d, hh:mm a').format(date);

  Widget _buildRow(BuildContext context, String label, String? value) =>
      DetailRow(
        label: label,
        value: value,
        valueColor: context.primaryTextColor,
      );
}
