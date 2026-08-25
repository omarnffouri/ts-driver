import 'dart:convert';

import '../../domain/entities/create_inspection_response_entity.dart';

CreateInspectionResponseModel createInspectionResponseModelFromJson(
        String str) =>
    CreateInspectionResponseModel.fromJson(json.decode(str));

class CreateInspectionResponseModel extends CreateInspectionResponseEntity {
  const CreateInspectionResponseModel({
    super.code,
    super.status,
    super.message,
    super.payload,
  });

  factory CreateInspectionResponseModel.fromJson(Map<String, dynamic> json) =>
      CreateInspectionResponseModel(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        payload: json["payload"] == null
            ? []
            : List<dynamic>.from(json["payload"]!.map((x) => x)),
      );
}
