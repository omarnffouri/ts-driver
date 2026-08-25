import 'package:get/get.dart';

import '../controllers/signed_forms_controller.dart';

class SignedFormsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SignedFormsController>(SignedFormsController());
  }
}
