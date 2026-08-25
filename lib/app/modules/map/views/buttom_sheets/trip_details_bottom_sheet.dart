import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/map/controllers/map_controller.dart';
import '../widgets/map_formatters.dart';
import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';
import 'package:ts_driver/app/modules/shipments/presentation/controllers/shipments_controller.dart';
import 'package:ts_driver/app/modules/shipments/presentation/views/bottom_sheets/sheet_header.dart';
import 'package:ts_driver/app/modules/shipments/presentation/views/widgets/shipment_summary_card.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class TripDetailsBottomSheet extends GetView<MapController> {
  const TripDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final shipment = controller.currentShipment.value;
    const tripType = TripType.transit;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              icon: Icons.route_rounded,
              accent: tripType.accentColor(context),
              title: 'Trip Details',
              trailerId: shipment.trailerId,
            ),
            SizedBox(height: 12.h),
            _TripFactsStrip(shipment: shipment),
            SizedBox(height: 12.h),
            _InspectionProgress(shipment: shipment),
            SizedBox(height: 12.h),
            ShipmentSummaryCard(tripType: tripType, shipment: shipment),
            if (shipment.driverInstruction?.trim().isNotEmpty ?? false) ...[
              SizedBox(height: 12.h),
              _InstructionPanel(instruction: shipment.driverInstruction ?? ''),
            ],
            SizedBox(height: 16.h),
            _CompleteTripButton(
              onTap: () async {
                Navigator.of(Get.overlayContext!).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  showConfirmBottomSheet();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void showConfirmBottomSheet() {
    Future.delayed(const Duration(milliseconds: 300), () {
      showAppBottomSheet(
        child: _DecisionBottomSheet(
          icon: Icons.flag_rounded,
          title: 'Complete trip',
          message:
              'Confirm the route is complete before moving to final documents.',
          secondaryText: 'Cancel',
          secondaryIcon: Icons.close_rounded,
          onSecondary: () {
            Navigator.of(Get.overlayContext!).pop();
          },
          primaryText: 'Complete',
          primaryIcon: Icons.check_circle_rounded,
          onPrimary: () {
            Navigator.of(Get.overlayContext!).pop();

            final isPostTripInspectionDone =
                controller.currentShipment.value.isPostTripInspectionDone;

            if (isPostTripInspectionDone == true) {
              _showUploadBolBottomSheet();
              return;
            }

            showInspectionBottomSheet();
          },
        ),
      );
    });
  }

  void showInspectionBottomSheet() {
    Future.delayed(const Duration(milliseconds: 500), () {
      showAppBottomSheet(
        child: _DecisionBottomSheet(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Post-trip inspection',
          message:
              'Run the inspection now, or continue to BOL upload and finish it later.',
          secondaryText: 'Later',
          secondaryIcon: Icons.schedule_rounded,
          onSecondary: () async {
            Navigator.of(Get.overlayContext!).pop();
            _showUploadBolBottomSheet();
          },
          primaryText: 'Start',
          primaryIcon: Icons.check_circle_rounded,
          onPrimary: () async {
            Navigator.of(Get.overlayContext!).pop();
            final isPostTripInspectionDone =
                controller.currentShipment.value.isPostTripInspectionDone;

            if (isPostTripInspectionDone == true) {
              _showUploadBolBottomSheet();
              return;
            }

            final data = await Get.toNamed(Routes.INSPECTION, arguments: {
              "shipment_id": controller.currentShipment.value.id.toString(),
              "driver_id": controller.currentShipment.value.driverId.toString(),
              "trailer_id":
                  controller.currentShipment.value.trailerId.toString(),
            });
            if (data != null && data) {
              controller.currentShipment.value.isPostTripInspectionDone = true;
              controller.currentShipment.refresh();
              _showUploadBolBottomSheet();
            }
          },
        ),
      );
    });
  }

  void _showUploadBolBottomSheet() {
    final shpCtrl = Get.find<ShipmentsController>();
    Future.delayed(const Duration(milliseconds: 100)).then(
      (_) => shpCtrl.showUploadBolBottomSheet(
        shipment: controller.currentShipment.value,
      ),
    );
  }
}

class _TripFactsStrip extends StatelessWidget {
  const _TripFactsStrip({required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final totalStops = shipment.shipmentStops?.length ?? 0;
    final completedStops = _completedStops(shipment);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SheetMetric(
              icon: Icons.straighten_rounded,
              label: 'Distance',
              value: valueOrFallback(shipment.estimatedDistance, 'N/A'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _SheetMetric(
              icon: Icons.schedule_rounded,
              label: 'ETA',
              value: valueOrFallback(shipment.estimatedDuration, 'N/A'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _SheetMetric(
              icon: Icons.flag_rounded,
              label: 'Stops',
              value: totalStops == 0 ? '0' : '$completedStops/$totalStops',
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetMetric extends StatelessWidget {
  const _SheetMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 66.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: context.inputFillColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.r, color: context.secondaryTextColor),
          SizedBox(height: 6.h),
          AppText(
            text: value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: context.primaryTextColor,
            ),
          ),
          AppText(
            text: label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: context.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionProgress extends StatelessWidget {
  const _InspectionProgress({required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_rounded,
                size: 18.r,
                color: context.primaryTextColor,
              ),
              SizedBox(width: 7.w),
              AppText(
                text: 'Inspection progress',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _InspectionBadge(
                  label: 'Pre-trip',
                  isDone: shipment.isPreTripInspectionDone == true,
                  pendingColor: kMainColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InspectionBadge(
                  label: 'Post-trip',
                  isDone: shipment.isPostTripInspectionDone == true,
                  pendingColor: AppColors.warningDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InspectionBadge extends StatelessWidget {
  const _InspectionBadge({
    required this.label,
    required this.isDone,
    required this.pendingColor,
  });

  final String label;
  final bool isDone;
  final Color pendingColor;

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.success : pendingColor;
    final icon = isDone ? Icons.check_circle_rounded : Icons.pending_rounded;
    final status = isDone ? 'Done' : 'Pending';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color.applyOpacity(context.isDark ? .20 : .12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.applyOpacity(.30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.r, color: color),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: context.primaryTextColor,
                  ),
                ),
                AppText(
                  text: status,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionPanel extends StatelessWidget {
  const _InstructionPanel({required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: context.primaryTint,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: kMainColor,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 8.w),
              AppText(
                text: 'Driver instruction',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(
            text: instruction,
            size: 13,
            color: context.secondaryTextColor,
          ),
        ],
      ),
    );
  }
}

class _CompleteTripButton extends StatelessWidget {
  const _CompleteTripButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kMainColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          height: 50.h,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: kWhiteColor,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              const AppText(
                text: 'Complete Trip',
                color: kWhiteColor,
                weight: FontWeight.w800,
                size: 15,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionBottomSheet extends StatelessWidget {
  const _DecisionBottomSheet({
    required this.icon,
    required this.title,
    required this.message,
    required this.secondaryText,
    required this.secondaryIcon,
    required this.onSecondary,
    required this.primaryText,
    required this.primaryIcon,
    required this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String secondaryText;
  final IconData secondaryIcon;
  final VoidCallback onSecondary;
  final String primaryText;
  final IconData primaryIcon;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: context.primaryTint,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: kMainColor, size: 25.r),
            ),
            SizedBox(height: 12.h),
            AppText(
              text: title,
              maxLines: 1,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: context.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: message,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: context.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _DialogActionButton(
                    text: secondaryText,
                    icon: secondaryIcon,
                    onTap: onSecondary,
                    isPrimary: false,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DialogActionButton(
                    text: primaryText,
                    icon: primaryIcon,
                    onTap: onPrimary,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? kMainColor : context.cardColor;
    final foreground = isPrimary ? kWhiteColor : context.primaryTextColor;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(11.r),
        onTap: onTap,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: isPrimary ? kMainColor : context.dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: foreground),
              SizedBox(width: 7.w),
              Flexible(
                child: AppText(
                  text: text,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _completedStops(ShipmentEntity shipment) {
  return shipment.shipmentStops
          ?.where((stop) => stop.isReached == true)
          .length ??
      0;
}
