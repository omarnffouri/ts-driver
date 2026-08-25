// To parse this JSON data, do
//
//     final signedFormUrlModel = signedFormUrlModelFromJson(jsonString);

import 'package:ts_driver/app/modules/forms/domain/entities/signed_form_entity.dart';

class SignedFormModel extends SignedFormEntity {
  const SignedFormModel({
    super.formName,
    super.signedFormUrl,
    super.createdAt,
    super.signedAt,
  });

  factory SignedFormModel.fromJson(Map<String, dynamic> json) =>
      SignedFormModel(
        formName: json["form_name"],
        signedFormUrl: json["signed_form"],
        createdAt: json["created_at"],
        signedAt: json["signed_at"],
      );

  Map<String, dynamic> toJson() => {
        "form_name": formName,
        "signed_form": signedFormUrl,
        "created_at": createdAt,
        "signed_at": signedAt,
      };
}
