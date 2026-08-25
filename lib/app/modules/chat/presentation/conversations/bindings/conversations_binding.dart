import 'package:get/get.dart';
import 'package:ts_driver/app/modules/chat/presentation/group_conversations/bindings/group_conversations_binding.dart';
import 'package:ts_driver/app/modules/chat/presentation/oto_conversations/bindings/oto_conversations_binding.dart';

import '../controllers/conversations_controller.dart';

class ConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ConversationsController>(ConversationsController());
    OtoConversationsBinding().dependencies();
    GroupConversationsBinding().dependencies();
  }
}
