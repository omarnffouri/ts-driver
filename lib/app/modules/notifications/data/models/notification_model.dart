// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

import '../../domain/entities/notification_entity.dart';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class NotificationModel extends NotificationEntity {
  NotificationModel({
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
  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? image,
    String? type,
    int? read,
    DateTime? createdAt,
    int? value,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        image: image ?? this.image,
        type: type ?? this.type,
        read: read ?? this.read,
        createdAt: createdAt ?? this.createdAt,
        value: value ?? this.value,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        type: json["type"],
        read: json["read"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
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
