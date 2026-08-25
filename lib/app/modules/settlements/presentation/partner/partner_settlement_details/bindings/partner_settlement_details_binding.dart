import 'package:get/get.dart';

import '../controllers/partner_settlement_details_controller.dart';

class PartnerSettlementDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PartnerSettlementDetailsController>(
      PartnerSettlementDetailsController(),
    );
  }
}
