// To parse this JSON data, do
//
//     final videoModel = videoModelFromJson(jsonString);

import 'dart:convert';

import '../../domain/entities/video_entity.dart';

// ignore: must_be_immutable
class VideoModel extends VideoEntity {
  VideoModel({
    super.id,
    super.title,
    super.description,
    super.categories,
    super.videoFile,
    super.videoThumb,
    super.time,
    super.totalLength,
    super.startDate,
    super.isWatched,
    super.finishDate,
  });

  factory VideoModel.fromRawJson(String str) =>
      VideoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  //todo: check this > changed varbile name from sneake case  to camel case
  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        categories: json["categories"] == null
            ? []
            : List<String>.from(json["categories"]!.map((x) => x)),
        videoFile: json["videoFile"],
        videoThumb: json["videoThumb"],
        time: json["time"],
        startDate: json["startDate"],
        isWatched: json["finishDate"] == null ? false : true,
        finishDate: json["finishDate"],
        totalLength: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x)),
        "videoFile": videoFile,
        "videoThumb": videoThumb,
        "time": time,
        "startDate": startDate!,
        "isWatched": isWatched,
        "finishDate": finishDate!,
        "totalLength": totalLength
      };
}
