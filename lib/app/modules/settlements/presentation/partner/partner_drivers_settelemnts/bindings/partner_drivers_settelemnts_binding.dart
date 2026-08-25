import 'package:get/get.dart';

import '../controllers/partner_drivers_settelemnts_controller.dart';

class PartnerDriversSettelemntsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerDriversSettelemntsController>(
      () => PartnerDriversSettelemntsController(),
    );
  }
}
