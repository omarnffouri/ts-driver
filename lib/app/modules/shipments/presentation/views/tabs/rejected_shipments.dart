import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';

import '../../controllers/shipments_controller.dart';
import 'shipment_tab_view.dart';

class RejectedShipments extends GetView<ShipmentsController> {
  const RejectedShipments({super.key});

  @override
  Widget build(BuildContext context) {
    return PagedShipmentTab(
      tab: controller.rejectedTab,
      action: 'rejected',
      tripType: TripType.rejected,
      title: 'Rejected Trips',
      emptyMessage: 'No Rejected Trips',
    );
  }
}
