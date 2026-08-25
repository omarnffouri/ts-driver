// To parse this JSON data, do
//
//     final settlementDetailsModel = settlementDetailsModelFromJson(jsonString);

import '../../domain/entities/settlement_details_entity.dart';

class SettlementDetailsModel extends SettlementDetailsEntity {
  const SettlementDetailsModel({
    super.team,
    super.batchNumber,
    super.settlementNumber,
    super.carrierDetails,
    super.shipments,
    super.additionalPaymentsTotal,
    super.reimbursements,
    super.reimbursementTotal,
    super.deductions,
    super.deductionTotal,
    super.feeAmount,
    super.earnings,
    super.total,
    super.truckDeductions,
    super.truckDeductionTotal,
    super.truckReimbursements,
    super.truckReimbursementTotal,
    super.paymentTotal,
  });

  factory SettlementDetailsModel.fromJson(Map<String, dynamic> json) =>
      SettlementDetailsModel(
        team: json["team"],
        batchNumber: json["batch_number"],
        settlementNumber: json["settlement_number"],
        carrierDetails: json["payee_name"],
        shipments: json["shipments"] == null
            ? []
            : List<Shipment>.from(
                json["shipments"]!.map((x) => Shipment.fromJson(x)),
              ),
        additionalPaymentsTotal: json["additional_payments_total"].toString(),
        reimbursements: json["reimbursements"] == null
            ? []
            : List<ReimbursementModel>.from(json["reimbursements"]!
                .map((x) => ReimbursementModel.fromJson(x))),
        reimbursementTotal: json["reimbursements_total"].toString(),
        deductions: json["deduction"] == null
            ? []
            : List<DeductionModel>.from(
                json["deduction"]!.map((x) => DeductionModel.fromJson(x))),
        deductionTotal: json["deduction_total"].toString(),
        feeAmount: json["fee_amount"].toString(),
        earnings: json["earnings"].toString(),
        total: json["total"].toString(),
        truckDeductions: json["truck_deductions"] == null
            ? []
            : List<DeductionModel>.from(json["truck_deductions"]!
                .map((x) => DeductionModel.fromJson(x))),
        truckDeductionTotal: json["truck_deduction_total"].toString(),
        truckReimbursements: json["truck_reimbursements"] == null
            ? []
            : List<ReimbursementModel>.from(json["truck_reimbursements"]!
                .map((x) => ReimbursementModel.fromJson(x))),
        truckReimbursementTotal: json["truck_reimbursement_total"].toString(),
        paymentTotal: json["payment_total"].toString(),
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
