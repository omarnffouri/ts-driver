import 'dart:convert';

import '../../domain/entities/trailer_entity.dart';

TrailerModel trailerModelFromJson(String str) =>
    TrailerModel.fromJson(json.decode(str));

String trailerModelToJson(TrailerModel data) => json.encode(data.toJson());

class TrailerModel extends TrailerEntity {
  const TrailerModel({
    super.id,
    super.identifier,
    super.titleNumber,
    super.licencePlateNumber,
    super.media,
  });

  factory TrailerModel.fromJson(Map<String, dynamic> json) => TrailerModel(
        id: json["id"],
        identifier: json["identifier"],
        titleNumber: json["title_number"],
        licencePlateNumber: json["licence_plate_number"],
        media: json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "identifier": identifier,
        "title_number": titleNumber,
        "licence_plate_number": licencePlateNumber,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };
}

class Media extends MediaEntity {
  const Media({
    super.name,
    super.path,
  });

  @override
  Media copyWith({
    String? name,
    String? path,
  }) =>
      Media(
        name: name ?? this.name,
        path: path ?? this.path,
      );

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        name: json["name"],
        path: json["path"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        "path": path,
      };
}
