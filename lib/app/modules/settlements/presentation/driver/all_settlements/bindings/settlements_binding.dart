import 'package:get/get.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';

class SettlementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettlementsController>(
      () => SettlementsController(),
    );
  }
}
