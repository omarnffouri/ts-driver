// To parse this JSON data, do
//
//     final weekDetailsEntity = weekDetailsEntityFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

WeekDetailsEntity weekDetailsEntityFromJson(String str) =>
    WeekDetailsEntity.fromJson(json.decode(str));

String weekDetailsEntityToJson(WeekDetailsEntity data) =>
    json.encode(data.toJson());

class WeekDetailsEntity extends Equatable {
  final String? message;
  final int? code;
  final WeekDataEntity? data;

  const WeekDetailsEntity({
    this.message,
    this.code,
    this.data,
  });

  factory WeekDetailsEntity.fromJson(Map<String, dynamic> json) =>
      WeekDetailsEntity(
        message: json["message"],
        code: json["code"],
        data:
            json["data"] == null ? null : WeekDataEntity.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "data": data?.toJson(),
      };

  @override
  List<Object?> get props => [
        message,
        code,
        data,
      ];
}

class WeekDataEntity extends Equatable {
  final List<ClockInOutSessionEntity>? mon;
  final List<ClockInOutSessionEntity>? tue;
  final List<ClockInOutSessionEntity>? wed;
  final List<ClockInOutSessionEntity>? thu;
  final List<ClockInOutSessionEntity>? fri;
  final List<ClockInOutSessionEntity>? sat;
  final List<ClockInOutSessionEntity>? sun;

  const WeekDataEntity({
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
    this.sun,
  });

  factory WeekDataEntity.fromJson(Map<String, dynamic> json) => WeekDataEntity(
        mon: json["mon"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["mon"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        tue: json["tue"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["tue"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        wed: json["wed"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["wed"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        thu: json["thu"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["thu"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        fri: json["fri"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["fri"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        sat: json["sat"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["sat"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
        sun: json["sun"] == null
            ? []
            : List<ClockInOutSessionEntity>.from(
                json["sun"]!.map((x) => ClockInOutSessionEntity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mon":
            mon == null ? [] : List<dynamic>.from(mon!.map((x) => x.toJson())),
        "tue":
            tue == null ? [] : List<dynamic>.from(tue!.map((x) => x.toJson())),
        "wed":
            wed == null ? [] : List<dynamic>.from(wed!.map((x) => x.toJson())),
        "thu":
            thu == null ? [] : List<dynamic>.from(thu!.map((x) => x.toJson())),
        "fri":
            fri == null ? [] : List<dynamic>.from(fri!.map((x) => x.toJson())),
        "sat":
            sat == null ? [] : List<dynamic>.from(sat!.map((x) => x.toJson())),
        "sun":
            sun == null ? [] : List<dynamic>.from(sun!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [
        mon,
        tue,
        wed,
        thu,
        fri,
        sat,
        sun,
      ];
}

class ClockInOutSessionEntity extends Equatable {
  final DateTime? clockin;
  final DateTime? clockout;
  final String? duration;

  const ClockInOutSessionEntity({
    this.clockin,
    this.clockout,
    this.duration,
  });

  factory ClockInOutSessionEntity.fromJson(Map<String, dynamic> json) =>
      ClockInOutSessionEntity(
        clockin:
            json["clockin"] == null ? null : DateTime.parse(json["clockin"]),
        clockout:
            json["clockout"] == null ? null : DateTime.parse(json["clockout"]),
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "clockin": clockin?.toIso8601String(),
        "clockout": clockout?.toIso8601String(),
        "duration": duration,
      };

  @override
  List<Object?> get props => [
        clockin,
        clockout,
        duration,
      ];
}
