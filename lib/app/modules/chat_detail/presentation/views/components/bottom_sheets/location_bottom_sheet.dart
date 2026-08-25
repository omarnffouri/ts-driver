import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/location_picker.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/controllers/chat_detail_controller.dart';

void showLocationBottomSheet(ChatDetailController controller) {
  showAppBottomSheet(
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    showGrabber: true,
    constraints: BoxConstraints(maxHeight: Get.height * .8),
    child: LocationBottomSheetContent(controller: controller),
  );
}

class LocationBottomSheetContent extends StatelessWidget {
  final ChatDetailController controller;
  const LocationBottomSheetContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Share Location",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: context.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close_rounded,
                    color: context.hintColor,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Obx(
              () => Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      controller.locationAddress.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => MapPicker(
                // pass icon widget
                iconWidget: controller.isMapLoading.value
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: AppColors.primary,
                      ),
                //add map picker controller
                mapPickerController: controller.mapPickerController,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: Get.height * 0.50,
                    child: controller.isMapLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            myLocationEnabled: true,
                            zoomControlsEnabled: true,
                            // hide location button
                            myLocationButtonEnabled: true,

                            mapToolbarEnabled: true,
                            mapType: MapType.normal,
                            //  camera position
                            initialCameraPosition: controller.cameraPosition,
                            onMapCreated: (GoogleMapController controller) {
                              // _controller.complete(controller);
                            },
                            onCameraMoveStarted: () {
                              // notify map is moving
                              controller.mapPickerController.mapMoving!();
                              controller.locationAddress.value = "checking ...";
                            },
                            onCameraMove: (cameraPosition) {
                              controller.cameraPosition = cameraPosition;
                            },
                            onCameraIdle: () async {
                              // notify map stopped moving
                              controller
                                  .mapPickerController.mapFinishedMoving!();
                              //get address name from camera position
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                controller.cameraPosition.target.latitude,
                                controller.cameraPosition.target.longitude,
                              );

                              // update the ui with the address
                              controller.locationAddress.value =
                                  '${placemarks.first.name}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';
                            },
                          ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      debugPrint(
                          "Location ${controller.cameraPosition.target.latitude} ${controller.cameraPosition.target.longitude}");
                      debugPrint("Address: $controller.locationAddress");
                      controller.sendLocationMessageNew();
                      Get.back();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.primary),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: Text(
                      "Send",
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
