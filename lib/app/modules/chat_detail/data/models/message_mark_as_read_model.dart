// To parse this JSON data, do
//
//     final messageMarkAsReadModel = messageMarkAsReadModelFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/domain/entities/message_mark_as_read_entity.dart';

MessageMarkAsReadModel messageMarkAsReadModelFromJson(String str) =>
    MessageMarkAsReadModel.fromJson(json.decode(str));

String messageMarkAsReadModelToJson(MessageMarkAsReadModel data) =>
    json.encode(data.toJson());

class MessageMarkAsReadModel extends MessageMarkAsReadEntity {
  const MessageMarkAsReadModel({
    super.error,
    super.message,
    super.code,
  });

  factory MessageMarkAsReadModel.fromJson(Map<String, dynamic> json) =>
      MessageMarkAsReadModel(
        error: json["error"],
        message: json["message"],
        code: json["code"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "code": code,
      };
}
