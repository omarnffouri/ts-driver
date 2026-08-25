// To parse this JSON data, do
//
//     final conversationModel = conversationModelFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

// ignore: must_be_immutable
class ConversationEntity extends Equatable {
  int? id;
  ConversationUserEntity? user;
  String? dateTimeInHumans;
  ConversationLastMessageEntity? message;
  int? unreadCount;
  bool? chatAble;
  final List<ParticipantEntity>? participants;

  ConversationEntity(
      {this.id,
      this.user,
      this.dateTimeInHumans,
      this.message,
      this.chatAble,
      this.participants,
      this.unreadCount});

  factory ConversationEntity.fromJson(Map<String, dynamic> json) =>
      ConversationEntity(
        id: json["id"],
        user: json["receiver"] == null
            ? null
            : ConversationUserEntity.fromJson(json["receiver"]),
        message: json["message"] == null
            ? null
            : ConversationLastMessageEntity.fromJson(json["message"]),
        chatAble: json["chat_able"],
        unreadCount: json["unread_count"],
        participants: json["participants"] == null
            ? []
            : List<ParticipantEntity>.from(json["participants"]!
                .map((x) => ParticipantEntity.fromJson(x))),
        dateTimeInHumans: json["date_time_in_humans"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "receiver": user?.toJson(),
        "chat_able": chatAble,
        "date_time_in_humans": dateTimeInHumans,
        "message": message?.toJson(),
        "participants": participants == null
            ? []
            : List<dynamic>.from(participants!.map((x) => x.toJson())),
        "unread_count": unreadCount
      };

  @override
  List<Object?> get props => [
        id,
        user,
        chatAble,
        dateTimeInHumans,
        message,
        unreadCount,
        participants,
      ];
}

// ignore: must_be_immutable
class ConversationUserEntity extends Equatable {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? modelType;
  String? address;
  String? ringCentralUsername;
  String? ringCentralExtension;
  String? ringCentralPassword;
  String? name;
  String? image;

  ConversationUserEntity({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.modelType,
    this.ringCentralUsername,
    this.ringCentralExtension,
    this.ringCentralPassword,
    this.name,
    this.image,
  });

  factory ConversationUserEntity.fromJson(Map<String, dynamic> json) =>
      ConversationUserEntity(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        modelType: json["model_type"],
        phone: json["phone"],
        address: json["address"],
        ringCentralUsername: json["ring_central_username"],
        ringCentralExtension: json["ring_central_extension"],
        ringCentralPassword: json["ring_central_password"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "address": address,
        "model_type": modelType,
        "ring_central_username": ringCentralUsername,
        "ring_central_extension": ringCentralExtension,
        "ring_central_password": ringCentralPassword,
        "name": name,
        "image": image,
      };

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        modelType,
        address,
        ringCentralUsername,
        ringCentralExtension,
        ringCentralPassword,
        name,
        image
      ];
}

// ignore: must_be_immutable
class ConversationLastMessageEntity extends Equatable {
  int? id;
  int? conversationId;
  String? modelType;
  int? modelId;
  int? duration;
  String? type;
  String? message;
  DateTime? deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? authIsSender;
  String? dateTimeInHumans;
  List<AttachmentEntity>? attachments;

  ConversationLastMessageEntity({
    this.id,
    this.conversationId,
    this.modelType,
    this.modelId,
    this.type,
    this.message,
    this.duration,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.authIsSender,
    this.dateTimeInHumans,
    this.attachments,
  });

  factory ConversationLastMessageEntity.fromJson(Map<String, dynamic> json) =>
      ConversationLastMessageEntity(
        id: json["id"],
        conversationId: json["conversation_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        duration: json["duration"],
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
        duration,
        message,
        deletedAt,
        createdAt,
        updatedAt,
        authIsSender,
        dateTimeInHumans,
        attachments,
      ];
}

class ParticipantEntity extends Equatable {
  final int? id;
  final int? pid;
  final String? name;
  final String? phone;
  final String? image;
  final String? modelType;
  final bool? isGroupAdmin;

  const ParticipantEntity({
    this.id,
    this.pid,
    this.name,
    this.phone,
    this.image,
    this.modelType,
    this.isGroupAdmin,
  });

  factory ParticipantEntity.fromJson(Map<String, dynamic> json) =>
      ParticipantEntity(
        id: json["id"],
        pid: json["p_id"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        modelType: json["model_type"],
        isGroupAdmin: json["is_group_admin"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "p_id": pid,
        "name": name,
        "phone": phone,
        "image": image,
        "model_type": modelType,
        "is_group_admin": isGroupAdmin,
      };

  @override
  List<Object?> get props => [
        id,
        pid,
        name,
        phone,
        image,
        modelType,
        isGroupAdmin,
      ];
}
