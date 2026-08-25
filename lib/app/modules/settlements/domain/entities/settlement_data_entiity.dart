// To parse this JSON data, do
//
//     final settlementDataEntity = settlementDataEntityFromJson(jsonString);

import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class SettlementDataEntity extends Equatable {
  String? id;
  String? name;
  String? weekName;
  final String? path;
  final String? type;
  final String? truckId;
  final String? settlementNumber;
  final DateTime? fromDate;
  final DateTime? toDate;

  SettlementDataEntity({
    this.id,
    this.name,
    this.path,
    this.fromDate,
    this.toDate,
    this.type,
    this.truckId,
    this.settlementNumber,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        fromDate,
        toDate,
        type,
        truckId,
      ];
}
