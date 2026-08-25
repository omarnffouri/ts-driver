// To parse this JSON data, do
//
//     final formModel = formModelFromJson(jsonString);

import 'dart:convert';

class FormModel {
  FormModel({
    this.formId,
    this.applicantFormId,
    this.formName,
    this.formFields,
    this.formKey,
    this.isSigned,
  });

  int? formId;
  int? applicantFormId;
  String? formName;
  List<FormField>? formFields;
  String? formKey;
  bool? isSigned;

  FormModel copyWith({
    int? formId,
    int? applicantFormId,
    String? formName,
    List<FormField>? formFields,
    String? formKey,
    bool? isSigned,
  }) =>
      FormModel(
        formId: formId ?? this.formId,
        applicantFormId: applicantFormId ?? this.applicantFormId,
        formName: formName ?? this.formName,
        formFields: formFields ?? this.formFields,
        formKey: formKey ?? this.formKey,
        isSigned: isSigned ?? this.isSigned,
      );

  factory FormModel.fromRawJson(String str) =>
      FormModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
        formId: json["formID"],
        formKey: json["formID"].toString(),
        applicantFormId: json["applicantFormID"],
        formName: json["form_name"],
        formFields: json["form_fields"] == null
            ? []
            : List<FormField>.from(
                json["form_fields"]!.map((x) => FormField.fromJson(x))),
        isSigned: json["is_signed"],
      );

  Map<String, dynamic> toJson() => {
        "formID": formId,
        "applicantFormID": applicantFormId,
        "form_name": formName,
        "is_signed": isSigned,
        "form_fields": formFields == null
            ? []
            : List<dynamic>.from(formFields!.map((x) => x.toJson())),
      };
}

class FormField {
  FormField({
    this.fieldId,
    this.type,
    this.label,
    this.value,
    this.autoFill,
    this.isRequired,
    this.formFieldsValue,
  });

  int? fieldId;
  String? type;
  String? label;
  int? value;
  dynamic autoFill;
  int? isRequired;
  FormFieldsValue? formFieldsValue;

  FormField copyWith({
    int? fieldId,
    String? type,
    String? label,
    int? value,
    dynamic autoFill,
    int? isRequired,
    FormFieldsValue? formFieldsValue,
  }) =>
      FormField(
        fieldId: fieldId ?? this.fieldId,
        type: type ?? this.type,
        label: label ?? this.label,
        value: value ?? this.value,
        autoFill: autoFill ?? this.autoFill,
        isRequired: isRequired ?? this.isRequired,
        formFieldsValue: formFieldsValue ?? this.formFieldsValue,
      );

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
        formFieldsValue: json["form_fields_value"] == null
            ? null
            : FormFieldsValue.fromJson(json["form_fields_value"]),
      );

  Map<String, dynamic> toJson() => {
        "field_id": fieldId,
        "type": type,
        "label": label,
        "value": value,
        "auto_fill": autoFill,
        "is_required": isRequired,
        "form_fields_value": formFieldsValue?.toJson(),
      };
}

class FormFieldsValue {
  FormFieldsValue({
    this.id,
    this.applicantFormId,
    this.formFieldId,
    this.value,
    this.createdAt,
    this.updatedAt,
    this.title,
  });

  int? id;
  int? applicantFormId;
  int? formFieldId;
  String? value;
  String? createdAt;
  String? updatedAt;
  int? title;

  FormFieldsValue copyWith({
    int? id,
    int? applicantFormId,
    int? formFieldId,
    String? value,
    String? createdAt,
    String? updatedAt,
    int? title,
  }) =>
      FormFieldsValue(
        id: id ?? this.id,
        applicantFormId: applicantFormId ?? this.applicantFormId,
        formFieldId: formFieldId ?? this.formFieldId,
        value: value ?? this.value,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        title: title ?? this.title,
      );

  factory FormFieldsValue.fromRawJson(String str) =>
      FormFieldsValue.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FormFieldsValue.fromJson(Map<String, dynamic> json) =>
      FormFieldsValue(
        id: json["id"],
        applicantFormId: json["applicant_form_id"],
        formFieldId: json["form_field_id"],
        value: json["value"],
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
