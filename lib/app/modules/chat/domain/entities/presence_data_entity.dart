// To parse this JSON data, do
//
//     final presenceDataEntity = presenceDataEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

PresenceDataEntity presenceDataEntityFromJson(String str) =>
    PresenceDataEntity.fromJson(json.decode(str));

String presenceDataEntityToJson(PresenceDataEntity data) =>
    json.encode(data.toJson());

List<int> parsePresenceIds(dynamic raw) {
  if (raw == null) return [];
  return (raw as List)
      .map((x) => x is int ? x : int.tryParse(x.toString()) ?? 0)
      .toList();
}

class PresenceDataEntity extends Equatable {
  final PresencePresenceEntity? presence;

  const PresenceDataEntity({
    this.presence,
  });

  factory PresenceDataEntity.fromJson(Map<String, dynamic> json) =>
      PresenceDataEntity(
        presence: json["presence"] == null
            ? null
            : PresencePresenceEntity.fromJson(json["presence"]),
      );

  Map<String, dynamic> toJson() => {
        "presence": presence?.toJson(),
      };

  @override
  List<Object?> get props => [presence];
}

class PresencePresenceEntity extends Equatable {
  final List<int>? ids;
  final Map<String, PresenceUserEntity>? hash;
  final int? count;

  const PresencePresenceEntity({
    this.ids,
    this.hash,
    this.count,
  });

  factory PresencePresenceEntity.fromJson(Map<String, dynamic> json) =>
      PresencePresenceEntity(
        ids: parsePresenceIds(json["ids"]),
        hash: Map.from(json["hash"]).map((k, v) =>
            MapEntry<String, PresenceUserEntity>(
                k, PresenceUserEntity.fromJson(v))),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "ids": ids == null ? [] : List<dynamic>.from(ids!.map((x) => x)),
        "hash": Map.from(hash!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "count": count,
      };

  @override
  List<Object?> get props => [
        ids,
        hash,
        count,
      ];
}

class PresenceUserEntity extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final String? image;
  final String? modelType;

  const PresenceUserEntity({
    this.id,
    this.name,
    this.phone,
    this.image,
    this.modelType,
  });

  factory PresenceUserEntity.fromJson(Map<String, dynamic> json) =>
      PresenceUserEntity(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        modelType: json["model_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "image": image,
        "model_type": modelType,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        image,
        modelType,
      ];
}
