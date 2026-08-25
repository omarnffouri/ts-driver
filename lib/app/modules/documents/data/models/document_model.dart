// To parse this JSON data, do
//
//     final documentModel = documentModelFromJson(jsonString);

// ignore_for_file: overridden_fields, annotate_overrides

import 'dart:convert';

import '../../domain/entities/document_entity.dart';

// ignore: must_be_immutable
class DocumentModel extends DocumentEntity {
  DocumentModel({
    required super.id,
    required super.message,
    required super.fileName,
    required super.createdAt,
    required super.requiredDocument,
  });

  DocumentModel copyWith({
    String? id,
    String? message,
    String? fileName,
    String? createdAt,
    RequiredDocument? requiredDocument,
  }) =>
      DocumentModel(
        id: id ?? this.id,
        message: message ?? this.message,
        fileName: fileName ?? this.fileName,
        createdAt: createdAt ?? this.createdAt,
        requiredDocument: requiredDocument ?? this.requiredDocument,
      );

  factory DocumentModel.fromRawJson(String str) =>
      DocumentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json["id"].toString(),
        message: json["message"],
        fileName: json["file_name"],
        createdAt: json["created_at"],
        requiredDocument: json["required_document"] == null
            ? null
            : RequiredDocument.fromJson(json["required_document"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "file_name": fileName,
        "created_at": createdAt,
        "required_document": requiredDocument?.toEntity(),
      };
}

class RequiredDocument extends RequiredDocumentEntity {
  const RequiredDocument({
    required super.id,
    required super.fileType,
    required super.fileName,
    required super.hasExpiration,
  });

  RequiredDocument copyWith({
    int? id,
    String? fileType,
    String? fileName,
    bool? hasExpiration,
  }) =>
      RequiredDocument(
        id: id ?? this.id,
        fileType: fileType ?? this.fileType,
        fileName: fileName ?? this.fileName,
        hasExpiration: hasExpiration ?? this.hasExpiration,
      );

  factory RequiredDocument.fromRawJson(String str) =>
      RequiredDocument.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RequiredDocument.fromJson(Map<String, dynamic> json) =>
      RequiredDocument(
        id: json["id"],
        fileType: json["file_type"],
        fileName: json["file_name"],
        hasExpiration: json["has_expiration"] == null
            ? null
            : json["has_expiration"] == 0
                ? false
                : true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_type": fileType,
        "file_name": fileName,
        "has_expiration": hasExpiration,
      };
}
