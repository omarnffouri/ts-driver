import 'package:get/get.dart';

import '../controller/truck_inspection_controller.dart';

class TruckInspectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TruckInspectionController>(
      () => TruckInspectionController(),
    );
  }
}
