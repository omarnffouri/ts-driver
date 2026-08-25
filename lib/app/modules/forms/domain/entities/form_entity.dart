import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormEntity extends Equatable {
  FormEntity({
    this.formId,
    this.applicantFormId,
    this.formName,
    this.formFields,
    this.formKey,
    this.isSigned,
    required this.attachments,
    required this.videos,
    required this.otherDocuments,
  });

  final int? formId;
  final int? applicantFormId;
  final String? formName;
  final List<FormFieldEntity>? formFields;
  final RxList<FormAttachmentEntity> attachments;
  final RxList<FormAttachmentEntity> otherDocuments;
  final RxList<FormAttachmentEntity> videos;
  final String? formKey;
  final bool? isSigned;
  final GlobalKey<FormState> formGlobalKey = GlobalKey<FormState>();

  FormEntity copyWith({
    int? formId,
    int? applicantFormId,
    String? formName,
    List<FormFieldEntity>? formFields,
    String? formKey,
    bool? isSigned,
    RxList<FormAttachmentEntity>? attachments,
    RxList<FormAttachmentEntity>? videos,
    RxList<FormAttachmentEntity>? otherDocuments,
  }) =>
      FormEntity(
        formId: formId ?? this.formId,
        applicantFormId: applicantFormId ?? this.applicantFormId,
        formName: formName ?? this.formName,
        formFields: formFields ?? this.formFields,
        formKey: formKey ?? this.formKey,
        isSigned: isSigned ?? this.isSigned,
        attachments: attachments ?? this.attachments,
        videos: videos ?? this.videos,
        otherDocuments: otherDocuments ?? this.otherDocuments,
      );

  String toRawEntity() => json.encode(toEntity());

  Map<String, dynamic> toEntity() => {
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

  @override
  List<Object?> get props => [
        formId,
        applicantFormId,
        formName,
        formFields,
        formKey,
        isSigned,
        attachments,
        videos,
        otherDocuments,
      ];
}

class FormFieldEntity extends Equatable {
  FormFieldEntity({
    this.fieldId,
    this.type,
    this.label,
    this.value,
    this.autoFill,
    this.isRequired,
    this.formFieldsValue,
  });

  final int? fieldId;
  final String? type;
  final String? label;
  final int? value;
  final dynamic autoFill;
  final int? isRequired;
  final FormFieldsValueEntity? formFieldsValue;
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  FormFieldEntity copyWith({
    int? fieldId,
    String? type,
    String? label,
    int? value,
    dynamic autoFill,
    int? isRequired,
    FormFieldsValueEntity? formFieldsValue,
  }) =>
      FormFieldEntity(
        fieldId: fieldId ?? this.fieldId,
        type: type ?? this.type,
        label: label ?? this.label,
        value: value ?? this.value,
        autoFill: autoFill ?? this.autoFill,
        isRequired: isRequired ?? this.isRequired,
        formFieldsValue: formFieldsValue ?? this.formFieldsValue,
      );

  Map<String, dynamic> toEntity() => {
        "field_id": fieldId,
        "type": type,
        "label": label,
        "value": value,
        "auto_fill": autoFill,
        "is_required": isRequired,
        "form_fields_value": formFieldsValue?.toEntity(),
      };

  @override
  List<Object?> get props => [
        fieldId,
        type,
        label,
        value,
        autoFill,
        isRequired,
        formFieldsValue,
      ];
}

class FormFieldsValueEntity extends Equatable {
  const FormFieldsValueEntity({
    this.id,
    this.applicantFormId,
    this.formFieldId,
    required this.value,
    this.createdAt,
    this.updatedAt,
    this.title,
  });

  final int? id;
  final int? applicantFormId;
  final int? formFieldId;
  final String value;
  final String? createdAt;
  final String? updatedAt;
  final int? title;

  FormFieldsValueEntity copyWith({
    int? id,
    int? applicantFormId,
    int? formFieldId,
    String? value,
    String? createdAt,
    String? updatedAt,
    int? title,
  }) =>
      FormFieldsValueEntity(
        id: id ?? this.id,
        applicantFormId: applicantFormId ?? this.applicantFormId,
        formFieldId: formFieldId ?? this.formFieldId,
        value: value ?? this.value,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        title: title ?? this.title,
      );

  String toRawEntity() => json.encode(toEntity());

  Map<String, dynamic> toEntity() => {
        "id": id,
        "applicant_form_id": applicantFormId,
        "form_field_id": formFieldId,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "title": title,
      };

  @override
  List<Object?> get props => [
        id,
        applicantFormId,
        formFieldId,
        value,
        createdAt,
        updatedAt,
        title,
      ];
}

// ignore: must_be_immutable
class FormAttachmentEntity extends Equatable {
  final int? id;
  DateTime? seenAt;
  final String? url;
  final String? title;

  FormAttachmentEntity({
    this.id,
    this.seenAt,
    this.url,
    this.title,
  });

  factory FormAttachmentEntity.fromJson(Map<String, dynamic> json) =>
      FormAttachmentEntity(
        id: json["id"],
        seenAt: json["seen_at"] == null
            ? null
            : DateTime.parse(json["seen_at"])
                .add(DateTime.now().timeZoneOffset),
        url: json["url"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "seen_at": seenAt?.toIso8601String(),
        "url": url,
        "title": title,
      };

  @override
  List<Object?> get props => [
        id,
        seenAt,
        url,
        title,
      ];
}
