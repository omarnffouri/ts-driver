import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../../controllers/shipments_controller.dart';
import 'details_bottom_sheet.dart';
import 'rejection_bottom_sheet.dart';

class AcceptShipmentBottomSheet extends GetView<ShipmentsController> {
  const AcceptShipmentBottomSheet({super.key, required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          DetailsBottomSheet(
            shipment: shipment,
            tripType: TripType.assigned,
            showCloseButton: false,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AppButton(
                  text: "Accept",
                  bgColor: AppColors.primary,
                  width: double.infinity,
                  hight: 50,
                  radius: 12,
                  fontWeight: FontWeight.bold,
                  icon: const Icon(Icons.check_circle,
                      color: AppColors.onPrimary, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                    controller.updateShipment(
                      shipment: shipment,
                      status: "accepted",
                    );
                  },
                ),
                addVerticalSpace(10.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      conformRejectDialog(shipment: shipment);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: context.tileColor,
                      foregroundColor: context.secondaryTextColor,
                      side: BorderSide(color: context.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.close_rounded, size: 18.w),
                    label: AppText(
                      text: 'Reject',
                      color: context.secondaryTextColor,
                      weight: FontWeight.bold,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

Future<void> conformRejectDialog({required ShipmentEntity shipment}) async {
  showAppBottomSheet(
    isScrollControlled: false,
    child: RejectionBottomSheet(shipment: shipment),
  );
}
