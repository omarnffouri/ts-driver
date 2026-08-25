import 'package:get/get.dart';

import '../controllers/oto_conversations_controller.dart';

class OtoConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OtoConversationsController>(OtoConversationsController());
  }
}
