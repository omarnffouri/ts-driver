// To parse this JSON data, do
//
//     final partnerSettlementModel = partnerSettlementModelFromJson(jsonString);

import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class PartnerSettlementEntity extends Equatable {
  final String? settlementId;
  final String? name;
  String? weekName;
  final int? truckId;
  final String? type;
  final String? path;
  final String? settlementNumber;
  final DateTime? batchDateFrom;
  final DateTime? batchDateTo;
  final DateTime? createAt;

  PartnerSettlementEntity({
    this.settlementId,
    this.name,
    this.weekName,
    this.truckId,
    this.type,
    this.path,
    this.settlementNumber,
    this.batchDateFrom,
    this.batchDateTo,
    this.createAt,
  });

  @override
  List<Object?> get props => [
        name,
        truckId,
        type,
        path,
        settlementNumber,
        batchDateFrom,
        batchDateTo,
        createAt
      ];
}
