import 'package:get/get.dart';

import '../controllers/profile_add_accident_history_controller.dart';

class ProfileAddAccidentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAddAccidentHistoryController>(
      () => ProfileAddAccidentHistoryController(),
    );
  }
}
