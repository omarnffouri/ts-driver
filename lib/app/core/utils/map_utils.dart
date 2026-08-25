// ignore_for_file: always_specify_types

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';/
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

import '../../theme/app_colors.dart';

// final Location location = Location();

Future<LatLng?> getCurrentLocation() async {
  LatLng? currentLocation;
  try {
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentLocation = LatLng(position.latitude, position.longitude);
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      debugPrint('Permission denied');
    }
    currentLocation = null;
  }
  return currentLocation;
}

// ignore: depend_on_referenced_packages

// distance in KM
// double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//   const double p = 0.017453292519943295;
//   final double a = 0.5 -
//       cos((lat2 - lat1) * p) / 2 +
//       cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//   double distance = 12742 * asin(sqrt(a));
//   String type = "KM".tr;
//   if (distance < 1) {
//     distance = distance * 1000;
//     type = "M".tr;
//   }
//   return distance;
// }

class CustomLatLng {
  CustomLatLng(this.latitude, this.longitude);

  final double? latitude;
  final double? longitude;
  double? distance = 0;
  LatLng get latLng => LatLng(latitude!, longitude!);
}

Future<bool> ispermissionGranted() async {
  bool serviceEnabled;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await Geolocator.openLocationSettings();
    if (!serviceEnabled) {
      return false;
    }
  }
  bool hasPermission = await requestLocationPermission();
  if (hasPermission) {
    debugPrint('permission granted hasPermission >> true');
    return true;
  }
  debugPrint('permission granted hasPermission >> false');
  return false;
}

//! todo : add permission and fix this
Future<bool> requestLocationPermission() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('permission denied');
      return false;
    } else if (permission == LocationPermission.deniedForever) {
      debugPrint('permission denied forever');
      return false;
    } else {
      debugPrint('permission granted');
      return true;
    }
  }
  debugPrint('permission granted');
  return true;
}

Future<BitmapDescriptor> getMarkerBitmap(int size, {String? text}) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint1 = Paint()..color = kMainColor;
  final Paint paint2 = Paint()..color = Colors.white;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

  if (text != null) {
    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size / 3,
        color: Colors.white,
        fontWeight: FontWeight.normal,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );
  }

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  // ignore: deprecated_member_use
  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  // assert(list.isNotEmpty);
  double? x0;
  double? x1;
  double? y0;
  double? y1;
  for (final LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1!) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1!) y1 = latLng.longitude;
      if (latLng.longitude < y0!) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}
