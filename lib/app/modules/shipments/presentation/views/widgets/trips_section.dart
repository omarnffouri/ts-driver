import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../domain/entities/shipment_entity.dart';
import 'shipment_item.dart';

class TripsSection extends StatelessWidget {
  const TripsSection({
    super.key,
    required this.shipments,
    required this.tripType,
    required this.title,
  });

  final List<ShipmentEntity> shipments;
  final TripType tripType;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 6.h),
            child: Row(
              children: [
                Container(
                  width: 3.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: tripType.accentColor(context),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                addHorizontalSpace(8.w),
                AppText(
                  text: title.toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                    color: context.secondaryTextColor,
                  ),
                ),
                addHorizontalSpace(8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: context.dividerColor
                        .applyOpacity(context.isDark ? 1 : .6),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: AppText(
                    text: "${shipments.length}",
                    size: 11,
                    weight: FontWeight.w700,
                    color: context.secondaryTextColor,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          ListView.separated(
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shipments.length,
            itemBuilder: (ctx, index) {
              return ShipmentItem(
                tripType: tripType,
                shipment: shipments[index],
              );
            },
            separatorBuilder: (ctx, index) => SizedBox(height: 8.h),
          ),
        ],
      ),
    );
  }
}
