// To parse this JSON data, do
//
//     final partnerSettlementModel = partnerSettlementModelFromJson(jsonString);

import '../../domain/entities/partner_settlement_data_entity.dart';

// ignore: must_be_immutable
class PartnerSettlement extends PartnerSettlementEntity {
  PartnerSettlement({
    super.settlementId,
    super.name,
    super.weekName,
    super.truckId,
    super.type,
    super.path,
    super.settlementNumber,
    super.batchDateFrom,
    super.batchDateTo,
    super.createAt,
  });

  factory PartnerSettlement.fromJson(Map<String, dynamic> json) =>
      PartnerSettlement(
        settlementId: json["settlement_id"].toString(),
        name: json["name"],
        truckId: json["truck_id"],
        type: json["type"],
        path: json["path"],
        settlementNumber: json["settlement_number"],
        batchDateFrom: json["batch_date_from"] == null
            ? null
            : DateTime.parse(json["batch_date_from"]),
        batchDateTo: json["batch_date_to"] == null
            ? null
            : DateTime.parse(json["batch_date_to"]),
        createAt: json["create_at"] == null
            ? null
            : DateTime.parse(json["create_at"]),
      );

  Map<String, dynamic> toJson() => {
        "settlement_id": settlementId,
        "name": name,
        "truck_id": truckId,
        "type": type,
        "path": path,
        "settlement_number": settlementNumber,
        "batch_date_from":
            "${batchDateFrom!.year.toString().padLeft(4, '0')}-${batchDateFrom!.month.toString().padLeft(2, '0')}-${batchDateFrom!.day.toString().padLeft(2, '0')}",
        "batch_date_to":
            "${batchDateTo!.year.toString().padLeft(4, '0')}-${batchDateTo!.month.toString().padLeft(2, '0')}-${batchDateTo!.day.toString().padLeft(2, '0')}",
        "create_at": createAt?.toIso8601String(),
      };
}
