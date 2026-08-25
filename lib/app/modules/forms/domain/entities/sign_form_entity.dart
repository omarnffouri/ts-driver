// To parse this JSON data, do
//
//     final signFormModel = signFormModelFromJson(jsonString);

import 'package:equatable/equatable.dart';

class SignFormEntity extends Equatable {
  const SignFormEntity({
    this.formData,
    this.formId,
    this.applicantId,
    this.applicantFormId,
    this.signature,
  });

  final List<FormDatumEntity>? formData;
  final int? formId;
  final int? applicantId;
  final int? applicantFormId;
  final String? signature;

  SignFormEntity copyWith({
    List<FormDatumEntity>? formData,
    int? formId,
    int? applicantId,
    int? applicantFormId,
    String? signature,
  }) =>
      SignFormEntity(
        formData: formData ?? this.formData,
        formId: formId ?? this.formId,
        applicantId: applicantId ?? this.applicantId,
        applicantFormId: applicantFormId ?? this.applicantFormId,
        signature: signature ?? this.signature,
      );

  @override
  List<Object?> get props => [
        formData,
        formId,
        applicantId,
        applicantFormId,
        signature,
      ];

  factory SignFormEntity.fromEntity(Map<String, dynamic> json) =>
      SignFormEntity(
        formData: json["form_data"] == null
            ? []
            : List<FormDatumEntity>.from(
                json["form_data"]!.map((x) => FormDatumEntity.fromJson(x))),
        formId: json["form_id"],
        applicantId: json["applicant_id"],
        applicantFormId: json["applicant_form_id"],
        signature: json["signature"],
      );

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

class FormDatumEntity extends Equatable {
  const FormDatumEntity({
    this.fieldId,
    this.value,
  });

  final String? fieldId;
  final String? value;

  factory FormDatumEntity.fromJson(Map<String, dynamic> json) =>
      FormDatumEntity(
        fieldId: json["field_id"],
        value: json["value"],
      );

  Map<String, dynamic> toEntity() => {
        "field_id": fieldId,
        "value": value,
      };

  @override
  List<Object?> get props => [
        fieldId,
        value,
      ];
}
