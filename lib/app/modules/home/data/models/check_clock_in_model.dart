import 'dart:convert';

import 'package:ts_driver/app/modules/home/domain/entities/check_clock_in_entity.dart';

CheckClockInDataModel checkClockInDataModelFromJson(String str) =>
    CheckClockInDataModel.fromJson(json.decode(str));

String checkClockInDataModelToJson(CheckClockInDataModel data) =>
    json.encode(data.toJson());

class CheckClockInDataModel extends CheckClockInDataEntity {
  const CheckClockInDataModel({
    super.autoStart,
    super.clockedIn,
    super.date,
    super.startStopWatchFrom,
  });

  factory CheckClockInDataModel.fromJson(Map<String, dynamic> json) =>
      CheckClockInDataModel(
        autoStart: json["autoStart"],
        clockedIn: json["clockedIn"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        // API may send this as a double (e.g. 46.0); coerce to int.
        startStopWatchFrom: (json["startStopWatchFrom"] as num?)?.toInt(),
      );

  @override
  Map<String, dynamic> toJson() => {
        "autoStart": autoStart,
        "clockedIn": clockedIn,
        "date": date?.toIso8601String(),
        "startStopWatchFrom": startStopWatchFrom,
      };
}
