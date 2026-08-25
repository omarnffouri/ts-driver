// To parse this JSON data, do
//
//     final contactEntity = contactEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

ContactEntity contactEntityFromJson(String str) =>
    ContactEntity.fromJson(json.decode(str));

String contactEntityToJson(ContactEntity data) => json.encode(data.toJson());

class ContactEntity extends Equatable {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? phone;
  final String? birthDate;
  final String? address;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final dynamic teamId;
  final String? ringCentralUsername;
  final String? ringCentralExtension;
  final String? ringCentralPassword;
  final String? name;
  final String? image;
  final String? modelType;

  const ContactEntity(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.emailVerifiedAt,
      this.phone,
      this.birthDate,
      this.address,
      this.fcmToken,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.teamId,
      this.ringCentralUsername,
      this.ringCentralExtension,
      this.ringCentralPassword,
      this.name,
      this.image,
      this.modelType});

  factory ContactEntity.fromJson(Map<String, dynamic> json) => ContactEntity(
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

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        emailVerifiedAt,
        phone,
        birthDate,
        address,
        fcmToken,
        createdAt,
        updatedAt,
        deletedAt,
        teamId,
        ringCentralUsername,
        ringCentralExtension,
        ringCentralPassword,
        name,
        image,
        modelType
      ];
}
