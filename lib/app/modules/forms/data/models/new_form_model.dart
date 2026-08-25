// To parse this JSON data, do
//
//     final newFormModel = newFormModelFromJson(jsonString);

import 'dart:convert';

import 'package:ts_driver/app/modules/forms/domain/entities/new_form_entity.dart';

NewFormModel newFormModelFromJson(String str) =>
    NewFormModel.fromJson(json.decode(str));

String newFormModelToJson(NewFormModel data) => json.encode(data.toJson());

class NewFormModel extends NewFormEntity {
  const NewFormModel({
    super.components,
    super.type,
    super.id,
    super.schemaVersion,
  });

  factory NewFormModel.fromJson(Map<String, dynamic> json) => NewFormModel(
        components: json["components"] == null
            ? []
            : List<Component>.from(
                json["components"]!.map((x) => Component.fromJson(x))),
        type: json["type"],
        id: json["id"],
        schemaVersion: json["schemaVersion"],
      );

  Map<String, dynamic> toJson() => {
        "components": components == null
            ? []
            : List<dynamic>.from(components!.map((x) => x.toJson())),
        "type": type,
        "id": id,
        "schemaVersion": schemaVersion,
      };
}

class Component extends ComponentEntity {
  const Component({
    super.text,
    super.type,
    super.layout,
    super.id,
    super.label,
    super.key,
    super.values,
    super.validate,
    super.bycompany,
  });

  factory Component.fromJson(Map<String, dynamic> json) => Component(
        text: json["text"],
        type: json["type"],
        layout: json["layout"] == null ? null : Layout.fromJson(json["layout"]),
        id: json["id"],
        label: json["label"],
        key: json["key"],
        values: json["values"] == null
            ? []
            : List<ValueElement>.from(
                json["values"]!.map((x) => ValueElement.fromJson(x))),
        validate: json["validate"] == null
            ? null
            : Validate.fromJson(json["validate"]),
        bycompany: json["bycompany"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "text": text,
        "type": type,
        "layout": layout?.toJson(),
        "id": id,
        "label": label,
        "key": key,
        "values": values == null
            ? []
            : List<dynamic>.from(values!.map((x) => x.toJson())),
        "validate": validate?.toJson(),
        "bycompany": bycompany,
      };
}

class Layout extends LayoutEntity {
  const Layout({
    super.row,
    super.columns,
  });

  factory Layout.fromJson(Map<String, dynamic> json) => Layout(
        row: json["row"],
        columns: json["columns"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "row": row,
        "columns": columns,
      };
}

class Validate extends ValidateEntity {
  const Validate({
    super.required,
  });

  factory Validate.fromJson(Map<String, dynamic> json) => Validate(
        required: json["required"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "required": required,
      };
}

class ValueElement extends ValueEntity {
  ValueElement({
    super.label,
    super.value,
  });

  factory ValueElement.fromJson(Map<String, dynamic> json) => ValueElement(
        label: json["label"],
        value: json["value"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "label": label,
        "value": value,
      };
}
