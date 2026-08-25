import 'package:get/get.dart';

import '../controllers/partner_settlements_controller.dart';

class PartnerSettlementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PartnerSettlementsController>(
      PartnerSettlementsController(),
    );
  }
}
