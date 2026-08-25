// To parse this JSON data, do
//
//     final presenceUserAddedEntity = presenceUserAddedEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/presence_data_entity.dart';

PresenceUserAddedEntity presenceUserAddedEntityFromJson(String str) =>
    PresenceUserAddedEntity.fromJson(json.decode(str));

String presenceUserAddedEntityToJson(PresenceUserAddedEntity data) =>
    json.encode(data.toJson());

class PresenceUserAddedEntity extends Equatable {
  final String? userId;
  final PresenceUserEntity? user;

  const PresenceUserAddedEntity({
    this.userId,
    this.user,
  });

  factory PresenceUserAddedEntity.fromJson(Map<String, dynamic> json) =>
      PresenceUserAddedEntity(
        userId: json["user_id"],
        user: json["user_info"] == null
            ? null
            : PresenceUserEntity.fromJson(json["user_info"]),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_info": user?.toJson(),
      };

  @override
  List<Object?> get props => [
        userId,
        user,
      ];
}
