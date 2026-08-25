import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/shipments/presentation/views/widgets/shipment_summary_card.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../widgets/appointment_card.dart';
import '../widgets/status_pill.dart';
import 'sheet_header.dart';

class DetailsBottomSheet extends StatelessWidget {
  const DetailsBottomSheet({
    super.key,
    required this.shipment,
    required this.tripType,
    this.showCloseButton = true,
  });

  final ShipmentEntity shipment;
  final TripType tripType;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                icon: Icons.receipt_long_rounded,
                accent: tripType.accentColor(context),
                title: 'Shipment Details',
                trailerId: shipment.trailerId,
              ),
              const SizedBox(height: 10),
              StatusPill(tripType: tripType, shipment: shipment),
              const SizedBox(height: 14),
              ShipmentSummaryCard(tripType: tripType, shipment: shipment),
              const SizedBox(height: 10),
              AppointmentCard(shipment: shipment, tripType: tripType),
              if (shipment.driverInstruction?.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 10),
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
                          Icon(Icons.info_outline_rounded,
                              size: 15.w, color: tripType.accentColor(context)),
                          SizedBox(width: 6.w),
                          AppText(
                            text: 'INSTRUCTION',
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
                      SizedBox(height: 6.h),
                      AppText(
                        text: shipment.driverInstruction ?? '',
                        size: 13,
                        color: context.primaryTextColor,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              if (showCloseButton)
                AppButton(
                  text: "Close",
                  bgColor: AppColors.primary,
                  width: double.infinity,
                  hight: 50,
                  radius: 12,
                  fontWeight: FontWeight.bold,
                  onPressed: () => Navigator.pop(context),
                ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
