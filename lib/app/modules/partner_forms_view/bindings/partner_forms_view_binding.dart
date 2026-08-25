import 'package:get/get.dart';

import '../controllers/partner_forms_view_controller.dart';

class PartnerFormsViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PartnerFormsViewController>(
      PartnerFormsViewController(),
    );
  }
}
