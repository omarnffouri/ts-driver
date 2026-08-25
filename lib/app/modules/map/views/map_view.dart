import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../controllers/map_controller.dart';
import 'buttom_sheets/trip_details_bottom_sheet.dart';
import 'widgets/inspection_prompt_card.dart';
import 'widgets/map_scrim.dart';
import 'widgets/map_style.dart';
import 'widgets/map_top_controls.dart';
import 'widgets/trip_overview_card.dart';

class MapView extends GetView<MapController> {
  const MapView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    debugPrint("Map View");
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Obx(
          () {
            final shipment = controller.currentShipment.value;
            final topInset = MediaQuery.of(context).padding.top;
            final isInspectionPending =
                shipment.isPreTripInspectionDone == false;

            return Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    onMapCreated: controller.onMapCreated,
                    markers: controller.markers,
                    polylines: controller.polylines.toSet(),
                    style: context.isDark ? mapDarkStyle : null,
                    initialCameraPosition: controller.initialCameraPosition,
                  ),
                ),
                const MapScrim(alignment: Alignment.topCenter),
                const MapScrim(alignment: Alignment.bottomCenter),
                Positioned(
                  top: topInset + 12.h,
                  left: 14.w,
                  right: 14.w,
                  child: FadeInDown(
                    child: MapTopBar(
                      shipment: shipment,
                      onBack: () => Navigator.of(context).pop(),
                      onCenterMap: controller.goToMyLocation,
                    ),
                  ),
                ),
                if (isInspectionPending)
                  Positioned(
                    top: topInset + 74.h,
                    left: 14.w,
                    right: 14.w,
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 90),
                      child: InspectionPromptCard(
                        onPressed: controller.handlingInspection,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8.h,
                  left: 14.w,
                  right: 14.w,
                  child: FadeInUp(
                    child: TripOverviewCard(
                      shipment: shipment,
                      onTap: showTripDetails,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> showTripDetails() async {
  await showAppBottomSheet(
    constraints: BoxConstraints(
      maxHeight: Get.height * 0.78,
      minHeight: Get.height * 0.34,
    ),
    child: const TripDetailsBottomSheet(),
  );
}
