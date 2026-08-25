// To parse this JSON data, do
//
//     final messageMarkAsReadEntity = messageMarkAsReadEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

MessageMarkAsReadEntity messageMarkAsReadEntityFromJson(String str) =>
    MessageMarkAsReadEntity.fromJson(json.decode(str));

String messageMarkAsReadEntityToJson(MessageMarkAsReadEntity data) =>
    json.encode(data.toJson());

class MessageMarkAsReadEntity extends Equatable {
  final bool? error;
  final String? message;
  final int? code;

  const MessageMarkAsReadEntity({
    this.error,
    this.message,
    this.code,
  });

  factory MessageMarkAsReadEntity.fromJson(Map<String, dynamic> json) =>
      MessageMarkAsReadEntity(
        error: json["error"],
        message: json["message"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "code": code,
      };

  @override
  List<Object?> get props => [
        error,
        message,
        code,
      ];
}
