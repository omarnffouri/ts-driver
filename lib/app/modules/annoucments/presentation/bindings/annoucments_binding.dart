import 'package:get/get.dart';

import '../controllers/annoucments_controller.dart';

class AnnoucmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AnnoucmentsController>(AnnoucmentsController());
  }
}
