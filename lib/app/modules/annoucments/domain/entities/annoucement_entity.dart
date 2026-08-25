import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class AnnoucementEntity extends Equatable {
  final int? id;
  final String? title;
  final String? message;
  final String? image;
  final String? type;
  int? read;
  final DateTime? createdAt;
  final int? value;

  AnnoucementEntity({
    this.id,
    this.title,
    this.message,
    this.image,
    this.type,
    this.read,
    this.createdAt,
    this.value,
  });

  AnnoucementEntity copyWith({
    int? id,
    String? title,
    String? message,
    String? image,
    String? type,
    int? read,
    DateTime? createdAt,
    int? value,
  }) =>
      AnnoucementEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        message: message ?? this.message,
        image: image ?? this.image,
        type: type ?? this.type,
        read: read ?? this.read,
        createdAt: createdAt ?? this.createdAt,
        value: value ?? this.value,
      );

  factory AnnoucementEntity.fromEntity(Map<String, dynamic> json) =>
      AnnoucementEntity(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        type: json["type"],
        read: json["read"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"])
                .add(DateTime.now().timeZoneOffset),
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "image": image,
        "type": type,
        "read": read,
        "created_at": createdAt?.toIso8601String(),
        "value": value,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        image,
        type,
        read,
        createdAt,
        value,
      ];
}
