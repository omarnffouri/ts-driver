import 'package:get/get.dart';
import 'package:ts_driver/app/controllers/location_controller.dart';
import 'package:ts_driver/app/core/enum/access_level.dart';
import 'package:ts_driver/app/modules/chat/presentation/conversations/bindings/conversations_binding.dart';
import 'package:ts_driver/app/modules/partner_forms_view/controllers/partner_forms_view_controller.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';
import 'package:ts_driver/app/modules/shipments/presentation/controllers/shipments_controller.dart';

import '../../home/presentation/controllers/home_controller.dart';
import '../../settlements/presentation/partner/all_partner_settlements/controllers/partner_settlements_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_screen_controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainScreenController>(
      MainScreenController(),
    );

    final accessLevel =
        Get.find<MainScreenController>().authController.accessLevel.value;
    switch (accessLevel) {
      case AccessLevel.partnerOnly:
        Get.lazyPut<PartnerSettlementsController>(
            () => PartnerSettlementsController());
        Get.lazyPut<PartnerFormsViewController>(
            () => PartnerFormsViewController());
        break;
      case AccessLevel.driverOnly:
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<ShipmentsController>(() => ShipmentsController());
        Get.lazyPut<SettlementsController>(() => SettlementsController());
        Get.lazyPut<LocationController>(() => LocationController());
        ConversationsBinding().dependencies();
        break;
      case AccessLevel.both:
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<ShipmentsController>(() => ShipmentsController());
        Get.lazyPut(() => PartnerSettlementsController());
        Get.lazyPut<LocationController>(() => LocationController());
        ConversationsBinding().dependencies();
        break;
      default:
    }
  }
}
