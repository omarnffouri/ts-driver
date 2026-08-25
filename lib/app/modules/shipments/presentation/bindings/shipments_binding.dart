import 'package:get/get.dart';

import '../controllers/shipments_controller.dart';

class ShipmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ShipmentsController>(ShipmentsController());
  }
}
