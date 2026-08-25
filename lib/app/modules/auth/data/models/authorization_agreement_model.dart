// To parse this JSON data, do
//
//     final authorizationAgreement = authorizationAgreementFromJson(jsonString);

import 'dart:convert';

class AuthorizationAgreement {
  AuthorizationAgreement({
    this.title,
    this.isChecked,
  });

  String? title;
  bool? isChecked;

  AuthorizationAgreement copyWith({
    String? title,
    bool? isChecked,
  }) =>
      AuthorizationAgreement(
        title: title ?? this.title,
        isChecked: isChecked ?? this.isChecked,
      );

  factory AuthorizationAgreement.fromRawJson(String str) =>
      AuthorizationAgreement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthorizationAgreement.fromJson(Map<String, dynamic> json) =>
      AuthorizationAgreement(
        title: json["title"],
        isChecked: json["isChecked"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "isChecked": isChecked,
      };
}
