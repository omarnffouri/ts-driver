// To parse this JSON data, do
//
//     final partnerSettlementDetailsModel = partnerSettlementDetailsModelFromJson(jsonString);

import '../../domain/entities/partner_settlement_details_entity.dart';

class PartnerSettlementDetailsModel extends PartnerSettlementDetailsEntity {
  PartnerSettlementDetailsModel({
    super.team,
    super.settlementNumber,
    super.batchNumber,
    super.createdAt,
    super.carrierDetails,
    super.earnings,
    super.reimbursements,
    super.deductions,
    super.total,
    super.truckDeductions,
    super.truckDeductionTotal,
    super.truckReimbursements,
    super.truckReimbursementTotal,
    super.info,
  });

  factory PartnerSettlementDetailsModel.fromJson(Map<String, dynamic> json) =>
      PartnerSettlementDetailsModel(
        team: json["team"],
        settlementNumber: json["settlement_number"],
        batchNumber: json["batch_number"],
        createdAt: json["created_at"],
        carrierDetails: json["payee_name"],
        earnings: json["earnings"].toString(),
        reimbursements: json["reimbursements"].toString(),
        deductions: json["deductions"].toString(),
        total: json["total"].toString().replaceAll(',', ''),
        truckDeductions: json["truck_deduction"] == null
            ? []
            : List<DeductionModel>.from(json["truck_deduction"]!
                .map((x) => DeductionModel.fromJson(x))),
        truckDeductionTotal: json["truck_deduction_total"].toString(),
        truckReimbursements: json["truck_reimbursement"] == null
            ? []
            : List<ReimbursementModel>.from(json["truck_reimbursement"]!
                .map((x) => ReimbursementModel.fromJson(x))),
        truckReimbursementTotal: json["truck_reimbursement_total"].toString(),
        info: json["info"] == null
            ? []
            : List<SettlementDetailsInfoModel>.from(json["info"]!
                .map((x) => SettlementDetailsInfoModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "team": team,
        "settlement_number": settlementNumber,
        "batch_number": batchNumber,
        "created_at": createdAt,
        "payee_name": carrierDetails,
        "earnings": earnings,
        "reimbursements": reimbursements,
        "deductions": deductions,
        "total": total,
        "truck_deductions": truckDeductions == null
            ? []
            : List<dynamic>.from(truckDeductions!.map((x) => x.toEntity())),
        "truck_deduction_total": truckDeductionTotal,
        "truck_reimbursement": truckReimbursements == null
            ? []
            : List<dynamic>.from(truckReimbursements!.map((x) => x.toEntity())),
        "truck_reimbursement_total": truckReimbursementTotal,
        "info": info == null
            ? []
            : List<dynamic>.from(info!.map((x) => x.toEntity())),
      };
}

class SettlementDetailsInfoModel extends SettlementDetailsInfoEntity {
  const SettlementDetailsInfoModel({
    super.driverName,
    super.paymentTotal,
    super.driverTotal,
    super.shipments,
    super.additionalPaymentsTotal,
    super.reimbursements,
    super.reimbursementTotal,
    super.deductions,
    super.deductionTotal,
  });

  factory SettlementDetailsInfoModel.fromJson(Map<String, dynamic> json) =>
      SettlementDetailsInfoModel(
        driverName: json["driver_name"],
        driverTotal: json["driver_total"].toString(),
        paymentTotal: json["payment_total"].toString(),
        shipments: json["shipments"] == null
            ? []
            : List<Shipment>.from(
                json["shipments"]!.map((x) => Shipment.fromJson(x)),
              ),
        additionalPaymentsTotal: json["additional_payments_total"].toString(),
        reimbursements: json["reimbursement"] == null
            ? []
            : List<ReimbursementModel>.from(json["reimbursement"]!
                .map((x) => ReimbursementModel.fromJson(x))),
        reimbursementTotal: json["reimbursement_total"].toString(),
        deductions: json["deduction"] == null
            ? []
            : List<DeductionModel>.from(
                json["deduction"]!.map((x) => DeductionModel.fromJson(x))),
        deductionTotal: json["deduction_total"].toString(),
      );
}

class Shipment extends ShipmentEntity {
  Shipment({
    super.shipmentNumber,
    super.shipmentTotal,
    super.totalMileage,
    super.deliveryDate,
    super.pickupDate,
    super.pickupAddress,
    super.deliveryAddress,
    super.paymentInfo,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        shipmentNumber: json["shipment_number"],
        shipmentTotal: json["shipment_total"].toString(),
        totalMileage: json["total_mileage"].toString(),
        deliveryDate: json["delivery_date"],
        pickupDate: json["pickup_date"],
        pickupAddress: json["pickup_address"],
        deliveryAddress: json["delivery_address"],
        paymentInfo: json["payment_info"] == null
            ? []
            : List<PaymentInfo>.from(
                json["payment_info"]!.map((x) => PaymentInfo.fromJson(x))),
      );
}

class ReimbursementModel extends ReimbursementEntity {
  ReimbursementModel({
    super.reimbursementType,
    super.description,
    super.amount,
  });

  factory ReimbursementModel.fromJson(Map<String, dynamic> json) =>
      ReimbursementModel(
        reimbursementType: json["reimbursement_type"],
        description: json["description"],
        amount: json["amount"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "reimbursement_type": reimbursementType,
        "description": description,
        "amount": amount,
      };
}

class DeductionModel extends DeductionEntity {
  DeductionModel({
    super.deductionNumber,
    super.description,
    super.deductionType,
    super.amount,
  });

  factory DeductionModel.fromJson(Map<String, dynamic> json) => DeductionModel(
        deductionNumber: json["deduction_number"],
        description: json["description"],
        deductionType: json["deduction_type"],
        amount: json["amount"].toString(),
      );
}

class PaymentInfo extends PaymentInfoEntity {
  const PaymentInfo({
    super.amountType,
    super.amount,
    super.rate,
    super.payment,
    super.paymentType,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
        amountType: json["amount_type"] == "Additional Payment"
            ? "Additional"
            : json["amount_type"].toString(),
        amount: json["amount"] == null || json["amount"] == "-"
            ? "0"
            : json["amount"].toString(),
        rate: json["rate"].toString().replaceAll(RegExp(r'[^\d.]'), ''),
        payment: json["payment"].toString(),
        paymentType: json["payment_type"].toString(),
      );
}
