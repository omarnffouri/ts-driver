// To parse this JSON data, do
//
//     final newFormModel = newFormModelFromJson(jsonString);

import 'package:equatable/equatable.dart';

class NewFormEntity extends Equatable {
  final List<ComponentEntity>? components;
  final String? type;
  final String? formKey;
  final String? id;
  final bool? isSigned;
  final int? schemaVersion;

  const NewFormEntity({
    this.components,
    this.type,
    this.formKey,
    this.isSigned,
    this.id,
    this.schemaVersion,
  });

  factory NewFormEntity.fromEntity(Map<String, dynamic> json) => NewFormEntity(
        components: json["components"] == null
            ? []
            : List<ComponentEntity>.from(
                json["components"]!.map((x) => ComponentEntity.fromJson(x))),
        type: json["type"],
        id: json["id"],
        formKey: json["id"].toString(),
        schemaVersion: json["schemaVersion"],
      );

  Map<String, dynamic> toEntity() => {
        "components": components == null
            ? []
            : List<dynamic>.from(components!.map((x) => x.toJson())),
        "type": type,
        "id": id,
        "schemaVersion": schemaVersion,
      };

  @override
  List<Object?> get props => [components, type, id, schemaVersion];
}

class ComponentEntity extends Equatable {
  final String? text;
  final String? type;
  final LayoutEntity? layout;
  final String? id;
  final String? label;
  final String? key;
  final List<ValueEntity>? values;
  final ValidateEntity? validate;
  final bool? bycompany;

  const ComponentEntity({
    this.text,
    this.type,
    this.layout,
    this.id,
    this.label,
    this.key,
    this.values,
    this.validate,
    this.bycompany,
  });

  factory ComponentEntity.fromJson(Map<String, dynamic> json) =>
      ComponentEntity(
        text: json["text"],
        type: json["type"],
        layout: json["layout"] == null
            ? null
            : LayoutEntity.fromJson(json["layout"]),
        id: json["id"],
        label: json["label"],
        key: json["key"],
        values: json["values"] == null
            ? []
            : List<ValueEntity>.from(
                json["values"]!.map((x) => ValueEntity.fromJson(x))),
        validate: json["validate"] == null
            ? null
            : ValidateEntity.fromJson(json["validate"]),
        bycompany: json["bycompany"],
      );

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

  @override
  List<Object?> get props => [
        text,
        type,
        layout,
        id,
        label,
        key,
        values,
        validate,
        bycompany,
      ];
}

class LayoutEntity extends Equatable {
  final String? row;
  final dynamic columns;

  const LayoutEntity({
    this.row,
    this.columns,
  });

  factory LayoutEntity.fromJson(Map<String, dynamic> json) => LayoutEntity(
        row: json["row"],
        columns: json["columns"],
      );

  Map<String, dynamic> toJson() => {
        "row": row,
        "columns": columns,
      };

  @override
  List<Object?> get props => [row, columns];
}

class ValidateEntity extends Equatable {
  final bool? required;

  const ValidateEntity({
    this.required,
  });

  factory ValidateEntity.fromJson(Map<String, dynamic> json) => ValidateEntity(
        required: json["required"],
      );

  Map<String, dynamic> toJson() => {
        "required": required,
      };

  @override
  List<Object?> get props => [required];
}

class ValueEntity {
  final String? label;
  final String? value;

  ValueEntity({
    this.label,
    this.value,
  });

  factory ValueEntity.fromJson(Map<String, dynamic> json) => ValueEntity(
        label: json["label"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "value": value,
      };
}
