import 'package:get/get.dart';

import '../controllers/settlement_details_controller.dart';

class SettlementDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettlementDetailsController>(
      () => SettlementDetailsController(),
    );
  }
}
