import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../../../theme/app_colors.dart';
import '../../../shipments/domain/entities/shipment_entity.dart';
import 'map_formatters.dart';

/// Bottom peek card summarizing the active trip (shipment, route, distance/ETA/
/// stop progress) that opens the full trip details sheet on tap.
class TripOverviewCard extends StatelessWidget {
  const TripOverviewCard({
    super.key,
    required this.shipment,
    required this.onTap,
  });

  final ShipmentEntity shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalStops = shipment.shipmentStops?.length ?? 0;
    final completedStops = shipment.shipmentStops
            ?.where((stop) => stop.isReached == true)
            .length ??
        0;

    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(14.r),
      elevation: context.isDark ? 0 : 12,
      shadowColor: const Color(0x333E4958),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: context.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: context.primaryTint,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: kMainColor,
                      size: 19.r,
                    ),
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: valueOrFallback(
                            shipment.shipmentNumber,
                            'Current shipment',
                          ),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: context.primaryTextColor,
                          ),
                        ),
                        AppText(
                          text:
                              'Trailer ${valueOrFallback(shipment.trailerId, 'N/A')}',
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
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: context.hintColor,
                    size: 22.r,
                  ),
                ],
              ),
              SizedBox(height: 9.h),
              RouteSummary(
                pickup: locationLabel(shipment.startLocation, 'Pickup'),
                dropoff: locationLabel(shipment.endLocation, 'Dropoff'),
              ),
              SizedBox(height: 9.h),
              Row(
                children: [
                  Expanded(
                    child: TripMetric(
                      icon: Icons.straighten_rounded,
                      label: 'Distance',
                      value: valueOrFallback(shipment.estimatedDistance, 'N/A'),
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: TripMetric(
                      icon: Icons.schedule_rounded,
                      label: 'ETA',
                      value: valueOrFallback(shipment.estimatedDuration, 'N/A'),
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: TripMetric(
                      icon: Icons.flag_rounded,
                      label: 'Stops',
                      value:
                          totalStops == 0 ? '0' : '$completedStops/$totalStops',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                height: 38.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kMainColor,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: kWhiteColor,
                      size: 17.r,
                    ),
                    SizedBox(width: 7.w),
                    const AppText(
                      text: 'Trip Details',
                      color: kWhiteColor,
                      weight: FontWeight.w800,
                      size: 13,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteSummary extends StatelessWidget {
  const RouteSummary({
    super.key,
    required this.pickup,
    required this.dropoff,
  });

  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: context.inputFillColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          const RoutePoint(color: AppColors.success),
          SizedBox(width: 7.w),
          Expanded(
            child: AppText(
              text: pickup,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: context.hintColor,
              size: 15.r,
            ),
          ),
          const RoutePoint(color: kMainColor),
          SizedBox(width: 7.w),
          Expanded(
            child: AppText(
              text: dropoff,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutePoint extends StatelessWidget {
  const RoutePoint({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.r,
      height: 8.r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class TripMetric extends StatelessWidget {
  const TripMetric({
    super.key,
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
      constraints: BoxConstraints(minHeight: 48.h),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.inputFillColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: context.secondaryTextColor),
          SizedBox(height: 4.h),
          AppText(
            text: value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: context.primaryTextColor,
            ),
          ),
          AppText(
            text: label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: context.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
