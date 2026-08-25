// To parse this JSON data, do
//
//     final conversationDetailsModel = conversationDetailsModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/modules/chat_detail/data/enums/message_types.dart';

ConversationDetailsEntity conversationDetailsModelFromJson(String str) =>
    ConversationDetailsEntity.fromJson(json.decode(str));

String conversationDetailsModelToJson(ConversationDetailsEntity data) =>
    json.encode(data.toJson());

// ignore: must_be_immutable
class ConversationDetailsEntity extends Equatable {
  final int? id;
  final int? isPrivate;
  final int? modelId;
  final String? type;
  final List<ConversationWithParticipentEntity>? participants;
  List<ConversationMessageEntity>? messages;

  ConversationDetailsEntity({
    this.id,
    this.isPrivate,
    this.modelId,
    this.type,
    this.participants,
    this.messages,
  });

  factory ConversationDetailsEntity.fromJson(Map<String, dynamic> json) =>
      ConversationDetailsEntity(
        id: json["id"],
        isPrivate: json["is_private"],
        modelId: json["model_id"],
        type: json["type"],
        participants: json["participants"] == null
            ? null
            : List<ConversationWithParticipentEntity>.from(json["participants"]!
                .map((x) => ConversationWithParticipentEntity.fromJson(x))),
        messages: json["messages"] == null
            ? []
            : List<ConversationMessageEntity>.from(json["messages"]!
                .map((x) => ConversationMessageEntity.fromJson(x))),
      );

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

  @override
  List<Object?> get props =>
      [id, isPrivate, modelId, type, participants, messages];
}

// ignore: must_be_immutable
class ConversationMessageEntity extends Equatable {
  int? id;
  dynamic conversationId;
  final String? modelType;
  final int? modelId;
  int? duration;
  ConversationMessageEntity? replyOn;
  final String? type;
  String? message;
  LocationModel? location;
  DateTime? deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<ReadByEntity>? readBy;
  final List<ConversationMentionEntity>? mentions;
  final bool? authIsSender;
  final String? dateTimeInHumans;
  final dynamic sender;
  ConversationUserModelEntity? model;
  final String? tempId;
  String? readAt;
  List<MessageReactionEntity>? reactions;
  List<AttachmentEntity>? attachments;
  bool sendedNow = false;
  bool sentSuccessfully = false;
  final String? callType;
  final int? forwardMessageId;

  ConversationMessageEntity({
    this.id,
    this.conversationId,
    this.modelType,
    this.modelId,
    this.type,
    this.message,
    this.deletedAt,
    this.replyOn,
    this.forwardMessageId,
    this.readBy,
    this.createdAt,
    this.location,
    this.updatedAt,
    this.callType,
    this.authIsSender,
    this.mentions,
    this.dateTimeInHumans,
    this.sender,
    this.model,
    this.tempId,
    this.duration,
    this.readAt,
    this.reactions,
    this.attachments,
  });

  factory ConversationMessageEntity.fromJson(Map<String, dynamic> json) =>
      ConversationMessageEntity(
        id: json["id"],
        duration: json["duration"],
        conversationId: json["conversation_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        type: json["type"],
        forwardMessageId: json["forward_message_id"],
        message: json["message"],
        location: json["location"] == null
            ? null
            : LocationModel.fromJson(json["location"]),
        callType: json["call_type"] ?? "audio",
        tempId: json["temp_id"],
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
        sender: json["sender"],
        readAt: json["read_at"],
        readBy: json["read_by"] == null
            ? []
            : List<ReadByEntity>.from(
                json["read_by"]!.map((x) => ReadByEntity.fromJson(x))),
        model: json["model"] == null
            ? null
            : ConversationUserModelEntity.fromJson(json["model"]),
        replyOn: json["reply_on"] == null
            ? null
            : ConversationMessageEntity.fromJson(json["reply_on"]),
        attachments: json["attachments"] == null
            ? []
            : List<AttachmentEntity>.from(
                json["attachments"]!.map((x) => AttachmentEntity.fromJson(x))),
        mentions: json["mentions"] == null
            ? []
            : List<ConversationMentionEntity>.from(json["mentions"]!
                .map((x) => ConversationMentionEntity.fromJson(x))),
        reactions: json["reactions"] == null
            ? []
            : List<MessageReactionEntity>.from(json["reactions"]!
                .map((x) => MessageReactionEntity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "conversation_id": conversationId,
        "model_type": modelType,
        "model_id": modelId,
        "type": type,
        "duration": duration,
        "temp_id": tempId,
        "forward_message_id": forwardMessageId,
        "call_type": callType,
        "message": message,
        'location': location?.toJson(),
        "deleted_at": deletedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "auth_is_sender": authIsSender,
        "date_time_in_humans": dateTimeInHumans,
        "sender": sender,
        "read_at": readAt,
        "model": model?.toJson(),
        "read_by": readBy == null
            ? []
            : List<dynamic>.from(readBy!.map((x) => x.toJson())),
        "reply_on": replyOn?.toJson(),
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

  @override
  List<Object?> get props => [
        id,
        conversationId,
        modelType,
        modelId,
        type,
        mentions,
        message,
        forwardMessageId,
        deletedAt,
        tempId,
        callType,
        createdAt,
        replyOn,
        readBy,
        updatedAt,
        duration,
        authIsSender,
        dateTimeInHumans,
        sender,
        model,
        readAt,
        attachments,
        reactions,
      ];
}

class ConversationUserModelEntity extends Equatable {
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

  const ConversationUserModelEntity({
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

  factory ConversationUserModelEntity.fromJson(Map<String, dynamic> json) =>
      ConversationUserModelEntity(
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

class ConversationWithParticipentEntity extends Equatable {
  final int? id;
  final String? phone;
  final String? name;
  final String? image;
  final String? modelType;
  final bool? isGroupAdmin;
  final int? pId;

  const ConversationWithParticipentEntity(
      {this.id,
      this.phone,
      this.name,
      this.image,
      this.pId,
      this.modelType,
      this.isGroupAdmin});

  factory ConversationWithParticipentEntity.fromJson(
          Map<String, dynamic> json) =>
      ConversationWithParticipentEntity(
        id: json["id"],
        pId: json["p_id"],
        phone: json["phone"],
        name: json["name"],
        image: json["image"],
        modelType: json["model_type"],
        isGroupAdmin: json["is_group_admin"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "name": name,
        "image": image,
        "p_id": pId,
        "model_type": modelType,
        "is_group_admin": isGroupAdmin,
      };

  @override
  List<Object?> get props =>
      [id, phone, name, image, modelType, isGroupAdmin, pid];
}

class ReadByEntity extends Equatable {
  final int? id;
  final int? messageId;
  final String? modelType;
  final int? modelId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReadByEntity({
    this.id,
    this.messageId,
    this.modelType,
    this.modelId,
    this.createdAt,
    this.updatedAt,
  });

  factory ReadByEntity.fromJson(Map<String, dynamic> json) => ReadByEntity(
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "message_id": messageId,
        "model_type": modelType,
        "model_id": modelId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        messageId,
        modelType,
        modelId,
        createdAt,
        updatedAt,
      ];
}

class LocationModel extends Equatable {
  final double? lat, lng;

  const LocationModel({this.lat, this.lng});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  List<Object?> get props => [lat, lng];
}

class ConversationMentionEntity extends Equatable {
  final int? id;
  final int? messageId;
  final int? participantId;
  final String? modelType;
  final int? modelId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MentionUserModelEntity? user;

  const ConversationMentionEntity({
    this.id,
    this.messageId,
    this.modelType,
    this.modelId,
    this.user,
    this.participantId,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationMentionEntity.fromJson(Map<String, dynamic> json) =>
      ConversationMentionEntity(
        id: json["id"],
        messageId: json["echo_message_id"],
        modelType: json["model_type"],
        modelId: json["model_id"],
        participantId: json["participant_id"],
        user: json["model"] == null
            ? null
            : MentionUserModelEntity.fromJson(json["model"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

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

  @override
  List<Object?> get props => [
        id,
        messageId,
        modelType,
        modelId,
        participantId,
        user,
        createdAt,
        updatedAt,
      ];
}

class MentionUserModelEntity extends Equatable {
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
  final String? fcmToken;
  final String? currentStatus;
  final String? phone;
  final String? modelType;

  const MentionUserModelEntity({
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
    this.fcmToken,
    this.currentStatus,
    this.phone,
    this.modelType,
  });

  factory MentionUserModelEntity.fromJson(Map<String, dynamic> json) =>
      MentionUserModelEntity(
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
        fcmToken,
        currentStatus,
        phone,
        modelType,
      ];
}

// ignore: must_be_immutable
class MessageReactionEntity extends Equatable {
  final int? id;
  final int? pId;
  String? reaction;

  //
  //
  // not form the api maually added
  ConversationWithParticipentEntity? reactedBy;

  MessageReactionEntity({this.id, this.pId, this.reaction, this.reactedBy});

  factory MessageReactionEntity.fromJson(Map<String, dynamic> json) =>
      MessageReactionEntity(
        id: json["id"],
        pId: json["p_id"],
        reaction: json["reaction"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "p_id": pId,
        "reaction": reaction,
      };

  @override
  List<Object?> get props => [
        id,
        pId,
        reaction,
      ];
}

// ignore: must_be_immutable
class AttachmentEntity extends Equatable {
  final String? fileName;
  final int? id;
  String? mimeType;
  final int? size;
  final String? thumbUrl;
  final String? url;
  final String? uuid;

  bool sendedNow = false;
  bool sending = false;
  RxDouble downloadProgress = (0.0).obs;
  RxBool isDownloading = false.obs;
  bool sendedSuccessfully = false;
  File? file;
  String attachmentType = MessageTypes.attachment;

  AttachmentEntity({
    this.fileName,
    this.id,
    this.mimeType,
    this.size,
    this.thumbUrl,
    this.url,
    this.uuid,
  });

  factory AttachmentEntity.fromJson(Map<String, dynamic> json) =>
      AttachmentEntity(
        fileName: json["file_name"],
        id: json["id"],
        mimeType: json["mime_type"],
        size: json["size"],
        thumbUrl: json["thumb_url"],
        url: json["url"],
        uuid: json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "file_name": fileName,
        "id": id,
        "mime_type": mimeType,
        "size": size,
        "thumb_url": thumbUrl,
        "url": url,
        "uuid": uuid,
      };

  @override
  List<Object?> get props => [
        fileName,
        id,
        mimeType,
        size,
        thumbUrl,
        url,
        uuid,
      ];
}
