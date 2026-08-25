import 'package:ts_driver/app/modules/shipments/domain/entities/shipment_entity.dart';

// ignore: must_be_immutable
class ShipmentModel extends ShipmentEntity {
  ShipmentModel({
    super.id,
    super.trailerId,
    super.driverId,
    super.shipmentNumber,
    super.createdAt,
    super.updatedAt,
    super.totalDrivers,
    super.totalAmount,
    super.additionalAmount,
    super.driverStatus,
    super.startLocation,
    super.endLocation,
    super.shipmentStops,
    super.originalPolyline,
    super.driverInstruction,
    super.estimatedDuration,
    super.estimatedDistance,
    super.isPreTripInspectionDone,
    super.isPostTripInspectionDone,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) => ShipmentModel(
      id: json["id"],
      trailerId: json["trailer_id"].toString(),
      driverId: json["driver_id"].toString(),
      shipmentNumber: json["shipment_number"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      totalDrivers: json["total_drivers"],
      totalAmount: json["total_amount"],
      additionalAmount: json["additional_amount"],
      driverStatus: json["driver_status"],
      startLocation: json["start_location"] == null
          ? null
          : Loc.fromJson(json["start_location"]),
      endLocation: json["end_location"] == null
          ? null
          : Loc.fromJson(json["end_location"]),
      shipmentStops: json["shipmentStops"] == null
          ? []
          : List<Loc>.from(json["shipmentStops"]!.map((x) => Loc.fromJson(x))),
      originalPolyline: json["original_polyline"],
      driverInstruction: json["driver_instruction"],
      estimatedDuration: json["estimated_duration"].toString(),
      estimatedDistance: json["get_total_miles"].toString(),
      isPreTripInspectionDone: json["pre_inspection"] == 1 ? true : false,
      isPostTripInspectionDone: json["post_inspection"] == 1 ? true : false);
}

// ignore: must_be_immutable
class Loc extends LocEntity {
  Loc({
    super.id,
    super.stopType,
    super.contactDetails,
    super.goods,
    super.weight,
    super.info,
    super.locationId,
    super.transitDateTime,
    super.location,
    super.isReached,
  });

  factory Loc.fromJson(Map<String, dynamic> json) => Loc(
        id: json["id"],
        stopType: json["stop_type"],
        contactDetails: json["contact_details"],
        goods: json["goods"],
        weight: json["weight"],
        info: json["info"],
        locationId: json["location_id"],
        transitDateTime: json["transit_date_time"] == null
            ? null
            : DateTime.parse(json["transit_date_time"]),
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        isReached: json["is_reached"] == 1 ? true : false,
      );
}

class Location extends LocationEntity {
  const Location({
    super.id,
    super.latitude,
    super.longitude,
    super.address,
    super.companyName,
    super.stateName,
    super.city,
    super.zipcode,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        companyName: json["company_name"],
        stateName: json["state_name"],
        city: json["city"],
        zipcode: json["zipcode"],
      );
}
