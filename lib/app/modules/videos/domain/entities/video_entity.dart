import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class VideoEntity extends Equatable {
  VideoEntity({
    this.id,
    this.title,
    this.description,
    this.categories,
    this.videoFile,
    this.videoThumb,
    this.time,
    this.totalLength,
    this.startDate,
    this.isWatched,
    this.finishDate,
    this.timeWatched,
  });

  final int? id;
  final String? title;
  final String? description;
  final List<String>? categories;
  final String? videoFile;
  final String? videoThumb;
  int? time;
  final String? startDate;
  bool? isWatched;
  final String? finishDate;
  final int? timeWatched;
  final int? totalLength;

  String get firstCategory =>
      (categories?.isNotEmpty ?? false) ? categories!.first : '';

  double get watchedFraction {
    final total = totalLength ?? 0;
    return total == 0 ? 0 : (time ?? 0) / total;
  }

  VideoEntity copyWith({
    int? id,
    String? title,
    String? description,
    List<String>? categories,
    String? videoFile,
    String? videoThumb,
    int? time,
    String? startDate,
    bool? isWatched,
    String? finishDate,
    int? totalLength,
  }) =>
      VideoEntity(
        id: id ?? this.id,
        title: title ?? title,
        description: description ?? this.description,
        categories: categories ?? this.categories,
        videoFile: videoFile ?? this.videoFile,
        videoThumb: videoThumb ?? this.videoThumb,
        time: time ?? this.time,
        startDate: startDate ?? this.startDate,
        isWatched: isWatched ?? this.isWatched,
        finishDate: finishDate ?? this.finishDate,
        totalLength: totalLength ?? this.totalLength,
      );

  //todo: check this > changed varbile name from sneake case  to camel case
  factory VideoEntity.fromEntity(Map<String, dynamic> json) => VideoEntity(
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

  Map<String, dynamic> toEntity() => {
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

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categories,
        videoFile,
        videoThumb,
        time,
        startDate,
        isWatched,
        finishDate,
        timeWatched,
        totalLength
      ];
}
