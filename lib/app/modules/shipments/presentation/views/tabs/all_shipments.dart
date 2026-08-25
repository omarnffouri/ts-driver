import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';

import '../../controllers/shipments_controller.dart';
import 'shipment_tab_view.dart';

class AllShipments extends GetView<ShipmentsController> {
  const AllShipments({super.key});

  @override
  Widget build(BuildContext context) {
    return ShipmentTabView(
      scrollController: controller.activeScrollController,
      refreshController: controller.activeRefreshController,
      onRefresh: () => controller.fetchActiveLoads(),
      isLoading: (ctrl) => ctrl.isLoadingActive.value,
      isPaginating: (_) => false,
      isEmptyCheck: (ctrl) => ctrl.isNewShipmentsEmpty,
      loadingTitle: 'New Load Offering',
      emptyMessage: "No Shipments",
      physics: const ClampingScrollPhysics(),
      sections: [
        ShipmentSection(
          title: "BOL Rejected",
          getShipments: (ctrl) => ctrl.bolRejected,
          tripType: TripType.bolRejected,
        ),
        ShipmentSection(
          title: "New Load Offering",
          getShipments: (ctrl) => ctrl.assigned,
          tripType: TripType.assigned,
        ),
        ShipmentSection(
          title: "Waiting",
          getShipments: (ctrl) => ctrl.waiting,
          tripType: TripType.waiting,
        ),
        ShipmentSection(
          title: "Current Trip",
          getShipments: (ctrl) => ctrl.transitTrip,
          tripType: TripType.transit,
        ),
      ],
    );
  }
}
