import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/widgets/permission_info_dialog.dart';

class PermissionHelper {
  static Future<bool> haveCameraPermission(String message) async {
    final status = await permission_handler.Permission.camera.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.camera, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> haveMicPermission(String message) async {
    final status = await permission_handler.Permission.microphone.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.microphone, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> haveLocationPermission(String message) async {
    // checking location service aviablity
    final serviceEnabled = Platform.isIOS
        ? await Geolocator.isLocationServiceEnabled()
        : await permission_handler
            .Permission.locationWhenInUse.serviceStatus.isEnabled;

    if (!serviceEnabled) {
      await _showPermissionInfoDialog(
          permission_handler.Permission.location,
          "Location is disabled, Please enable location service from the settings to proceed furhter.",
          permission_handler.PermissionStatus.denied,
          openSettingText: "Location Settings", onOpenSettingsClick: () async {
        await Geolocator.openLocationSettings();
      });
      return false;
    }

    // checking for location permission in ios using geo locator package
    if (Platform.isIOS) {
      final locationStatus = await Geolocator.requestPermission();
      switch (locationStatus) {
        case LocationPermission.denied:
        case LocationPermission.deniedForever:
        case LocationPermission.unableToDetermine:
          await _showPermissionInfoDialog(
              permission_handler.Permission.location,
              message,
              permission_handler.PermissionStatus.denied);
          return false;

        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return true;
      }
    }

    // else checking location permission on android using permission handler package
    final status = await permission_handler.Permission.location.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.location, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> havePhotosPermission(String message) async {
    final status = await permission_handler.Permission.photos.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.photos, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> haveStoragePermission(String message) async {
    final status = await permission_handler.Permission.storage.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.storage, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> haveAppleMusicPermission(String message) async {
    final status = await permission_handler.Permission.mediaLibrary.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return true;

      case permission_handler.PermissionStatus.denied:
      case permission_handler.PermissionStatus.permanentlyDenied:
      case permission_handler.PermissionStatus.restricted:
        await _showPermissionInfoDialog(
            permission_handler.Permission.mediaLibrary, message, status);
        break;

      case permission_handler.PermissionStatus.limited:
        return true;

      case permission_handler.PermissionStatus.provisional:
        break;
    }

    return false;
  }

  static Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }

  static _showPermissionInfoDialog(permission_handler.Permission permission,
      String message, permission_handler.PermissionStatus permissionStatus,
      {String openSettingText = "Open App Settings",
      Function? onOpenSettingsClick}) async {
    // await Get.dialog(
    // PermissionInfoDialog(
    //   permissionCode: permissionCode,
    //   message: message,
    //   permissionStatus: permissionStatus,
    // ),
    // );

    await showGeneralDialog(
      barrierColor: Colors.black.applyOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 500, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: PermissionInfoDialog(
              permissionCode: permission,
              message: message,
              permissionStatus: permissionStatus,
              openSettingText: openSettingText,
              onOpenSettingsClick: onOpenSettingsClick,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: true,
      barrierLabel: '',
      context: Get.context!,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }
}
