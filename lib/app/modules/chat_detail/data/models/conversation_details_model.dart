// To parse this JSON data, do
//
//     final conversationDetailsModel = conversationDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

ConversationDetailsModel conversationDetailsModelFromJson(String str) =>
    ConversationDetailsModel.fromJson(json.decode(str));

String conversationDetailsModelToJson(ConversationDetailsModel data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class ConversationDetailsModel extends ConversationDetailsEntity {
  ConversationDetailsModel({
    super.id,
    super.isPrivate,
    super.modelId,
    super.type,
    super.participants,
    super.messages,
  });

  factory ConversationDetailsModel.fromJson(Map<String, dynamic> json) =>
      ConversationDetailsModel(
        id: json["id"],
        isPrivate: json["is_private"],
        modelId: json["model_id"],
        type: json["type"],
        participants: json["participants"] == null
            ? null
            : List<ConversationWithParticipentModel>.from(json["participants"]!
                .map((x) => ConversationWithParticipentModel.fromJson(x))),
        messages: json["messages"] == null
            ? []
            : List<ConversationMessageModel>.from(json["messages"]!
                .map((x) => ConversationMessageModel.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "is_private": isPrivate,
        "model_id": modelId,
        "type": type,
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "messages": messages == null
            ? []
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
      };
}

// ignore: must_be_immutable
class ConversationMessageModel extends ConversationMessageEntity {
  ConversationMessageModel({
    super.id,
    super.conversationId,
    super.modelType,
    super.modelId,
    super.type,
    super.message,
    super.deletedAt,
    super.createdAt,
    super.updatedAt,
    super.readBy,
    super.authIsSender,
    super.dateTimeInHumans,
    super.forwardMessageId,
    super.location,
    super.sender,
    super.callType,
    super.tempId,
    super.duration,
    super.replyOn,
    super.mentions,
    super.model,
    super.readAt,
    super.reactions,
    super.attachments,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) =>
      ConversationMessageModel(
        id: json["id"],
        conversationId: json["conversation_id"],
        duration: json["duration"],
        modelType: json["model_type"],
        callType: json["call_type"] ?? "audio",
        tempId: json["temp_id"],
        modelId: json["model_id"],
        location: json["location"] == null
            ? null
            : LocationModel.fromJson(json["location"]),
        type: json["type"],
        message: json["message"],
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.parse(json["deleted_at"]).toLocal(),
        replyOn: json["reply_on"] == null
            ? null
            : ConversationMessageModel.fromJson(json["reply_on"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        authIsSender: json["auth_is_sender"],
        forwardMessageId: json["forward_message_id"],
        readAt: json["read_at"],
        readBy: json["read_by"] == null
            ? []
            : List<ReadByModel>.from(
                json["read_by"]!.map((x) => ReadByModel.fromJson(x))),
        dateTimeInHumans: json["date_time_in_humans"],
        sender: json["sender"],
        model: json["model"] == null
            ? null
            : ConversationUserModel.fromJson(json["model"]),
        attachments: json["attachments"] == null
            ? []
            : List<AttachmentModel>.from(
                json["attachments"]!.map((x) => AttachmentModel.fromJson(x))),
        mentions: json["mentions"] == null
            ? []
            : List<ConversationMentionModel>.from(json["mentions"]!
                .map((x) => ConversationMentionModel.fromJson(x))),
        reactions: json["reactions"] == null
            ? []
            : List<MessageReactionModel>.from(json["reactions"]!
                .map((x) => MessageReactionModel.fromJson(x))),
      );

  static ConversationMessageModel? fromJsonAndNullable(
      Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return ConversationMessageModel(
      id: json["id"],
      duration: json["duration"],
      conversationId: json["conversation_id"],
      modelType: json["model_type"],
      modelId: json["model_id"],
      callType: json["call_type"] ?? "audio",
      forwardMessageId: json["forward_message_id"],
      tempId: json["temp_id"],
      location: json["location"] == null
          ? null
          : LocationModel.fromJson(json["location"]),
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
      readAt: json["read_at"],
      dateTimeInHumans: json["date_time_in_humans"],
      sender: json["sender"],
      readBy: json["read_by"] == null
          ? []
          : List<ReadByModel>.from(
              json["read_by"]!.map((x) => ReadByModel.fromJson(x))),
      model: json["model"] == null
          ? null
          : ConversationUserModel.fromJson(json["model"]),
      replyOn: json["reply_on"] == null
          ? null
          : ConversationMessageModel.fromJson(json["reply_on"]),
      attachments: json["attachments"] == null
          ? []
          : List<AttachmentModel>.from(
              json["attachments"]!.map((x) => AttachmentModel.fromJson(x))),
      mentions: json["mentions"] == null
          ? []
          : List<ConversationMentionModel>.from(json["mentions"]!
              .map((x) => ConversationMentionModel.fromJson(x))),
      reactions: json["reactions"] == null
          ? []
          : List<MessageReactionModel>.from(
              json["reactions"]!.map((x) => MessageReactionModel.fromJson(x))),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "model_type": modelType,
        "model_id": modelId,
        "type": type,
        "forward_message_id": forwardMessageId,
        "duration": duration,
        "message": message,
        "call_type": callType,
        "temp_id": tempId,
        "deleted_at": deletedAt?.toIso8601String(),
        "read_at": readAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "auth_is_sender": authIsSender,
        "date_time_in_humans": dateTimeInHumans,
        "read_by": readBy == null
            ? []
            : List<dynamic>.from(readBy!.map((x) => x.toJson())),
        "sender": sender,
        "reply_on": replyOn?.toJson(),
        "model": model?.toJson(),
        "attachments": attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x.toJson())),
        "mentions": mentions == null
            ? []
            : List<dynamic>.from(mentions!.map((x) => x.toJson())),
        "reactions": reactions == null
            ? []
            : List<dynamic>.from(reactions!.map((x) => x.toJson())),
      };
}

class ConversationUserModel extends ConversationUserModelEntity {
  const ConversationUserModel({
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

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) =>
      ConversationUserModel(
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
}

class ConversationWithParticipentModel
    extends ConversationWithParticipentEntity {
  const ConversationWithParticipentModel({
    super.id,
    super.phone,
    super.name,
    super.image,
    super.modelType,
    super.isGroupAdmin,
    super.pId,
  });

  factory ConversationWithParticipentModel.fromJson(
          Map<String, dynamic> json) =>
      ConversationWithParticipentModel(
        id: json["id"],
        pId: json["p_id"],
        phone: json["phone"],
        name: json["name"],
        image: json["image"],
        modelType: json["model_type"],
        isGroupAdmin: json["is_group_admin"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "p_id": pId,
        "phone": phone,
        "name": name,
        "image": image,
        "model_type": modelType,
        "is_group_admin": isGroupAdmin,
      };
}

class ReadByModel extends ReadByEntity {
  const ReadByModel({
    super.id,
    super.messageId,
    super.modelType,
    super.modelId,
    super.createdAt,
    super.updatedAt,
  });

  factory ReadByModel.fromJson(Map<String, dynamic> json) => ReadByModel(
        id: json["id"],
        messageId: json["message_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "message_id": messageId,
        "model_type": modelType,
        "model_id": modelId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class ConversationMentionModel extends ConversationMentionEntity {
  const ConversationMentionModel({
    super.id,
    super.messageId,
    super.modelType,
    super.modelId,
    super.user,
    super.participantId,
    super.createdAt,
    super.updatedAt,
  });

  factory ConversationMentionModel.fromJson(Map<String, dynamic> json) =>
      ConversationMentionModel(
        id: json["id"],
        messageId: json["echo_message_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        participantId: json["participant_id"],
        user: json["model"] == null
            ? null
            : MentionUserModel.fromJson(json["model"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "echo_message_id": messageId,
        "participant_id": participantId,
        "model_type": modelType,
        "model_id": modelId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "model": user?.toJson(),
      };
}

class MentionUserModel extends MentionUserModelEntity {
  const MentionUserModel({
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
    super.fcmToken,
    super.currentStatus,
    super.phone,
    super.modelType,
  });

  factory MentionUserModel.fromJson(Map<String, dynamic> json) =>
      MentionUserModel(
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
        "fcm_token": fcmToken,
        "currentStatus": currentStatus,
        "phone": phone,
        "model_type": modelType,
      };
}

// ignore: must_be_immutable
class MessageReactionModel extends MessageReactionEntity {
  MessageReactionModel({
    super.id,
    super.pId,
    super.reaction,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) =>
      MessageReactionModel(
        id: json["id"],
        pId: json["p_id"],
        reaction: json["reaction"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "p_id": pId,
        "reaction": reaction,
      };
}

// ignore: must_be_immutable
class AttachmentModel extends AttachmentEntity {
  AttachmentModel({
    super.fileName,
    super.id,
    super.mimeType,
    super.size,
    super.thumbUrl,
    super.url,
    super.uuid,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      AttachmentModel(
        fileName: json["file_name"],
        id: json["id"],
        mimeType: json["mime_type"],
        size: json["size"],
        thumbUrl: json["thumb_url"],
        url: json["url"],
        uuid: json["uuid"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "file_name": fileName,
        "id": id,
        "mime_type": mimeType,
        "size": size,
        "thumb_url": thumbUrl,
        "url": url,
        "uuid": uuid,
      };
}
