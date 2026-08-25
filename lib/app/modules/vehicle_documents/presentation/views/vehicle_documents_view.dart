import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/vehicle_documents/presentation/views/tabs/trailer_documents_tab.dart';
import 'package:ts_driver/app/modules/vehicle_documents/presentation/views/tabs/truck_documents_tab.dart';

import '../controllers/vehicle_documents_controller.dart';
import 'components/vehical_doc_tabs_head.dart';

class VehicleDocumentsView extends GetView<VehicleDocumentsController> {
  const VehicleDocumentsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: const Column(
          children: [
            VehicleDocTabsHead(),
            DocumentBody(),
          ],
        ),
      ),
    );
  }
}

class DocumentBody extends GetView<VehicleDocumentsController> {
  const DocumentBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep both tabs alive so switching is instant (no rebuild / re-animation)
    // and each tab keeps its scroll + search state.
    return Expanded(
      child: Obx(
        () => IndexedStack(
          index: controller.currentTab.value == VehicalDocsTabs.truck ? 0 : 1,
          children: const [
            TruckDocumentsTab(),
            TrailerDocumentsTab(),
          ],
        ),
      ),
    );
  }
}
