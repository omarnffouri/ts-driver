// To parse this JSON data, do
//
//     final messageMarkAsReadEntity = messageMarkAsReadEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

ForwardMessageEntity forwardMessageEntityFromJson(String str) =>
    ForwardMessageEntity.fromJson(json.decode(str));

String forwardMessageEntityToJson(ForwardMessageEntity data) =>
    json.encode(data.toJson());

class ForwardMessageEntity extends Equatable {
  final bool? error;
  final String? message;
  final int? code;

  const ForwardMessageEntity({
    this.error,
    this.message,
    this.code,
  });

  factory ForwardMessageEntity.fromJson(Map<String, dynamic> json) =>
      ForwardMessageEntity(
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
