// To parse this JSON data, do
//
//     final conversationDetailsModel = conversationDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

ConversationTypingEntity conversationTypingModelFromJson(String str) =>
    ConversationTypingEntity.fromJson(json.decode(str));

String conversationDetailsModelToJson(ConversationTypingEntity data) =>
    json.encode(data.toJson());

class ConversationTypingEntity extends Equatable {
  final bool? typing;
  final ConversationTypingUserEntity? user;

  const ConversationTypingEntity({this.typing, this.user});

  factory ConversationTypingEntity.fromJson(Map<String, dynamic> json) =>
      ConversationTypingEntity(
          typing: json["typing"],
          user: ConversationTypingUserEntity.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"typing": typing, "user": user?.toJson()};

  @override
  List<Object?> get props => [typing, user];
}

class ConversationTypingUserEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? image;
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
  final String? fcmToken;
  final String? currentStatus;
  final String? phone;
  final String? modelType;

  const ConversationTypingUserEntity({
    this.id,
    this.uuid,
    this.name,
    this.firstName,
    this.middleName,
    this.image,
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
    this.modelType,
  });

  factory ConversationTypingUserEntity.fromJson(Map<String, dynamic> json) =>
      ConversationTypingUserEntity(
        id: json["id"],
        uuid: json["uuid"],
        name: json["name"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        image: json["image"],
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
        modelType: json["model_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "name": name,
        "first_name": firstName,
        "middle_name": middleName,
        "image": image,
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
        "model_type": modelType,
      };

  @override
  List<Object?> get props => [
        id,
        uuid,
        name,
        firstName,
        middleName,
        image,
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
        modelType,
      ];
}
