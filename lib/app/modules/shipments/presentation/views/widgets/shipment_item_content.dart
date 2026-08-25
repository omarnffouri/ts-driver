import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../../controllers/shipments_controller.dart';

/// Collapsed manifest row: bold id + status pill, money (or requested date),
/// a single-line route, and — for actionable states — a hairline divider + CTA.
class ShipmentItemContent extends StatelessWidget {
  const ShipmentItemContent({
    super.key,
    required this.shipment,
    required this.tripType,
  });

  final ShipmentEntity shipment;
  final TripType tripType;

  @override
  Widget build(BuildContext context) {
    final isBol = tripType == TripType.bolRejected;
    final statusColor = tripType.pillTextColor(context, shipment);
    final statusTint =
        context.statusTintAlpha(isTransit: tripType == TripType.transit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StatusIcon(
              icon: tripType.statusIcon(shipment),
              color: statusColor,
              alpha: statusTint,
            ),
            addHorizontalSpace(8.w),
            Expanded(
              child: AppText(
                text: "${shipment.shipmentNumber}",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            addHorizontalSpace(8.w),
            if (isBol)
              _RequestedCaption(shipment: shipment)
            else
              _AmountBlock(shipment: shipment),
          ],
        ),
        addVerticalSpace(6.h),
        AppText(
          text: shipment.routeSummary,
          size: 13,
          weight: FontWeight.w500,
          maxLines: 1,
          color: context.secondaryTextColor,
        ),
        if (tripType.hasActionButton) ...[
          addVerticalSpace(8.h),
          Row(
            children: [
              const Spacer(),
              _ActionSlot(shipment: shipment, tripType: tripType),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.icon,
    required this.color,
    required this.alpha,
  });
  final IconData icon;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.r,
      height: 26.r,
      decoration: BoxDecoration(
        color: color.applyOpacity(alpha),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 16.w, color: color),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.shipment});
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          text: shipment.baseAmount,
          maxLines: 1,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: context.primaryTextColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (shipment.hasExtra)
          AppText(
            text: shipment.extraAmount,
            size: 12,
            weight: FontWeight.w600,
            maxLines: 1,
            color: context.successTextColor,
          ),
      ],
    );
  }
}

class _RequestedCaption extends StatelessWidget {
  const _RequestedCaption({required this.shipment});
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final date = shipment.updatedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          text: "Requested",
          size: 11,
          weight: FontWeight.w400,
          maxLines: 1,
          color: context.hintColor,
        ),
        if (date != null)
          AppText(
            text: DateFormat('yyyy-MM-dd').format(date),
            size: 12,
            weight: FontWeight.w700,
            maxLines: 1,
            color: context.secondaryTextColor,
          ),
      ],
    );
  }
}

/// State-specific CTA. Reuses the controller's in-flight [updatingShipmentId]
/// to swap a spinner inside the button without reflowing the row.
class _ActionSlot extends GetView<ShipmentsController> {
  const _ActionSlot({required this.shipment, required this.tripType});
  final ShipmentEntity shipment;
  final TripType tripType;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.updatingShipmentId.value == shipment.id;
      switch (tripType) {
        case TripType.assigned:
          return _ActionButton(
            label: "Accept / Reject",
            loading: loading,
            color: AppColors.primary,
            foreground: AppColors.onPrimary,
            onTap: () => controller.showConfirmBottomSheet(shipment: shipment),
          );
        case TripType.transit:
          return _ActionButton(
            label: "Continue",
            loading: loading,
            color: tripType.accentColor(context),
            foreground: AppColors.onPrimary,
            onTap: () =>
                Get.toNamed(Routes.MAP, arguments: {"shipment": shipment}),
          );
        case TripType.bolRejected:
          return _ActionButton(
            label: "Upload BOL",
            loading: loading,
            color: AppColors.error,
            foreground: AppColors.onPrimary,
            icon: Icons.upload_file_rounded,
            onTap: () => controller.showUploadBolBottomSheet(
              shipment: shipment,
              isBolRejected: true,
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.loading,
    required this.color,
    required this.foreground,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;
  final Color color; // fill
  final Color foreground; // label / icon
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.w, color: foreground),
                addHorizontalSpace(6.w),
              ],
              AppText(
                text: label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          );

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(10.r),
        splashColor: Colors.white.applyOpacity(.12),
        child: Container(
          constraints: BoxConstraints(minWidth: 84.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
