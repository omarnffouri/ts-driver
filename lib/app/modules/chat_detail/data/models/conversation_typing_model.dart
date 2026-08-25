// To parse this JSON data, do
//
//     final conversationDetailsModel = conversationDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_typing_entity.dart';

ConversationTypingModel conversationTypingModelFromJson(String str) =>
    ConversationTypingModel.fromJson(json.decode(str));

String conversationDetailsModelToJson(ConversationTypingModel data) =>
    json.encode(data.toJson());

class ConversationTypingModel extends ConversationTypingEntity {
  const ConversationTypingModel({super.typing, super.user});

  factory ConversationTypingModel.fromJson(Map<String, dynamic> json) =>
      ConversationTypingModel(
          typing: json["typing"],
          user: ConversationTypingUserModel.fromJson(json["user"]));

  @override
  Map<String, dynamic> toJson() => {"typing": typing, "user": user?.toJson()};

  @override
  List<Object?> get props => [typing, user];
}

class ConversationTypingUserModel extends ConversationTypingUserEntity {
  const ConversationTypingUserModel({
    super.id,
    super.uuid,
    super.name,
    super.firstName,
    super.middleName,
    super.image,
    super.lastName,
    super.ssNo,
    super.dob,
    super.mobileNumber,
    super.otherMobileNumber,
    super.email,
    super.maidenName,
    super.haveYouConvicted,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    super.fcmToken,
    super.currentStatus,
    super.phone,
    super.modelType,
  });

  factory ConversationTypingUserModel.fromJson(Map<String, dynamic> json) =>
      ConversationTypingUserModel(
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

  @override
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
