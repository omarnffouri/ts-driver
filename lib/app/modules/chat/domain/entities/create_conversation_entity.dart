// To parse this JSON data, do
//
//     final createConversationEntity = createConversationEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

CreateConversationEntity createConversationEntityFromJson(String str) =>
    CreateConversationEntity.fromJson(json.decode(str));

String createConversationEntityToJson(CreateConversationEntity data) =>
    json.encode(data.toJson());

class CreateConversationEntity extends Equatable {
  final NewConversationEntity? conversation;

  const CreateConversationEntity({
    this.conversation,
  });

  factory CreateConversationEntity.fromJson(Map<String, dynamic> json) =>
      CreateConversationEntity(
        conversation: json["conversation"] == null
            ? null
            : NewConversationEntity.fromJson(json["conversation"]),
      );

  Map<String, dynamic> toJson() => {
        "conversation": conversation?.toJson(),
      };

  @override
  List<Object?> get props => [conversation];
}

class NewConversationEntity extends Equatable {
  final int? id;
  final String? modelType;
  final int? modelId;
  final String? type;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final NewConversationWithParticipentEntity? withParticipent;

  const NewConversationEntity({
    this.id,
    this.modelType,
    this.modelId,
    this.type,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.withParticipent,
  });

  factory NewConversationEntity.fromJson(Map<String, dynamic> json) =>
      NewConversationEntity(
        id: json["id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        type: json["type"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        withParticipent: json["with_participent"] == null
            ? null
            : NewConversationWithParticipentEntity.fromJson(
                json["with_participent"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model_type": modelType,
        "model_id": modelId,
        "type": type,
        "deleted_at": deletedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "with_participent": withParticipent?.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        modelType,
        modelId,
        type,
        deletedAt,
        createdAt,
        updatedAt,
        withParticipent,
      ];
}

class NewConversationWithParticipentEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? ssNo;
  final String? dob;
  final String? mobileNumber;
  final dynamic otherMobileNumber;
  final String? email;
  final dynamic maidenName;
  final String? haveYouConvicted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final dynamic fcmToken;
  final String? currentStatus;
  final String? phone;
  final String? image;
  final String? modelType;

  const NewConversationWithParticipentEntity(
      {this.id,
      this.uuid,
      this.name,
      this.firstName,
      this.middleName,
      this.lastName,
      this.ssNo,
      this.dob,
      this.mobileNumber,
      this.otherMobileNumber,
      this.email,
      this.maidenName,
      this.haveYouConvicted,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.fcmToken,
      this.currentStatus,
      this.phone,
      this.image,
      this.modelType});

  factory NewConversationWithParticipentEntity.fromJson(
          Map<String, dynamic> json) =>
      NewConversationWithParticipentEntity(
        id: json["id"],
        uuid: json["uuid"],
        name: json["name"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        ssNo: json["ss_no"],
        dob: json["dob"],
        mobileNumber: json["mobile_number"],
        otherMobileNumber: json["other_mobile_number"],
        email: json["email"],
        maidenName: json["maiden_name"],
        haveYouConvicted: json["have_you_convicted"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        fcmToken: json["fcm_token"],
        currentStatus: json["currentStatus"],
        phone: json["phone"],
        image: json["image"],
        modelType: json["model_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "name": name,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "ss_no": ssNo,
        "dob": dob,
        "mobile_number": mobileNumber,
        "other_mobile_number": otherMobileNumber,
        "email": email,
        "maiden_name": maidenName,
        "have_you_convicted": haveYouConvicted,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "fcm_token": fcmToken,
        "currentStatus": currentStatus,
        "phone": phone,
        "image": image,
        "model_type": modelType
      };

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        firstName,
        middleName,
        lastName,
        ssNo,
        dob,
        mobileNumber,
        otherMobileNumber,
        email,
        maidenName,
        haveYouConvicted,
        createdAt,
        updatedAt,
        deletedAt,
        fcmToken,
        currentStatus,
        phone,
        image,
        modelType
      ];
}
