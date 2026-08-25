// To parse this JSON data, do
//
//     final createConversationEntity = createConversationEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat/domain/entities/create_conversation_entity.dart';

CreateConversationModel createConversationModelFromJson(String str) =>
    CreateConversationModel.fromJson(json.decode(str));

String createConversationModelToJson(CreateConversationModel data) =>
    json.encode(data.toJson());

class CreateConversationModel extends CreateConversationEntity {
  const CreateConversationModel({
    super.conversation,
  });

  factory CreateConversationModel.fromJson(Map<String, dynamic> json) =>
      CreateConversationModel(
        conversation: json["conversation"] == null
            ? null
            : NewConversationModel.fromJson(json["conversation"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "conversation": conversation?.toJson(),
      };
}

class NewConversationModel extends NewConversationEntity {
  const NewConversationModel({
    super.id,
    super.modelType,
    super.modelId,
    super.type,
    super.deletedAt,
    super.createdAt,
    super.updatedAt,
    super.withParticipent,
  });

  factory NewConversationModel.fromJson(Map<String, dynamic> json) =>
      NewConversationModel(
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
            : NewConversationWithParticipentModel.fromJson(
                json["with_participent"]),
      );

  @override
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
}

class NewConversationWithParticipentModel
    extends NewConversationWithParticipentEntity {
  const NewConversationWithParticipentModel({
    super.id,
    super.uuid,
    super.name,
    super.firstName,
    super.middleName,
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
    super.image,
    super.modelType,
  });

  factory NewConversationWithParticipentModel.fromJson(
          Map<String, dynamic> json) =>
      NewConversationWithParticipentModel(
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
          modelType: json["model_type"]);

  @override
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
}
