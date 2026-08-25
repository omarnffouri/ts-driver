// To parse this JSON data, do
//
//     final contactEntity = contactEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat/domain/entities/contact_entity.dart';

ContactModel contactModelFromJson(String str) =>
    ContactModel.fromJson(json.decode(str));

String contactModelToJson(ContactModel data) => json.encode(data.toJson());

class ContactModel extends ContactEntity {
  const ContactModel(
      {super.id,
      super.firstName,
      super.lastName,
      super.email,
      super.emailVerifiedAt,
      super.phone,
      super.birthDate,
      super.address,
      super.fcmToken,
      super.createdAt,
      super.updatedAt,
      super.deletedAt,
      super.teamId,
      super.ringCentralUsername,
      super.ringCentralExtension,
      super.ringCentralPassword,
      super.name,
      super.image,
      super.modelType});

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"] == null
            ? null
            : DateTime.parse(json["email_verified_at"]),
        phone: json["phone"],
        birthDate: json["birth_date"],
        address: json["address"],
        fcmToken: json["fcm_token"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        teamId: json["team_id"],
        ringCentralUsername: json["ring_central_username"],
        ringCentralExtension: json["ring_central_extension"],
        ringCentralPassword: json["ring_central_password"],
        name: json["name"],
        image: json["image"],
        modelType: json["model_type"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "phone": phone,
        "birth_date": birthDate,
        "address": address,
        "fcm_token": fcmToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "team_id": teamId,
        "ring_central_username": ringCentralUsername,
        "ring_central_extension": ringCentralExtension,
        "ring_central_password": ringCentralPassword,
        "name": name,
        "image": image,
        "model_type": modelType,
      };
}
