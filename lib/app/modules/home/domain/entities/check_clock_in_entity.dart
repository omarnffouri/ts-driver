import 'dart:convert';

import 'package:equatable/equatable.dart';

CheckClockInDataEntity checkClockInDataEntityFromJson(String str) =>
    CheckClockInDataEntity.fromJson(json.decode(str));

String checkClockInDataEntityToJson(CheckClockInDataEntity data) =>
    json.encode(data.toJson());

class CheckClockInDataEntity extends Equatable {
  final bool? autoStart;
  final bool? clockedIn;
  final DateTime? date;
  final int? startStopWatchFrom;

  const CheckClockInDataEntity({
    this.autoStart,
    this.clockedIn,
    this.date,
    this.startStopWatchFrom,
  });

  factory CheckClockInDataEntity.fromJson(Map<String, dynamic> json) =>
      CheckClockInDataEntity(
        autoStart: json["autoStart"],
        clockedIn: json["clockedIn"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        startStopWatchFrom: (json["startStopWatchFrom"] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        "autoStart": autoStart,
        "clockedIn": clockedIn,
        "date": date?.toIso8601String(),
        "startStopWatchFrom": startStopWatchFrom,
      };

  @override
  List<Object?> get props => [autoStart, clockedIn, startStopWatchFrom, date];
}
