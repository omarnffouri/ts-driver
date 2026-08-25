import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../../domain/entities/settlement_data_entiity.dart';
import '../../../../domain/entities/settlement_details_entity.dart';
import '../../../../domain/usecases/get_settlement_details_usecase.dart';

// tood: implement this with real data
class MonthlyRevenue {
  final String month;
  final double revenue;
  final double deduction;
  final double reimbursement;

  MonthlyRevenue(
    this.month,
    this.revenue, {
    this.deduction = 0,
    this.reimbursement = 0,
  });
}

class SettlementDetailsController extends GetxController {
  // user
  final user = Get.find<AuthController>().user.value;

  // usecases
  final getSettlementDetailsUsecase = sl<GetSettlmentDetailsUsecase>();
  // body refresh controllers
  RefreshController detailsRefreshController = RefreshController();

  // variables
  late SettlementDataEntity settlementDataEntity;

  final settlemetDetails = const SettlementDetailsEntity().obs;
  final RxBool isLoading = false.obs;
  final settlementNumber = ''.obs;
  final _settlementId = ''.obs;
  String get settlementId => _settlementId.value;

  bool get isTruckInfoAvailable =>
      settlemetDetails.value.truckDeductions != null &&
          settlemetDetails.value.truckDeductions!.isNotEmpty ||
      settlemetDetails.value.truckReimbursements != null &&
          settlemetDetails.value.truckReimbursements!.isNotEmpty;

  // chrts data
  final List<MonthlyRevenue> revenueData = [
    MonthlyRevenue('Apr', 2000, reimbursement: 500, deduction: -1200),
    MonthlyRevenue('May', 5000, reimbursement: 0, deduction: -400),
    MonthlyRevenue('Jun', 8500, reimbursement: 0, deduction: -300),
    MonthlyRevenue('Jul', 11000, reimbursement: 700, deduction: 0),
    MonthlyRevenue('Aug', 9000, reimbursement: 1700, deduction: 0),
    MonthlyRevenue('Sep', 3000, reimbursement: 700, deduction: -1000),
  ];

  @override
  void onInit() {
    super.onInit();
    debugPrint("SettlementDetailsController created");

    if (Get.arguments != null) {
      settlementDataEntity = Get.arguments as SettlementDataEntity;
      settlementNumber.value = settlementDataEntity.settlementNumber ?? '';
      _settlementId.value = settlementDataEntity.id ?? '';
      getSettlementDetails();
    }
  }

  Future<void> getSettlementDetails() async {
    try {
      isLoading.value = true;
      debugPrint('SettlementId: $settlementId');
      final response = await getSettlementDetailsUsecase.call(settlementId);
      response.fold((settlement) {
        debugPrint('Shipment: $settlement');
        settlemetDetails.value = settlement;
      }, (failure) {
        Get.snackbar('Error', failure.message);
      });
      isLoading.value = false;
    } catch (_) {
      debugPrint('Error $_');
      isLoading.value = false;
    }
  }

  handleShipmentRefresh() async {
    await getSettlementDetails();
    detailsRefreshController.refreshCompleted();
  }

  onShipmentsExpantionChanged(int index, bool expanded) {
    final ships = settlemetDetails.value.shipments;
    ships?[index].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }
    if (ships == null || ships.isEmpty) {
      return;
    }

    for (int i = 0; i < settlemetDetails.value.shipments!.length; i++) {
      if (i != index) {
        ships[i].shipmentsTileCtrl.collapse();
      }
    }

    closeReimbursementTiles();
    closeDeductionTiles();
    closeTruckDeductionTiles();
    closeTruckReimbursementTiles();
  }

  onDeductionExpantionChanged(int index, bool expanded) {
    final deductions = settlemetDetails.value.deductions;
    deductions?[index].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }
    if (deductions == null || deductions.isEmpty) {
      return;
    }

    for (int i = 0; i < deductions.length; i++) {
      if (i != index) {
        deductions[i].deductionTileCtrl.collapse();
      }
    }
    closeShipmentsTiles();
    closeReimbursementTiles();
    closeTruckDeductionTiles();
    closeTruckReimbursementTiles();
  }

  onReimbursementExpantionChanged(int index, bool expanded) {
    final reimbursements = settlemetDetails.value.reimbursements;
    reimbursements?[index].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }

    if (reimbursements == null || reimbursements.isEmpty) {
      return;
    }

    for (int i = 0; i < reimbursements.length; i++) {
      if (i != index) {
        reimbursements[i].reimbursementTileCtrl.collapse();
      }
    }
    closeShipmentsTiles();
    closeDeductionTiles();
    closeTruckDeductionTiles();
    closeTruckReimbursementTiles();
  }

  //! Truck deductions and reimbursements
  onTruckDeductionExpantionChanged(int index, bool expanded) {
    final deductions = settlemetDetails.value.truckDeductions;
    deductions?[index].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }
    if (deductions == null || deductions.isEmpty) {
      return;
    }

    for (int i = 0; i < deductions.length; i++) {
      if (i != index) {
        deductions[i].deductionTileCtrl.collapse();
      }
    }

    // close other tiles
    closeShipmentsTiles();
    closeDeductionTiles();
    closeReimbursementTiles();
    closeTruckReimbursementTiles();
  }

  onTruckReimbursementExpantionChanged(int index, bool expanded) {
    final reimbursements = settlemetDetails.value.truckReimbursements;
    reimbursements?[index].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }

    if (reimbursements == null || reimbursements.isEmpty) {
      return;
    }

    for (int i = 0; i < reimbursements.length; i++) {
      if (i != index) {
        reimbursements[i].reimbursementTileCtrl.collapse();
      }
    }

    // close other tiles
    closeShipmentsTiles();
    closeDeductionTiles();
    closeReimbursementTiles();
    closeTruckDeductionTiles();
  }

  // close tiles functions
  void closeShipmentsTiles() {
    final shipments = settlemetDetails.value.shipments;
    if (shipments == null || shipments.isEmpty) {
      return;
    }
    for (int i = 0; i < shipments.length; i++) {
      shipments[i].shipmentsTileCtrl.collapse();
    }
  }

  void closeDeductionTiles() {
    final deductions = settlemetDetails.value.deductions;
    if (deductions == null || deductions.isEmpty) {
      return;
    }
    for (int i = 0; i < deductions.length; i++) {
      deductions[i].deductionTileCtrl.collapse();
    }
  }

  void closeReimbursementTiles() {
    final reimbursements = settlemetDetails.value.reimbursements;
    if (reimbursements == null || reimbursements.isEmpty) {
      return;
    }
    for (int i = 0; i < reimbursements.length; i++) {
      reimbursements[i].reimbursementTileCtrl.collapse();
    }
  }

  void closeTruckDeductionTiles() {
    final deductions = settlemetDetails.value.truckDeductions;
    if (deductions == null || deductions.isEmpty) {
      return;
    }
    for (int i = 0; i < deductions.length; i++) {
      deductions[i].deductionTileCtrl.collapse();
    }
  }

  void closeTruckReimbursementTiles() {
    final reimbursements = settlemetDetails.value.truckReimbursements;
    if (reimbursements == null || reimbursements.isEmpty) {
      return;
    }
    for (int i = 0; i < reimbursements.length; i++) {
      reimbursements[i].reimbursementTileCtrl.collapse();
    }
  }

  Map<String, String> extractTruckDetails(String payeeName) {
    List<String> parts = payeeName.split(' | ');

    if (parts.length < 2) {
      return {
        'truckNumber': '',
        'customerkName': '',
      };
    }

    return {
      'truckNumber': parts[0],
      'customerkName': parts[1],
    };
  }

  Map<String, String> extractDateDetails(String payeeName) {
    List<String> parts = payeeName.split(' - ');

    if (parts.length < 2) {
      return {
        'date': '',
        'time': '',
      };
    }
    return {
      'date': parts[0],
      'time': parts[1],
    };
  }

  Future<void> download({
    required String url,
    required String fileName,
    required String extnsion,
  }) async {
    await saveFile(
      url: url,
      fileName: fileName,
      extension: extnsion,
    );
  }
}
