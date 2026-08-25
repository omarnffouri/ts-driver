import 'dart:io';

import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/map_utils.dart';
import 'package:ts_driver/app/modules/map/controllers/location_services.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();
  Future<void> startTrack() async {
    if (Platform.isIOS) {
      IosLocationService.startLocationUpdates();
    } else if (Platform.isAndroid) {
      onStartLocationService();
    }
  }

  Future<void> onStartLocationService() async {
    // check permission
    if (await ispermissionGranted() == false) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: "Please grant location permission",
      );
      return;
    }
    AndroidLocationService.startLocationUpdates();
  }

  Future<void> releaseTracking() async {
    if (Platform.isIOS) {
      await IosLocationService.stopLocationUpdates();
    } else if (Platform.isAndroid) {
      AndroidLocationService.stopLocationUpdates();
    }
  }
}
