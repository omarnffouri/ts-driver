import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/data/connection/api_constants.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';

final firestore = FirebaseFirestore.instance;

class AndroidLocationService {
  static const MethodChannel _channel = MethodChannel('tracking_service');

  static Future<bool> startLocationUpdates() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLocationUpdate') {
        final argument = call.arguments;
        onLocationUpdate(argument);
      }
    });

    try {
      await _channel.invokeMethod('startLocationUpdates');
      return true;
    } catch (e) {
      debugPrint('Error starting location updates: $e');
      return false;
    }
  }

  static Future<void> stopLocationUpdates() async {
    final storage = CommonVariables.tracking;
    var isShipmentRunning = storage.read(
      isShipmentServiceRunning,
    );
    var isClockRunning = storage.read(
      isClockServiceRunning,
    );

    if ((isShipmentRunning != null && isShipmentRunning == false) &&
        (isClockRunning != null && isClockRunning == false)) {
      await _channel.invokeMethod('stopLocationUpdates');
    }
  }

  static void onLocationUpdate(dynamic locationData) {
    final storage = CommonVariables.tracking;
    var isShipmentRunning = storage.read(isShipmentServiceRunning);
    // var isClockRunning = storage.read(isClockServiceRunning);

    final dataToSend = {
      "latitude": locationData["latitude"].toString(),
      "longitude": locationData["longitude"].toString(),
      "heading": locationData["heading"].toString(),
      "speed": locationData["speed"].toString(),
    };

    debugPrint(">>>>> trackingCallback called <<<<<<");
    debugPrint(">>>>> locationData $dataToSend");
    if (isShipmentRunning != null && isShipmentRunning == true) {
      // send sendShipmentLocation to server
      sendShipmentLocation(dataToSend);
    }
    // if (isClockRunning != null && isClockRunning == true) {
    //   // send sendClockLocation to server
    //   sendClockLocation(dataToSend);
    // }
  }
} // end of AndroidLocationService

class IosLocationService {
  static const String startLocationService = "startLocationService";
  static const String stopLocationService = "stopLocationService";
  static const String isServiceRunning = "isServiceRunning";
  static const String hasLocationAlwaysPermission =
      "hasLocationAlwaysPermission";
  static const String requestForAlwaysLocationPermission =
      "requestForAlwaysLocationPermission";

  static const MethodChannel _channel = MethodChannel('locationServiceChannel');
  //
  //
  static Future<bool> startLocationUpdates() async {
    // setting a method callback handler
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLocationUpdate') {
        final argument = call.arguments;
        // Perform the desired action with the argument
        onLocationUpdate(argument);
      }
    });

    try {
      await _channel.invokeMethod(IosLocationService.startLocationService);
      return true; // Successfully invoked the method
    } catch (e) {
      debugPrint('Error starting location updates: $e');
      return false; // There was an error invoking the method
    }
  }

  static Future<void> stopLocationUpdates() async {
    final storage = CommonVariables.tracking;
    var isShipmentRunning = storage.read(
      isShipmentServiceRunning,
    );
    var isClockRunning = storage.read(
      isClockServiceRunning,
    );

    if ((isShipmentRunning != null && isShipmentRunning == false) &&
        (isClockRunning != null && isClockRunning == false)) {
      await _channel.invokeMethod(IosLocationService.stopLocationService);
    }
  }

  static void onLocationUpdate(dynamic locationData) {
    final storage = CommonVariables.tracking;
    var isShipmentRunning = storage.read(isShipmentServiceRunning);
    // var isClockRunning = storage.read(isClockServiceRunning);

    final dataToSend = {
      "latitude": locationData["latitude"].toString(),
      "longitude": locationData["longitude"].toString(),
      "heading": locationData["heading"].toString(),
      "speed": locationData["speed"].toString(),
    };

    debugPrint(">>>>> trackingCallback called <<<<<<");
    debugPrint(">>>>> locationData $dataToSend");
    if (isShipmentRunning != null && isShipmentRunning == true) {
      // send sendShipmentLocation to server
      sendShipmentLocation(dataToSend);
    }
    // if (isClockRunning != null && isClockRunning == true) {
    //   // send sendClockLocation to server
    //   sendClockLocation(dataToSend);
    // }
  }
} // end of IosLocationService

void sendShipmentLocation(MapBody body) async {
  final user = Get.put<AuthController>(AuthController()).user.value;
  final ShipmentEntity currentShipment = ShipmentEntity.fromEntity(
      jsonDecode(CommonVariables.tracking.read(currentTransit)));
  if (currentShipment.id == null) {
    return;
  }

  String timestampId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
  List<Placemark> placemarks = await placemarkFromCoordinates(
    double.parse(body["latitude"].toString()),
    double.parse(body["longitude"].toString()),
  );
  final String shipmentNumber = currentShipment.shipmentNumber.toString();
  final rootCollection = ApiConstants.isProduction
      ? "shipment_tracking"
      : "shipment_tracking_staging";
  final locationRef = firestore
      .collection(rootCollection)
      .doc("current_location")
      .collection(shipmentNumber);
  final logsRef = firestore
      .collection(rootCollection)
      .doc("location_logs")
      .collection(shipmentNumber);

  final shipmentBody = {
    "shipment_number": shipmentNumber,
    "name": "${user.personalDetails!.firstName}",
    "shipment_id": currentShipment.id.toString(),
    "driver_id": "${user.personalDetails?.applicantId}",
    "latitude": body["latitude"].toString(),
    "longitude": body["longitude"].toString(),
    "heading": body["heading"].toString(),
    "speed": body["speed"].toString(),
    "address":
        "${placemarks[0].street}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}",
    "timestamp": timestampId,
  };

  final docSnapshot = await locationRef.get();
  try {
    if (docSnapshot.docs.isNotEmpty) {
      final DocumentSnapshot firstDocument = docSnapshot.docs[0];
      // Document exists, update its data
      await locationRef.doc(firstDocument.id).update(shipmentBody);
    } else {
      await locationRef.doc().set(shipmentBody);
    }
    await logsRef.doc(timestampId).set(shipmentBody);
  } catch (error) {
    debugPrint(error.toString());
  }
}

// void sendClockLocation(MapBody body) async {
//   final user = Get.put<AuthController>(AuthController()).user.value;
//   final collectionUUID = await CommonVariables.tracking.read(uuId);

//   final String userId = user.personalDetails!.userId.toString();
//   final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   debugPrint(">>>>> today $today");

//   final clockBody = {
//     "user_id": userId,
//     "timestamp": {".sv": "timestamp"},
//     "name": "${user.personalDetails!.firstName}",
//     "lat": num.parse(body["latitude"].toString()),
//     "lng": num.parse(body["longitude"].toString()),
//   };

//   final rootLogs = ApiConstants.isStagingServer
//       ? "user_tracking_logs_Staging"
//       : "user_tracking_logs";
//   final rootLive = ApiConstants.isStagingServer
//       ? "user_tracking_live_Staging"
//       : "user_tracking_live";

//   final logsRef = FirebaseDatabase.instance
//       .ref()
//       .child(rootLogs)
//       .child(today)
//       .child(userId)
//       .child(collectionUUID);

//   final liveRef = FirebaseDatabase.instance
//       .ref()
//       .child(rootLive)
//       .child(today)
//       .child(userId);

//   final snapshot = await liveRef.get();

//   try {
//     if (snapshot.exists && snapshot.value is Map) {
//       final data = Map<String, dynamic>.from(snapshot.value as Map);
//       String firstKey = data.keys.first;
//       // Document exists, update its data
//       if (firstKey == collectionUUID) {
//         await liveRef.child(collectionUUID).update(clockBody);
//       } else {
//         // Document exists, but with old collection, remove and create new
//         await liveRef.remove();
//         await liveRef.child(collectionUUID).set(clockBody);
//       }
//     } else {
//       // If the document does not exist, create it
//       await liveRef.child(collectionUUID).set(clockBody);
//     }
//     await logsRef.push().set(clockBody);
//   } catch (error) {
//     debugPrint(error.toString());
//   }
// }
