// To parse this JSON data, do
//
//     final trailerModel = trailerModelFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

TrailerEntity trailerModelFromJson(String str) =>
    TrailerEntity.fromJson(json.decode(str));

String trailerModelToJson(TrailerEntity data) => json.encode(data.toJson());

class TrailerEntity extends Equatable {
  final int? id;
  final int? identifier;
  final String? titleNumber;
  final String? licencePlateNumber;
  final List<MediaEntity>? media;

  const TrailerEntity({
    this.id,
    this.identifier,
    this.titleNumber,
    this.licencePlateNumber,
    this.media,
  });

  TrailerEntity copyWith({
    int? id,
    int? identifier,
    String? titleNumber,
    String? licencePlateNumber,
    List<MediaEntity>? media,
  }) =>
      TrailerEntity(
        id: id ?? this.id,
        identifier: identifier ?? this.identifier,
        titleNumber: titleNumber ?? this.titleNumber,
        licencePlateNumber: licencePlateNumber ?? this.licencePlateNumber,
        media: media ?? this.media,
      );

  factory TrailerEntity.fromJson(Map<String, dynamic> json) => TrailerEntity(
        id: json["id"],
        identifier: json["identifier"],
        titleNumber: json["title_number"],
        licencePlateNumber: json["licence_plate_number"],
        media: json["media"] == null
            ? []
            : List<MediaEntity>.from(
                json["media"]!.map((x) => MediaEntity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "identifier": identifier,
        "title_number": titleNumber,
        "licence_plate_number": licencePlateNumber,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [
        id,
        identifier,
        titleNumber,
        licencePlateNumber,
        media,
      ];
}

class MediaEntity extends Equatable {
  final String? name;
  final String? path;

  const MediaEntity({
    this.name,
    this.path,
  });

  MediaEntity copyWith({
    String? name,
    String? path,
  }) =>
      MediaEntity(
        name: name ?? this.name,
        path: path ?? this.path,
      );

  factory MediaEntity.fromJson(Map<String, dynamic> json) => MediaEntity(
        name: json["name"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "path": path,
      };

  @override
  List<Object?> get props => [
        name,
        path,
      ];
}
