import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ShipmentEntity extends Equatable {
  final int? id;
  final String? trailerId;
  final String? driverId;
  final String? shipmentNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? totalDrivers;
  final num? totalAmount;
  final num? additionalAmount;
  final String? driverStatus;
  final LocEntity? startLocation;
  final LocEntity? endLocation;
  final List<LocEntity>? shipmentStops;
  final String? originalPolyline;
  final String? driverInstruction;
  final String? estimatedDuration;
  final String? estimatedDistance;
  bool? isPreTripInspectionDone;
  bool? isPostTripInspectionDone;

  static final NumberFormat _money =
      NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  /// Total amount formatted as currency, with the optional additional amount
  /// appended (e.g. `$2,300` or `$2,300 + $150`).
  String get formattedAmount => hasExtra
      ? '$baseAmount + ${_money.format(additionalAmount)}'
      : baseAmount;

  /// Base total as currency, no additional amount (e.g. `$2,300`).
  String get baseAmount => _money.format(totalAmount ?? 0);

  /// Whether an additional amount rides on top of the base total.
  bool get hasExtra => (additionalAmount ?? 0) > 0;

  /// Additional amount as a `+ $X` bonus (empty-safe).
  String get extraAmount => '+ ${_money.format(additionalAmount ?? 0)}';

  /// Single-line `City, ST → City, ST` lane summary, null-safe with em-dash
  /// fallbacks for missing legs.
  String get routeSummary {
    String? leg(LocEntity? l) {
      final city = l?.location?.city;
      final state = l?.location?.stateName;
      final hasCity = city != null && city.isNotEmpty;
      final hasState = state != null && state.isNotEmpty;
      if (!hasCity && !hasState) return null;
      if (!hasState) return city;
      if (!hasCity) return state;
      return '$city, $state';
    }

    return '${leg(startLocation) ?? '—'} → ${leg(endLocation) ?? '—'}';
  }

  ShipmentEntity({
    this.id,
    this.trailerId,
    this.driverId,
    this.shipmentNumber,
    this.createdAt,
    this.updatedAt,
    this.totalDrivers,
    this.totalAmount,
    this.additionalAmount,
    this.driverStatus,
    this.startLocation,
    this.endLocation,
    this.shipmentStops,
    this.originalPolyline,
    this.driverInstruction,
    this.estimatedDuration,
    this.estimatedDistance,
    this.isPreTripInspectionDone,
    this.isPostTripInspectionDone,
  });

  factory ShipmentEntity.fromEntity(Map<String, dynamic> json) =>
      ShipmentEntity(
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
            : LocEntity.fromEntity(json["start_location"]),
        endLocation: json["end_location"] == null
            ? null
            : LocEntity.fromEntity(json["end_location"]),
        shipmentStops: json["shipmentStops"] == null
            ? []
            : List<LocEntity>.from(
                json["shipmentStops"]!.map((x) => LocEntity.fromEntity(x))),
        originalPolyline: json["original_polyline"],
        driverInstruction: json["driver_instruction"],
        estimatedDuration: json["estimated_duration"],
        estimatedDistance: json["get_total_miles"],
        isPreTripInspectionDone: json["pre_inspection"] == 1 ? true : false,
        isPostTripInspectionDone: json["post_inspection"] == 1 ? true : false,
      );

  Map<String, dynamic> toEntity() => {
        "id": id,
        "trailer_id": trailerId,
        "driver_id": driverId,
        "shipment_number": shipmentNumber,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "total_drivers": totalDrivers,
        "total_amount": totalAmount,
        "additional_amount": additionalAmount,
        "driver_status": driverStatus,
        "start_location": startLocation?.toEntity(),
        "end_location": endLocation?.toEntity(),
        "shipmentStops": shipmentStops?.map((x) => x.toEntity()).toList(),
        "original_polyline": originalPolyline,
        "driver_instruction": driverInstruction,
        "estimated_duration": estimatedDuration,
        "get_total_miles": estimatedDistance,
        "pre_inspection": isPreTripInspectionDone == true ? 1 : 0,
        "post_inspection": isPostTripInspectionDone == true ? 1 : 0,
      };

  @override
  List<Object?> get props => [
        id,
        trailerId,
        driverId,
        shipmentNumber,
        createdAt,
        updatedAt,
        totalDrivers,
        totalAmount,
        additionalAmount,
        driverStatus,
        startLocation,
        endLocation,
        shipmentStops,
        originalPolyline,
        driverInstruction,
        estimatedDuration,
        estimatedDistance,
        isPreTripInspectionDone,
        isPostTripInspectionDone,
      ];
}

// ignore: must_be_immutable
class LocEntity extends Equatable {
  final int? id;
  final String? stopType;
  final String? contactDetails;
  final String? goods;
  final String? weight;
  final String? info;
  final int? locationId;
  final DateTime? transitDateTime;
  final LocationEntity? location;
  bool? isReached;

  LocEntity({
    this.id,
    this.stopType,
    this.contactDetails,
    this.goods,
    this.weight,
    this.info,
    this.locationId,
    this.transitDateTime,
    this.location,
    this.isReached,
  });

  factory LocEntity.fromEntity(Map<String, dynamic> json) => LocEntity(
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
            : LocationEntity.fromEntity(json["location"]),
        isReached: json["is_reached"] == 1,
      );

  Map<String, dynamic> toEntity() => {
        "id": id,
        "stop_type": stopType,
        "contact_details": contactDetails,
        "goods": goods,
        "weight": weight,
        "info": info,
        "location_id": locationId,
        "transit_date_time": transitDateTime?.toIso8601String(),
        "location": location?.toEntity(),
        "is_reached": isReached == true ? 1 : 0,
      };

  @override
  List<Object?> get props => [
        id,
        stopType,
        contactDetails,
        goods,
        weight,
        info,
        locationId,
        transitDateTime,
        location,
      ];
}

class LocationEntity extends Equatable {
  final int? id;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? companyName;
  final String? stateName;
  final String? city;
  final String? zipcode;

  const LocationEntity({
    this.id,
    this.latitude,
    this.longitude,
    this.address,
    this.companyName,
    this.stateName,
    this.city,
    this.zipcode,
  });

  factory LocationEntity.fromEntity(Map<String, dynamic> json) =>
      LocationEntity(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        companyName: json["company_name"],
        stateName: json["state_name"],
        city: json["city"],
        zipcode: json["zipcode"],
      );

  Map<String, dynamic> toEntity() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "company_name": companyName,
        "state_name": stateName,
        "city": city,
        "zipcode": zipcode,
      };

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        address,
        companyName,
        stateName,
        city,
        zipcode,
      ];
}
