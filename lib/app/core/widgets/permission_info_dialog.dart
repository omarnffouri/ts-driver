import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class PermissionInfoDialog extends StatelessWidget {
  final Permission permissionCode;
  final String message;
  final PermissionStatus permissionStatus;
  final String openSettingText;
  final Function? onOpenSettingsClick;

  const PermissionInfoDialog(
      {super.key,
      required this.permissionCode,
      required this.message,
      required this.permissionStatus,
      this.openSettingText = "Open App Settings",
      this.onOpenSettingsClick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String permissionName = "Permission";
    String permissionIcon = Assets.images.accessibilityIcon.path;

    switch (permissionCode) {
      case Permission.camera:
        permissionName = "Camera";
        permissionIcon = Assets.images.cameraIcon.path;
        break;

      case Permission.microphone:
        permissionName = "Microphone";
        permissionIcon = Assets.images.micIcon.path;
        break;

      case Permission.location:
        permissionName = "Location";
        permissionIcon = Assets.images.locationIcon.path;
        break;

      case Permission.photos:
        permissionName = "Photos";
        permissionIcon = Assets.images.photosIcon.path;
        break;

      case Permission.storage:
        permissionName = "Storage";
        permissionIcon = Assets.images.foldersIcon.path;
        break;

      case Permission.mediaLibrary:
        permissionName = "Media Library";
        permissionIcon = Assets.images.musicIcon.path;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10,
                top: 40,
              ),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? const Color(0xff82858A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Get.isDarkMode ? Colors.white : Colors.black),
                boxShadow: [
                  BoxShadow(
                    color: Get.isDarkMode ? Colors.black87 : Colors.grey,
                    spreadRadius: 5,
                    blurRadius: 10,
                  )
                ],
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //
                  Text(
                    "$permissionName Permission",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Get.isDarkMode
                          ? Colors.white
                          : AppColorsLight.mainColor,
                    ),
                  ),

                  Text(
                    message,
                    style: theme.textTheme.bodyLarge,
                  ).marginOnly(top: 10),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                    color: AppColorsLight.mainColor,
                                    width: 0.5)),
                            backgroundColor: AppColorsLight.white,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Close",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColorsLight.mainColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            if (onOpenSettingsClick != null) {
                              onOpenSettingsClick!();
                            } else {
                              openAppSettings();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // Adjust the radius as needed
                            ),
                            backgroundColor: AppColorsLight.mainColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              openSettingText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).marginOnly(top: 10),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      )
                    ]),
                child: Image.asset(
                  permissionIcon,
                  width: 30,
                  height: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
