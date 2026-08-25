// To parse this JSON data, do
//
//     final conversationModel = conversationModelFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';

ConversationModel conversationModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String conversationModelToJson(ConversationModel data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class ConversationModel extends ConversationEntity {
  ConversationModel(
      {super.id,
      super.user,
      super.dateTimeInHumans,
      super.chatAble,
      super.message,
      super.participants,
      super.unreadCount});

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json["id"],
        user: json["receiver"] == null
            ? null
            : ConversationUser.fromJson(json["receiver"]),
        message: json["message"] == null
            ? null
            : ConversationLastMessageModel.fromJson(json["message"]),
        unreadCount: json["unread_count"],
        chatAble: json["chat_able"],
        participants: json["participants"] == null
            ? []
            : List<ParticipantModel>.from(
                json["participants"]!.map((x) => ParticipantModel.fromJson(x))),
        dateTimeInHumans: json["date_time_in_humans"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "receiver": user?.toJson(),
        "message": message?.toJson(),
        "chat_able": chatAble,
        "date_time_in_humans": dateTimeInHumans,
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "unread_count": unreadCount
      };
}

// ignore: must_be_immutable
class ConversationUser extends ConversationUserEntity {
  ConversationUser({
    super.id,
    super.firstName,
    super.lastName,
    super.email,
    super.phone,
    super.modelType,
    super.address,
    super.ringCentralUsername,
    super.ringCentralExtension,
    super.ringCentralPassword,
    super.name,
    super.image,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) =>
      ConversationUser(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phone: json["phone"],
        modelType: json["model_type"],
        address: json["address"],
        ringCentralUsername: json["ring_central_username"],
        ringCentralExtension: json["ring_central_extension"],
        ringCentralPassword: json["ring_central_password"],
        name: json["name"],
        image: json["image"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "model_type": modelType,
        "address": address,
        "ring_central_username": ringCentralUsername,
        "ring_central_extension": ringCentralExtension,
        "ring_central_password": ringCentralPassword,
        "name": name,
        "image": image,
      };
}

// ignore: must_be_immutable
class ConversationLastMessageModel extends ConversationLastMessageEntity {
  ConversationLastMessageModel({
    super.id,
    super.conversationId,
    super.modelType,
    super.modelId,
    super.type,
    super.message,
    super.deletedAt,
    super.duration,
    super.createdAt,
    super.updatedAt,
    super.authIsSender,
    super.dateTimeInHumans,
    super.attachments,
  });

  factory ConversationLastMessageModel.fromJson(Map<String, dynamic> json) =>
      ConversationLastMessageModel(
        id: json["id"],
        conversationId: json["conversation_id"],
        modelType: json["model_type"],
        duration: json["duration"],
        modelId: json["model_id"],
        type: json["type"],
        message: json["message"],
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.parse(json["deleted_at"]).toLocal(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        authIsSender: json["auth_is_sender"],
        dateTimeInHumans: json["date_time_in_humans"],
        attachments: json["attachments"] == null
            ? []
            : List<AttachmentModel>.from(
                json["attachments"]!.map((x) => AttachmentModel.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "model_type": modelType,
        "model_id": modelId,
        "type": type,
        "duration": duration,
        "message": message,
        "deleted_at": deletedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "auth_is_sender": authIsSender,
        "date_time_in_humans": dateTimeInHumans,
      };
}

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    super.id,
    super.pid,
    super.name,
    super.phone,
    super.image,
    super.modelType,
    super.isGroupAdmin,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      ParticipantModel(
        id: json["id"],
        pid: json["p_id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        modelType: json["model_type"],
        isGroupAdmin: json["is_group_admin"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "p_id": pid,
        "name": name,
        "phone": phone,
        "image": image,
        "model_type": modelType,
        "is_group_admin": isGroupAdmin,
      };
}
