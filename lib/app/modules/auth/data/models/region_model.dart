// To parse this JSON data, do
//
//     final statesModel = statesModelFromJson(jsonString);

// ignore_for_file: overridden_fields, annotate_overrides

import 'dart:convert';

import '../../domain/entities/region_entity.dart';

class RegionModel extends RegionEntity {
  final int? id;
  final String? name;
  final String? code;
  const RegionModel({
    required this.id,
    required this.name,
    required this.code,
  }) : super(id: id, name: name);

  RegionModel copyWith({
    int? id,
    String? name,
    String? code,
  }) =>
      RegionModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
      );

  factory RegionModel.fromRawJson(String str) =>
      RegionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
        id: json["id"],
        name: json["name"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
      };
}
