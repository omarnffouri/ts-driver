import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';

import '../../controllers/shipments_controller.dart';
import 'shipment_tab_view.dart';

class CompletedShipments extends GetView<ShipmentsController> {
  const CompletedShipments({super.key});

  @override
  Widget build(BuildContext context) {
    return PagedShipmentTab(
      tab: controller.completedTab,
      action: 'completed',
      tripType: TripType.completed,
      title: 'Completed Trips',
      emptyMessage: 'No Completed Trips',
    );
  }
}
