// To parse this JSON data, do
//
//     final settlementDetailsModel = settlementDetailsModelFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerSettlementDetailsEntity {
  final String? team;
  final String? settlementNumber;
  final String? batchNumber;
  final String? createdAt;
  final String? carrierDetails;
  final String? earnings;
  final String? reimbursements;
  final String? deductions;
  final String? total;
  final List<DeductionEntity>? truckDeductions;
  final String? truckDeductionTotal;
  final List<ReimbursementEntity>? truckReimbursements;
  final String? truckReimbursementTotal;
  final List<SettlementDetailsInfoEntity>? info;

  PartnerSettlementDetailsEntity({
    this.team,
    this.settlementNumber,
    this.batchNumber,
    this.createdAt,
    this.carrierDetails,
    this.earnings,
    this.reimbursements,
    this.deductions,
    this.total,
    this.truckDeductions,
    this.truckDeductionTotal,
    this.truckReimbursements,
    this.truckReimbursementTotal,
    this.info,
  });

  Map<String, dynamic> toEntity() => {
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

class SettlementDetailsInfoEntity extends Equatable {
  final String? driverName;
  final String? driverTotal;
  final String? paymentTotal;
  final List<ShipmentEntity>? shipments;
  final List<ReimbursementEntity>? reimbursements;
  final List<DeductionEntity>? deductions;
  final String? additionalPaymentsTotal;
  final String? reimbursementTotal;
  final String? deductionTotal;

  const SettlementDetailsInfoEntity({
    this.driverName,
    this.driverTotal,
    this.paymentTotal,
    this.shipments,
    this.additionalPaymentsTotal,
    this.reimbursements,
    this.reimbursementTotal,
    this.deductions,
    this.deductionTotal,
  });

  toEntity() {
    return SettlementDetailsInfoEntity(
      driverName: driverName,
      driverTotal: driverTotal,
      paymentTotal: paymentTotal,
      shipments: shipments,
      additionalPaymentsTotal: additionalPaymentsTotal,
      reimbursements: reimbursements,
      reimbursementTotal: reimbursementTotal,
      deductions: deductions,
      deductionTotal: deductionTotal,
    );
  }

  @override
  List<Object?> get props => [
        driverName,
        driverTotal,
        paymentTotal,
        shipments,
        additionalPaymentsTotal,
        reimbursements,
        reimbursementTotal,
        deductions,
        deductionTotal,
      ];
}

class ShipmentEntity extends Equatable {
  final String? shipmentNumber;
  final String? shipmentTotal;
  final String? totalMileage;
  final String? deliveryDate;
  final String? pickupDate;
  final String? pickupAddress;
  final String? deliveryAddress;
  final List<PaymentInfoEntity>? paymentInfo;
  final shipmentsTileCtrl = ExpansibleController();
  final isExpanded = false.obs;

  ShipmentEntity({
    this.shipmentNumber,
    this.shipmentTotal,
    this.totalMileage,
    this.deliveryDate,
    this.pickupDate,
    this.pickupAddress,
    this.deliveryAddress,
    this.paymentInfo,
  });

  @override
  List<Object?> get props => [
        shipmentNumber,
        shipmentTotal,
        totalMileage,
        deliveryDate,
        pickupDate,
        pickupAddress,
        deliveryAddress,
        paymentInfo,
      ];
}

class ReimbursementEntity extends Equatable {
  final String? reimbursementType;
  final String? description;
  final String? amount;
  final reimbursementTileCtrl = ExpansibleController();
  final isExpanded = false.obs;

  ReimbursementEntity({
    this.reimbursementType,
    this.description,
    this.amount,
  });

  toEntity() {
    return ReimbursementEntity(
      reimbursementType: reimbursementType,
      description: description,
      amount: amount,
    );
  }

  @override
  List<Object?> get props => [
        reimbursementType,
        description,
        amount,
      ];
}

class DeductionEntity extends Equatable {
  final String? deductionNumber;
  final String? description;
  final String? deductionType;
  final String? amount;
  final deductionTileCtrl = ExpansibleController();
  final isExpanded = false.obs;

  DeductionEntity({
    this.deductionNumber,
    this.description,
    this.deductionType,
    this.amount,
  });

  toEntity() {
    return DeductionEntity(
      deductionNumber: deductionNumber,
      description: description,
      deductionType: deductionType,
      amount: amount,
    );
  }

  @override
  List<Object?> get props => [
        deductionNumber,
        description,
        deductionType,
        amount,
      ];
}

class PaymentInfoEntity extends Equatable {
  final String? amountType;
  final String? amount;
  final String? rate;
  final String? payment;
  final String? paymentType;

  const PaymentInfoEntity({
    this.amountType,
    this.amount,
    this.rate,
    this.payment,
    this.paymentType,
  });

  @override
  List<Object?> get props => [
        amountType,
        amount,
        rate,
        payment,
        paymentType,
      ];
}
