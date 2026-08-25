// To parse this JSON data, do
//
//     final messageSentEntity = messageSentEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/conversation_details_entity.dart';

MessageSentEntity messageSentEntityFromJson(String str) =>
    MessageSentEntity.fromJson(json.decode(str));

String messageSentEntityToJson(MessageSentEntity data) =>
    json.encode(data.toJson());

class MessageSentEntity extends Equatable {
  final String? message;
  final int? code;
  final List<ConversationMessageEntity>? data;

  const MessageSentEntity({
    this.message,
    this.code,
    this.data,
  });

  factory MessageSentEntity.fromJson(Map<String, dynamic> json) =>
      MessageSentEntity(
        message: json["message"],
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<ConversationMessageEntity>.from(json["data"]!
                .map((x) => ConversationMessageEntity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [
        message,
        code,
        data,
      ];
}
