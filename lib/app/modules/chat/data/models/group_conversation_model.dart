import 'dart:convert';

import 'package:ts_driver/app/modules/chat/data/models/conversation_model.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/group_conversation_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';

GroupConversationModel groupConversationModelFromJson(String str) =>
    GroupConversationModel.fromJson(json.decode(str));

String groupConversationModelToJson(GroupConversationModel data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class GroupConversationModel extends GroupConversationEntity {
  GroupConversationModel({
    super.id,
    super.groupName,
    super.name,
    super.participants,
    super.message,
    super.chatAble,
    super.dateTimeInHumans,
    super.lastMessagedAt,
    super.mentioned,
    super.unreadCount,
    super.groupSettings,
  });

  factory GroupConversationModel.fromJson(Map<String, dynamic> json) =>
      GroupConversationModel(
        id: json["id"],
        groupName: json["group_name"],
        name: json["name"],
        chatAble: json["chat_able"],
        participants: json["participants"] == null
            ? []
            : List<ParticipantModel>.from(
                json["participants"]!.map((x) => ParticipantModel.fromJson(x))),
        message: json["message"] == null
            ? null
            : GroupMessageModel.fromJson(json["message"]),
        dateTimeInHumans: json["date_time_in_humans"],
        lastMessagedAt: json["last_messaged_at"],
        unreadCount: json["unread_count"],
        mentioned: json["mentioned"] == null
            ? []
            : List<int>.from(json["mentioned"]!.map((x) => x)),
        groupSettings: json["group_setting"] == null
            ? null
            : GroupSettingsModel.fromJson(json["group_setting"]),
      );

  factory GroupConversationModel.fromJsonApi(Map<String, dynamic> json) {
    final groupSettings = json["group_setting"] == null
        ? null
        : GroupSettingsModel.fromJson(json["group_setting"]);

    final conversation =
        GroupConversationModel.fromJson(json["conversations"][0]);

    conversation.groupSettings = groupSettings;

    return conversation;

    //
  }

  //   GroupConversationModel(
  //   id: json["id"],
  //   groupName: json["group_name"],
  //   name: json["name"],
  //   chatAble: json["chat_able"],
  //   participants: json["participants"] == null
  //       ? []
  //       : List<ParticipantModel>.from(
  //           json["participants"]!.map((x) => ParticipantModel.fromJson(x))),
  //   message: json["message"] == null
  //       ? null
  //       : GroupMessageModel.fromJson(json["message"]),
  //   dateTimeInHumans: json["date_time_in_humans"],
  //   lastMessagedAt: json["last_messaged_at"],
  //   unreadCount: json["unread_count"],
  //   mentioned: json["mentioned"] == null
  //       ? []
  //       : List<int>.from(json["mentioned"]!.map((x) => x)),
  //   groupSettings: json["group_setting"] == null
  //       ? null
  //       : GroupSettingsModel.fromJson(json["group_setting"]),
  // )

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "group_name": groupName,
        "name": name,
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "message": message?.toJson(),
        "date_time_in_humans": dateTimeInHumans,
        "chat_able": chatAble,
        "last_messaged_at": lastMessagedAt,
        "unread_count": unreadCount,
        "mentioned": mentioned == null
            ? []
            : List<dynamic>.from(mentioned!.map((x) => x)),
        "group_setting": groupSettings?.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        groupName,
        name,
        participants,
        chatAble,
        message,
        dateTimeInHumans,
        lastMessagedAt,
        unreadCount,
        groupSettings,
      ];
}

// ignore: must_be_immutable
class GroupMessageModel extends GroupMessageEntity {
  GroupMessageModel({
    super.id,
    super.conversationId,
    super.modelType,
    super.modelId,
    super.type,
    super.message,
    super.readAt,
    super.deletedAt,
    super.duration,
    super.createdAt,
    super.updatedAt,
    super.authIsSender,
    super.dateTimeInHumans,
    super.attachments,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) =>
      GroupMessageModel(
        id: json["id"],
        conversationId: json["conversation_id"],
        modelType: json["model_type"],
        duration: json["duration"],
        modelId: json["model_id"],
        type: json["type"],
        message: json["message"],
        readAt: json["read_at"],
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
        "message": message,
        "duration": duration,
        "read_at": readAt,
        "deleted_at": deletedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "auth_is_sender": authIsSender,
        "date_time_in_humans": dateTimeInHumans,
        "attachments": attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x.toJson())),
      };
}

class GroupSettingsModel extends GroupSettingsEntity {
  const GroupSettingsModel({
    super.id,
    super.name,
    super.logo,
  });

  factory GroupSettingsModel.fromJson(Map<String, dynamic> json) =>
      GroupSettingsModel(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
      };
}
