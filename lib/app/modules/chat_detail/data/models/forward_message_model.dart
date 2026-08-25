// To parse this JSON data, do
//
//     final messageMarkAsReadEntity = messageMarkAsReadEntityFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/chat_detail/domain/entities/forward_message_entity.dart';

ForwardMessageModel forwardMessageModelFromJson(String str) =>
    ForwardMessageModel.fromJson(json.decode(str));

String forwardMessageToJson(ForwardMessageModel data) =>
    json.encode(data.toJson());

class ForwardMessageModel extends ForwardMessageEntity {
  const ForwardMessageModel({
    super.error,
    super.message,
    super.code,
  });

  factory ForwardMessageModel.fromJson(Map<String, dynamic> json) =>
      ForwardMessageModel(
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
