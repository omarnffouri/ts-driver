import 'package:get/get.dart';

import '../controllers/vehicle_documents_controller.dart';

class VehicleDocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<VehicleDocumentsController>(
      VehicleDocumentsController(),
    );
  }
}
