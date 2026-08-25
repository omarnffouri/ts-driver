// To parse this JSON data, do
//
//     final applicationState = applicationStateFromJson(jsonString);

import 'dart:convert';

class ApplicationState {
  int? id;
  String? name;
  String? createdAt;
  bool isSelected = false;

  ApplicationState({
    this.id,
    this.name,
    this.createdAt,
    required this.isSelected,
  });

  ApplicationState copyWith({
    int? id,
    String? name,
    String? createdAt,
    bool? isSelected,
  }) =>
      ApplicationState(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        isSelected: isSelected ?? this.isSelected,
      );

  factory ApplicationState.fromRawJson(String str) =>
      ApplicationState.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ApplicationState.fromJson(Map<String, dynamic> json) =>
      ApplicationState(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"],
        isSelected: json["isSelected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt,
        "isSelected": isSelected,
      };
}
