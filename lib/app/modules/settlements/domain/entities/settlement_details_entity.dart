// To parse this JSON data, do
//
//     final settlementDetailsModel = settlementDetailsModelFromJson(jsonString);

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettlementDetailsEntity extends Equatable {
  final String? team;
  final String? batchNumber;
  final String? settlementNumber;
  final String? carrierDetails;
  final List<ShipmentEntity>? shipments;
  final String? additionalPaymentsTotal;
  final List<ReimbursementEntity>? reimbursements;
  final String? reimbursementTotal;
  final List<DeductionEntity>? deductions;
  final String? deductionTotal;
  final String? feeAmount;
  final String? earnings;
  final String? total;
  final List<DeductionEntity>? truckDeductions;
  final String? truckDeductionTotal;
  final List<ReimbursementEntity>? truckReimbursements;
  final String? truckReimbursementTotal;
  final String? paymentTotal;

  const SettlementDetailsEntity({
    this.team,
    this.batchNumber,
    this.settlementNumber,
    this.carrierDetails,
    this.shipments,
    this.additionalPaymentsTotal,
    this.reimbursements,
    this.reimbursementTotal,
    this.deductions,
    this.deductionTotal,
    this.feeAmount,
    this.earnings,
    this.total,
    this.truckDeductions,
    this.truckDeductionTotal,
    this.truckReimbursements,
    this.truckReimbursementTotal,
    this.paymentTotal,
  });

  @override
  List<Object?> get props => [
        team,
        batchNumber,
        settlementNumber,
        carrierDetails,
        shipments,
        additionalPaymentsTotal,
        reimbursements,
        reimbursementTotal,
        deductions,
        deductionTotal,
        feeAmount,
        earnings,
        total,
        truckDeductions,
        truckDeductionTotal,
        truckReimbursements,
        truckReimbursementTotal,
        paymentTotal,
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
