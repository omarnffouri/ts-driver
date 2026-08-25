// To parse this JSON data, do
//
//     final presenceDataEntity = presenceDataEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat/domain/entities/presence_data_entity.dart';

PresenceDataModel presenceDataModelFromJson(String str) =>
    PresenceDataModel.fromJson(json.decode(str));

String presenceDataModelToJson(PresenceDataModel data) =>
    json.encode(data.toJson());

class PresenceDataModel extends PresenceDataEntity {
  const PresenceDataModel({
    super.presence,
  });

  factory PresenceDataModel.fromJson(Map<String, dynamic> json) =>
      PresenceDataModel(
        presence: json["presence"] == null
            ? null
            : PresencePresenceModel.fromJson(json["presence"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "presence": presence?.toJson(),
      };
}

class PresencePresenceModel extends PresencePresenceEntity {
  const PresencePresenceModel({
    super.ids,
    super.hash,
    super.count,
  });

  factory PresencePresenceModel.fromJson(Map<String, dynamic> json) =>
      PresencePresenceModel(
        ids: parsePresenceIds(json["ids"]),
        hash: Map.from(json["hash"]).map((k, v) =>
            MapEntry<String, PresenceUserModel>(
                k, PresenceUserModel.fromJson(v))),
        count: json["count"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "ids": ids == null ? [] : List<dynamic>.from(ids!.map((x) => x)),
        "hash": Map.from(hash!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "count": count,
      };
}

class PresenceUserModel extends PresenceUserEntity {
  const PresenceUserModel({
    super.id,
    super.name,
    super.phone,
    super.image,
    super.modelType,
  });

  factory PresenceUserModel.fromJson(Map<String, dynamic> json) =>
      PresenceUserModel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        modelType: json["model_type"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "image": image,
        "model_type": modelType,
      };
}
