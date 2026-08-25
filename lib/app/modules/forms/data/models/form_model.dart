// To parse this JSON data, do
//
//     final formModel = formModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

import '../../domain/entities/form_entity.dart';

class FormModel extends FormEntity {
  FormModel({
    super.formId,
    super.applicantFormId,
    super.formName,
    super.formFields,
    super.formKey,
    super.isSigned,
    required super.attachments,
    required super.videos,
    required super.otherDocuments,
  });

  factory FormModel.fromRawJson(String str) =>
      FormModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
        formId: json["form_id"],
        formKey: json["form_id"].toString(),
        applicantFormId: json["applicant_form_id"],
        formName: json["form_name"],
        formFields: json["form_fields"] == null
            ? []
            : List<FormField>.from(
                json["form_fields"]!.map((x) => FormField.fromJson(x))),
        isSigned: json["is_signed"],
        attachments: json["attachments"] == null
            ? RxList()
            : RxList<FormAttachmentModel>.from(json["attachments"]!
                .map((x) => FormAttachmentModel.fromJson(x))),
        videos: json["videos"] == null
            ? RxList()
            : RxList<FormAttachmentModel>.from(
                json["videos"]!.map((x) => FormAttachmentModel.fromJson(x))),
        otherDocuments: json["other_documents"] == null
            ? RxList()
            : RxList<FormAttachmentModel>.from(json["other_documents"]!
                .map((x) => FormAttachmentModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "form_id": formId,
        "applicant_form_id": applicantFormId,
        "form_name": formName,
        "is_signed": isSigned,
        "form_fields": formFields == null
            ? []
            : List<dynamic>.from(formFields!.map((x) => x.toEntity())),
        "attachments": List<dynamic>.from(attachments.map((x) => x.toJson())),
        "videos": List<dynamic>.from(videos.map((x) => x.toJson())),
        "other_documents":
            List<dynamic>.from(otherDocuments.map((x) => x.toJson())),
      };
}

class FormField extends FormFieldEntity {
  FormField({
    super.fieldId,
    super.type,
    super.label,
    super.value,
    super.autoFill,
    super.isRequired,
    super.formFieldsValue,
  });

  factory FormField.fromRawJson(String str) =>
      FormField.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FormField.fromJson(Map<String, dynamic> json) => FormField(
        fieldId: json["field_id"],
        type: json["type"],
        label: json["label"],
        value: json["value"],
        autoFill: json["auto_fill"],
        isRequired: json["is_required"],
        formFieldsValue: json['form_fields_value'] != null &&
                json['form_fields_value'].isNotEmpty
            ? FormFieldsValue.fromJson(json['form_fields_value'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "field_id": fieldId,
        "type": type,
        "label": label,
        "value": value,
        "auto_fill": autoFill,
        "is_required": isRequired,
        "form_fields_value": formFieldsValue?.toEntity(),
      };
}

class FormFieldsValue extends FormFieldsValueEntity {
  const FormFieldsValue({
    super.id,
    super.applicantFormId,
    super.formFieldId,
    required super.value,
    super.createdAt,
    super.updatedAt,
    super.title,
  });

  factory FormFieldsValue.fromRawJson(String str) =>
      FormFieldsValue.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FormFieldsValue.fromJson(Map<String, dynamic> json) =>
      FormFieldsValue(
        id: json["id"],
        applicantFormId: json["applicant_form_id"],
        formFieldId: json["form_field_id"],
        value: json["value"].toString(),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "applicant_form_id": applicantFormId,
        "form_field_id": formFieldId,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "title": title,
      };
}

// ignore: must_be_immutable
class FormAttachmentModel extends FormAttachmentEntity {
  FormAttachmentModel({
    super.id,
    super.seenAt,
    super.url,
    super.title,
  });

  factory FormAttachmentModel.fromJson(Map<String, dynamic> json) =>
      FormAttachmentModel(
        id: json["id"],
        seenAt: json["seen_at"] == null
            ? null
            : DateTime.parse(json["seen_at"])
                .add(DateTime.now().timeZoneOffset),
        url: json["url"],
        title: json["title"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "seen_at": seenAt?.toIso8601String(),
        "url": url,
        "title": title,
      };
}
