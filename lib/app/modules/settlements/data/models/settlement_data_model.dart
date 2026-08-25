import 'package:ts_driver/app/modules/settlements/domain/entities/settlement_data_entiity.dart';

// ignore: must_be_immutable
class SettlementDataModel extends SettlementDataEntity {
  SettlementDataModel({
    super.id,
    super.name,
    super.path,
    super.fromDate,
    super.toDate,
    super.type,
    super.truckId,
    super.settlementNumber,
  });

  factory SettlementDataModel.fromJson(Map<String, dynamic> json) =>
      SettlementDataModel(
        id: json["settlement_id"].toString(),
        name: json["name"],
        path: json["path"],
        type: json["type"],
        truckId: json["truck_id"].toString(),
        settlementNumber: json["settlement_number"],
        fromDate: json["batch_date_from"] == null
            ? null
            : DateTime.parse(json["batch_date_from"]).toLocal(),
        toDate: json["batch_date_to"] == null
            ? null
            : DateTime.parse(json["batch_date_to"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "settlement_id": id,
        "name": name,
        "path": path,
        "type": type,
        "truck_id": truckId,
        "settlement_number": settlementNumber,
        "batch_date_from": fromDate?.toIso8601String(),
        "batch_date_to": toDate?.toIso8601String(),
      };
}
