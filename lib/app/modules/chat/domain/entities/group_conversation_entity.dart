// To parse this JSON data, do
//
//     final groupConversationEntity = groupConversationEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ts_driver/app/modules/chat/domain/entities/conversation_entity.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

GroupConversationEntity groupConversationEntityFromJson(String str) =>
    GroupConversationEntity.fromJson(json.decode(str));

String groupConversationEntityToJson(GroupConversationEntity data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class GroupConversationEntity extends Equatable {
  final int? id;
  final String? groupName;
  final String? name;
  final List<ParticipantEntity>? participants;
  GroupMessageEntity? message;
  String? dateTimeInHumans;
  final int? lastMessagedAt;
  int? unreadCount;
  bool? chatAble;
  List<int>? mentioned;
  GroupSettingsEntity? groupSettings;

  GroupConversationEntity({
    this.id,
    this.groupName,
    this.name,
    this.participants,
    this.message,
    this.chatAble,
    this.mentioned,
    this.dateTimeInHumans,
    this.lastMessagedAt,
    this.unreadCount,
    this.groupSettings,
  });

  factory GroupConversationEntity.fromJson(Map<String, dynamic> json) =>
      GroupConversationEntity(
        id: json["id"],
        groupName: json["group_name"],
        name: json["name"],
        participants: json["participants"] == null
            ? []
            : List<ParticipantEntity>.from(json["participants"]!
                .map((x) => ParticipantEntity.fromJson(x))),
        message: json["message"] == null
            ? null
            : GroupMessageEntity.fromJson(json["message"]),
        dateTimeInHumans: json["date_time_in_humans"],
        chatAble: json["chat_able"],
        lastMessagedAt: json["last_messaged_at"],
        unreadCount: json["unread_count"],
        mentioned: json["mentioned"] == null
            ? []
            : List<int>.from(json["mentioned"]!.map((x) => x)),
        groupSettings: json["group_setting"] == null
            ? null
            : GroupSettingsEntity.fromJson(json["group_setting"]),
      );

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
        message,
        chatAble,
        mentioned,
        dateTimeInHumans,
        lastMessagedAt,
        unreadCount,
        groupSettings,
      ];
}

// ignore: must_be_immutable
class GroupMessageEntity extends Equatable {
  final int? id;
  final int? conversationId;
  final String? modelType;
  final int? modelId;
  final String? type;
  final String? message;
  final int? duration;
  final dynamic readAt;
  DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? authIsSender;
  final String? dateTimeInHumans;
  final List<AttachmentEntity>? attachments;

  GroupMessageEntity({
    this.id,
    this.conversationId,
    this.modelType,
    this.modelId,
    this.duration,
    this.type,
    this.message,
    this.readAt,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.authIsSender,
    this.dateTimeInHumans,
    this.attachments,
  });

  factory GroupMessageEntity.fromJson(Map<String, dynamic> json) =>
      GroupMessageEntity(
        id: json["id"],
        conversationId: json["conversation_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        type: json["type"],
        duration: json["duration"],
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
            : List<AttachmentEntity>.from(
                json["attachments"]!.map((x) => AttachmentEntity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "model_type": modelType,
        "model_id": modelId,
        "type": type,
        "duration": duration,
        "message": message,
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

  @override
  List<Object?> get props => [
        id,
        conversationId,
        modelType,
        modelId,
        type,
        message,
        duration,
        readAt,
        deletedAt,
        createdAt,
        updatedAt,
        authIsSender,
        dateTimeInHumans,
        attachments,
      ];
}

class GroupSettingsEntity extends Equatable {
  final int? id;
  final String? name;
  final String? logo;

  const GroupSettingsEntity({
    this.id,
    this.name,
    this.logo,
  });

  factory GroupSettingsEntity.fromJson(Map<String, dynamic> json) =>
      GroupSettingsEntity(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        logo,
      ];
}
