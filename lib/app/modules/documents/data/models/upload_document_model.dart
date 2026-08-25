// To parse this JSON data, do
//
//     final uploadDocumentModel = uploadDocumentModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

class UploadDocumentModel {
  int? id;
  String? expirationDate;
  String? document;
  String? extension;
  bool? hasExpiration;
  File? file;

  // Cached when the file is chosen so the card needs no disk I/O on rebuild.
  String? fileName;
  String? fileSizeLabel;

  UploadDocumentModel({
    this.id,
    this.expirationDate,
    this.document,
    this.extension,
    this.hasExpiration,
  });

  UploadDocumentModel copyWith({
    int? id,
    String? fileType,
    String? expirationDate,
    String? document,
    String? extension,
    bool? hasExpiration,
  }) =>
      UploadDocumentModel(
        id: id ?? this.id,
        expirationDate: expirationDate ?? this.expirationDate,
        document: document ?? this.document,
        extension: extension ?? this.extension,
        hasExpiration: hasExpiration ?? this.hasExpiration,
      );

  factory UploadDocumentModel.fromRawJson(String str) =>
      UploadDocumentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadDocumentModel.fromJson(Map<String, dynamic> json) =>
      UploadDocumentModel(
        id: json["id"],
        expirationDate: json["expiration_date"],
        document: json["base64_document"],
        extension: json["file_extension"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "expiration_date": expirationDate,
        "file_extension": extension,
        "base64_document": document,
      };
}
