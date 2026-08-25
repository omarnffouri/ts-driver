import 'package:get/get.dart';

import '../controllers/group_conversations_controller.dart';

class GroupConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GroupConversationsController>(GroupConversationsController());
  }
}
