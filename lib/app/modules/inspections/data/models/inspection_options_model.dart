import 'dart:convert';

import '../../domain/entities/inspection_options_entity.dart';

InspectionOptionResponseModel inspectionOptionResponseModelFromJson(
        String str) =>
    InspectionOptionResponseModel.fromJson(json.decode(str));

class InspectionOptionResponseModel extends InspectionOptionResponseEntity {
  const InspectionOptionResponseModel({
    super.code,
    super.status,
    super.payload,
  });

  factory InspectionOptionResponseModel.fromJson(Map<String, dynamic> json) =>
      InspectionOptionResponseModel(
        code: json["code"],
        status: json["status"],
        payload: json["payload"] == null
            ? null
            : InpectionOptionsPayloadModel.fromJson(json["payload"]),
      );
}

class InpectionOptionsPayloadModel extends InpectionOptionsPayloadEntity {
  const InpectionOptionsPayloadModel({super.categories});

  factory InpectionOptionsPayloadModel.fromJson(Map<String, dynamic> json) =>
      InpectionOptionsPayloadModel(
        categories: json["categories"] == null
            ? []
            : List<InspectionOptionModel>.from(json["categories"]!
                .map((x) => InspectionOptionModel.fromJson(x))),
      );
}

class InspectionOptionModel extends InspectionOptionEntity {
  const InspectionOptionModel({super.id, super.name});

  factory InspectionOptionModel.fromJson(Map<String, dynamic> json) =>
      InspectionOptionModel(id: json["id"], name: json["name"]);
}
