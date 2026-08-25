import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../../../theme/app_colors.dart';
import '../../../shipments/domain/entities/shipment_entity.dart';
import 'map_formatters.dart';

/// Floating top row over the map: back button, trip status capsule, recenter.
class MapTopBar extends StatelessWidget {
  const MapTopBar({
    super.key,
    required this.shipment,
    required this.onBack,
    required this.onCenterMap,
  });

  final ShipmentEntity shipment;
  final VoidCallback onBack;
  final VoidCallback onCenterMap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MapActionButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onBack,
        ),
        SizedBox(width: 10.w),
        Expanded(child: TripStatusCapsule(shipment: shipment)),
        SizedBox(width: 10.w),
        MapActionButton(
          icon: Icons.my_location_rounded,
          iconColor: kMainColor,
          onPressed: onCenterMap,
        ),
      ],
    );
  }
}

class MapActionButton extends StatelessWidget {
  const MapActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(12.r),
      elevation: context.isDark ? 0 : 8,
      shadowColor: const Color(0x333E4958),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onPressed,
        child: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.dividerColor),
          ),
          child: Icon(
            icon,
            color: iconColor ?? context.primaryTextColor,
            size: 21.r,
          ),
        ),
      ),
    );
  }
}

class TripStatusCapsule extends StatelessWidget {
  const TripStatusCapsule({super.key, required this.shipment});

  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.r,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 26.r,
            height: 26.r,
            decoration: BoxDecoration(
              color: AppColors.warning.applyOpacity(
                context.statusTintAlpha(isTransit: true),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.route_rounded,
              color: context.warningTextColor,
              size: 16.r,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'In transit',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: context.warningTextColor,
                  ),
                ),
                AppText(
                  text: valueOrFallback(shipment.shipmentNumber, 'Active trip'),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: context.secondaryTextColor,
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
