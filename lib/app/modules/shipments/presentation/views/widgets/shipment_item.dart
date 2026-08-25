import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';

import '../../controllers/shipments_controller.dart';
import 'shipment_item_content.dart';

class ShipmentItem extends GetView<ShipmentsController> {
  const ShipmentItem({
    super.key,
    required this.tripType,
    required this.shipment,
  });

  final TripType tripType;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tripType.cardBorderColor(context), width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Material(
        color: tripType.cardFill(context),
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => controller.showDetailsBottomSheet(
            shipment: shipment,
            tripType: tripType,
          ),
          child: Opacity(
            opacity: tripType.rowOpacity,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusRail(tripType: tripType, shipment: shipment),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                      child: ShipmentItemContent(
                        shipment: shipment,
                        tripType: tripType,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3px left status rail. Solid for most states; dashed + muted for the archived
/// `rejected` state so it reads apart from `waiting`'s near-invisible rail.
class _StatusRail extends StatelessWidget {
  const _StatusRail({required this.tripType, required this.shipment});
  final TripType tripType;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final color = tripType.railColor(context, shipment);
    if (tripType.railDashed) {
      return SizedBox(
        width: 3.w,
        child: CustomPaint(
          painter: _DashedRailPainter(color: color),
        ),
      );
    }
    return Container(width: 3.w, color: color);
  }
}

/// Paints a vertical dashed rail filling the height it's given — unlike a
/// `double.infinity` [DottedLine], this has no intrinsic height, so it lays out
/// cleanly inside the card's [IntrinsicHeight] row.
class _DashedRailPainter extends CustomPainter {
  const _DashedRailPainter({required this.color});
  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    for (double y = 0; y < size.height; y += _dash + _gap) {
      final end = (y + _dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRailPainter oldDelegate) =>
      oldDelegate.color != color;
}
