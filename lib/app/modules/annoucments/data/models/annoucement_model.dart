import 'dart:convert';

import '../../domain/entities/annoucement_entity.dart';

AnnoucementModel annoucementModelFromJson(String str) =>
    AnnoucementModel.fromJson(json.decode(str));

String annoucementModelToJson(AnnoucementModel data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class AnnoucementModel extends AnnoucementEntity {
  AnnoucementModel({
    super.id,
    super.title,
    super.message,
    super.image,
    super.type,
    super.read,
    super.createdAt,
    super.value,
  });

  @override
  AnnoucementModel copyWith({
    int? id,
    String? title,
    String? message,
    String? image,
    String? type,
    int? read,
    DateTime? createdAt,
    int? value,
  }) =>
      AnnoucementModel(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        image: image ?? this.image,
        type: type ?? this.type,
        read: read ?? this.read,
        createdAt: createdAt ?? this.createdAt,
        value: value ?? this.value,
      );

  factory AnnoucementModel.fromJson(Map<String, dynamic> json) =>
      AnnoucementModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        type: json["type"],
        read: json["read"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"])
                .add(DateTime.now().timeZoneOffset),
        value: json["value"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "image": image,
        "type": type,
        "read": read,
        "created_at": createdAt?.toIso8601String(),
        "value": value,
      };
}
