// To parse this JSON data, do
//
//     final messageSentEntity = messageSentEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/data/models/conversation_details_model.dart';
import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_sent_entity.dart';

MessageSentModel messageSentModelFromJson(String str) =>
    MessageSentModel.fromJson(json.decode(str));

String messageSentEntityToJson(MessageSentModel data) =>
    json.encode(data.toJson());

class MessageSentModel extends MessageSentEntity {
  const MessageSentModel({
    super.message,
    super.code,
    super.data,
  });

  factory MessageSentModel.fromJson(Map<String, dynamic> json) =>
      MessageSentModel(
        message: json["message"],
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<ConversationMessageModel>.from(
                json["data"]!.map((x) => ConversationMessageModel.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
