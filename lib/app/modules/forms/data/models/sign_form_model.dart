// To parse this JSON data, do
//
//     final signFormModel = signFormModelFromJson(jsonString);

import 'dart:convert';

import '../../domain/entities/sign_form_entity.dart';

class SignFormModel extends SignFormEntity {
  const SignFormModel({
    super.formData,
    super.formId,
    super.applicantId,
    super.applicantFormId,
    super.signature,
  });

  factory SignFormModel.fromRawJson(String str) =>
      SignFormModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SignFormModel.fromJson(Map<String, dynamic> json) => SignFormModel(
        formData: json["form_data"] == null
            ? []
            : List<FormDatum>.from(
                json["form_data"]!.map((x) => FormDatum.fromJson(x))),
        formId: json["form_id"],
        applicantId: json["applicant_id"],
        applicantFormId: json["applicant_form_id"],
        signature: json["signature"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "form_data": formData == null
            ? []
            : List<dynamic>.from(formData!.map((x) => x.toEntity())),
        "form_id": formId,
        "applicant_id": applicantId,
        "applicant_form_id": applicantFormId,
        "signature": signature,
      };
}

class FormDatum extends FormDatumEntity {
  const FormDatum({
    super.fieldId,
    super.value,
  });

  factory FormDatum.fromRawJson(String str) =>
      FormDatum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toEntity());

  factory FormDatum.fromJson(Map<String, dynamic> json) => FormDatum(
        fieldId: json["field_id"],
        value: json["value"],
      );

  @override
  Map<String, dynamic> toEntity() => {
        "field_id": fieldId,
        "value": value,
      };
}
