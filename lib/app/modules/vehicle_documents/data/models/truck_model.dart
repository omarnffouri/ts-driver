import 'dart:convert';

import '../../domain/entities/truck_entity.dart';

TruckModel truckModelFromJson(String str) =>
    TruckModel.fromJson(json.decode(str));

String truckModelToJson(TruckModel data) => json.encode(data.toJson());

class TruckModel extends TruckEntity {
  const TruckModel({
    required super.id,
    required super.name,
    required super.path,
  });

  factory TruckModel.fromJson(Map<String, dynamic> json) => TruckModel(
        id: json["id"].toString(),
        name: json["name"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "path": path,
      };
}
