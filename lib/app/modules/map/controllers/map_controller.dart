// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/map/controllers/location_services.dart';
import 'package:ts_driver/app/modules/shipments/domain/usecases/update_stop_status_usecase.dart';
import 'package:ts_driver/app/modules/shipments/presentation/controllers/shipments_controller.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/utils/map_utils.dart';
import '../../../core/services/injection_service.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../shipments/domain/entities/shipment_entity.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class MapController extends GetxController {
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<Position>? locationSubscription;
  AndroidLocationService androidLocationService = AndroidLocationService();

  final updateStopStatusUsecase = sl<UpdateStopStatusUsecase>();
  final currentShipment = ShipmentEntity().obs;

  // rx marker
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  final rediectToInspection = false.obs;

  /// Initial map framing: center on the shipment's first known coordinate
  /// (pickup → stops → dropoff) so the screen opens on the trip area instead of
  /// a hardcoded city. The camera animates to the driver once the map is ready.
  CameraPosition get initialCameraPosition => CameraPosition(
        target: _shipmentAnchor() ?? const LatLng(25.2048, 55.2708),
        zoom: 13,
      );

  LatLng? _shipmentAnchor() {
    final fromStart =
        _latLngFrom(currentShipment.value.startLocation?.location);
    if (fromStart != null) return fromStart;
    final stops = currentShipment.value.shipmentStops;
    if (stops != null) {
      for (final stop in stops) {
        final point = _latLngFrom(stop.location);
        if (point != null) return point;
      }
    }
    return _latLngFrom(currentShipment.value.endLocation?.location);
  }

  LatLng? _latLngFrom(dynamic location) {
    final lat = double.tryParse('${location?.latitude ?? ''}');
    final lng = double.tryParse('${location?.longitude ?? ''}');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  // on init
  @override
  void onInit() {
    super.onInit();

    final arge = Get.arguments;
    final shipment = arge['shipment'] as ShipmentEntity?;
    final redirect = arge['redirect'] as bool?;

    if (shipment != null) {
      currentShipment.value = shipment;
    }
    if (redirect != null) {
      rediectToInspection.value = redirect;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (rediectToInspection.value) {
      handlingInspection();
    }
  }

  void updateStopState(MapBody body) async {
    final r = await updateStopStatusUsecase(body);

    r.fold(
      (l) => debugPrint("stop status updated"),
      (r) => debugPrint(r.toString()),
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
    // No fixed delay: camera moves are gated on mapController.future (completed
    // just above), and goToMyLocation/tracking await the GPS fix themselves.
    goToMyLocation();
    addMarkers();
    trackingDriverMovment();
  }

  Future<void> goToMyLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    try {
      final locationData = await Geolocator.getCurrentPosition();
      final target = LatLng(locationData.latitude, locationData.longitude);
      mapController.future.then(
        (value) => value.animateCamera(CameraUpdate.newLatLngZoom(target, 13)),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Function to get the current location and move the camera
  Future<void> trackingDriverMovment() async {
    locationSubscription =
        Geolocator.getPositionStream().listen((Position location) async {
      mapController.future.then(
        (value) => value.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 13,
            ),
          ),
        ),
      );
      checkStopReaching(LatLng(location.latitude, location.longitude));
    });
  }

  checkStopReaching(LatLng myLocation) async {
    final stops = currentShipment.value.shipmentStops;
    if (stops == null) return;
    final driver = PointLatLng(myLocation.latitude, myLocation.longitude);
    for (final stop in stops) {
      if (stop.isReached == true) continue;
      final location = stop.location;
      if (location?.latitude == null || location?.longitude == null) continue;
      final point = PointLatLng(
        double.parse(location!.latitude!),
        double.parse(location.longitude!),
      );
      final distance = Geolocator.distanceBetween(
        driver.latitude,
        driver.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < 1000) {
        final matches =
            markers.where((m) => m.markerId == MarkerId(stop.id.toString()));
        if (matches.isEmpty) continue;
        final target = matches.first;
        markers.remove(target);
        markers.add(
          target.copyWith(
            iconParam: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );

        // update the stop status
        updateStopState({"stop_id": stop.id.toString()});
        stop.isReached = true;
        currentShipment.refresh();
      }
    }
  }

  Future<void> addMarkers() async {
    markers.clear();

    final start = currentShipment.value.startLocation?.location;
    if (start?.latitude != null && start?.longitude != null) {
      addPickupMarker(
        LatLng(double.parse(start!.latitude!), double.parse(start.longitude!)),
      );
    }

    final end = currentShipment.value.endLocation?.location;
    if (end?.latitude != null && end?.longitude != null) {
      addDropoffMarker(
        LatLng(double.parse(end!.latitude!), double.parse(end.longitude!)),
      );
    }

    addShipmentStopsMarkers();
    addPolyLine(currentShipment.value.originalPolyline ?? '');
    addDriverToPickupPolyline();
  }

  // Function to add a marker for pickup location
  Future<void> addPickupMarker(LatLng position) async {
    final Uint8List customMarker = await getBytesFromAsset(
        path: Assets.images.pickMarker.path, //paste the custom image path
        width: 30 // size of custom image as marker
        );
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: position,
        icon: BitmapDescriptor.fromBytes(customMarker),
      ),
    );
  }

// Function to add a marker for drop-off location
  Future<void> addDropoffMarker(LatLng position) async {
    final Uint8List customMarker = await getBytesFromAsset(
        path: Assets.images.dropMarker.path, //paste the custom image path
        width: 30 // size of custom image as marker
        );
    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: position,
        icon: BitmapDescriptor.fromBytes(customMarker),
      ),
    );
  }

  // add shipment stops markers
  Future<void> addShipmentStopsMarkers() async {
    final stops = currentShipment.value.shipmentStops;
    if (stops == null) return;
    for (final item in stops) {
      final location = item.location;
      if (item.id == null ||
          location?.latitude == null ||
          location?.longitude == null) {
        continue;
      }
      final stop = LatLng(
        double.parse(location!.latitude!),
        double.parse(location.longitude!),
      );
      markers.add(
        Marker(
          markerId: MarkerId(item.id!.toString()),
          position: stop,
          icon: BitmapDescriptor.defaultMarkerWithHue(item.isReached ?? false
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueViolet),
          onTap: () {
            final target = markers.firstWhere(
                (element) => element.markerId == MarkerId(item.id.toString()));
            markers.remove(target);
            markers.add(
              target.copyWith(
                iconParam: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void addPolyLine(String polyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(polyline);
    // add trip polyline
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: kMainColor,
        patterns: <PatternItem>[PatternItem.dash(30), PatternItem.gap(2)],
        jointType: JointType.round,
        width: 3,
        points: result.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      ),
    );
    polylines.refresh();

    // move camera to bound locations
    // moveCameraToBoundLocations(
    //   result.map((e) => LatLng(e.latitude, e.longitude)).toList(),
    // );
  }

  Future<void> addDriverToPickupPolyline() async {
    final startLocation = currentShipment.value.startLocation?.location;
    if (startLocation?.latitude == null || startLocation?.longitude == null) {
      return;
    }
    try {
      final value = await Geolocator.getCurrentPosition();
      final driver = PointLatLng(value.latitude, value.longitude);
      final pickup = PointLatLng(
        double.parse(startLocation!.latitude!),
        double.parse(startLocation.longitude!),
      );
      final polylinePoints = PolylinePoints();
      final request = PolylineRequest(
          origin: driver, destination: pickup, mode: TravelMode.driving);
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: request,
        googleApiKey: GOOGLE_MAPS_API_KEY,
      );
      // No drivable route (e.g. ZERO_RESULTS when driver and pickup aren't
      // road-connected) — skip the line rather than crash the map.
      if (result.points.isEmpty) return;
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driverToPickup'),
          color: Colors.blue,
          patterns: <PatternItem>[PatternItem.dash(30), PatternItem.gap(2)],
          jointType: JointType.round,
          width: 3,
          points: result.points
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      );
      polylines.refresh();
    } catch (e) {
      debugPrint('addDriverToPickupPolyline skipped: $e');
    }
  }

  Future<void> moveCameraToBoundLocations(List<LatLng> location) async {
    List<LatLng>? locationBnd = <LatLng>[];

    if (location.isEmpty) {
      return;
    }
    for (final item in location) {
      locationBnd.add(item);
    }

    mapController.future.then(
      (value) => value.animateCamera(
        CameraUpdate.newLatLngBounds(boundsFromLatLngList(locationBnd), 80),
      ),
    );
  }

  // pre_trip_inspection
  Future<void> handlingInspection() async {
    final data = await Get.toNamed(Routes.INSPECTION, arguments: {
      "shipment_id": currentShipment.value.id.toString(),
      "driver_id": currentShipment.value.driverId.toString(),
      "trailer_id": currentShipment.value.trailerId.toString(),
    });
    if (data != null && data) {
      currentShipment.value.isPreTripInspectionDone = true;
      currentShipment.refresh();
      // find the shipment in transit list and update it
      if (Get.isRegistered<ShipmentsController>()) {
        final shipmentsCtrl = Get.find<ShipmentsController>();
        final idx = shipmentsCtrl.transitTrip
            .indexWhere((element) => element.id == currentShipment.value.id);
        if (idx != -1) {
          shipmentsCtrl.transitTrip[idx].isPreTripInspectionDone = true;
          shipmentsCtrl.transitTrip.refresh();
        }
      }
    }
    debugPrint("data $data");
  }

  @override
  void onClose() {
    mapController = Completer();
    mapController.future.then((value) => value.dispose());
    super.onClose();
  }
}
