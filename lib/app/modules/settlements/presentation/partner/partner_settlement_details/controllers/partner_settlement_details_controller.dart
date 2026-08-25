import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import '../../../../domain/entities/partner_settlement_data_entity.dart';
import '../../../../domain/entities/partner_settlement_details_entity.dart';
import '../../../../domain/usecases/get_partner_settlement_details_usecase.dart';

class PartnerSettlementDetailsController extends GetxController {
  // user
  final user = Get.find<AuthController>().user.value;

  // usecases
  final getPartnerSettlementDetailsUsecase =
      sl<GetPartnerSettlmentDetailsUsecase>();
  // body refresh controllers
  RefreshController detailsRefreshController = RefreshController();

  // variables
  late PartnerSettlementEntity settlementDataEntity;

  final settlemetDetails = PartnerSettlementDetailsEntity().obs;
  final RxBool isLoading = false.obs;
  final settlementNumber = ''.obs;
  final _settlementId = ''.obs;
  String get settlementId => _settlementId.value;
  bool get isInfoAvailable =>
      settlemetDetails.value.info != null &&
      settlemetDetails.value.info!.isNotEmpty;
  bool get isTruckInfoAvailable =>
      settlemetDetails.value.truckDeductions != null &&
          settlemetDetails.value.truckDeductions!.isNotEmpty ||
      settlemetDetails.value.truckReimbursements != null &&
          settlemetDetails.value.truckReimbursements!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    debugPrint("SettlementDetailsController created");

    if (Get.arguments != null) {
      settlementDataEntity = Get.arguments as PartnerSettlementEntity;
      settlementNumber.value = settlementDataEntity.settlementNumber ?? '';
      _settlementId.value = settlementDataEntity.settlementId ?? '';
      getSettlementDetails();
    }
  }

  Future<void> getSettlementDetails() async {
    try {
      isLoading.value = true;
      debugPrint('SettlementId: $settlementId');
      final response = await getPartnerSettlementDetailsUsecase.call(
        settlementId,
      );
      response.fold((settlement) {
        debugPrint('Shipment: ${settlement.toEntity()}');
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

  onShipmentsExpantionChanged({
    required infoIndex,
    required int shipmentIndex,
    required bool expanded,
  }) {
    final ships = settlemetDetails.value.info?[infoIndex].shipments;
    ships?[shipmentIndex].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }
    if (ships == null || ships.isEmpty) {
      return;
    }

    for (int i = 0; i < ships.length; i++) {
      if (i != shipmentIndex) {
        ships[i].shipmentsTileCtrl.collapse();
      }
    }
    // close other tiles
    settlemetDetails.value.info?.asMap().forEach((index, element) {
      closeReimbursementTiles(index);
      closeDeductionTiles(index);
    });

    closeTruckDeductionTiles();
    closeTruckReimbursementTiles();
  }

  onDeductionExpantionChanged({
    required infoIndex,
    required int deductionIndex,
    required bool expanded,
  }) {
    final deductions = settlemetDetails.value.info?[infoIndex].deductions;
    deductions?[deductionIndex].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }
    if (deductions == null || deductions.isEmpty) {
      return;
    }

    for (int i = 0; i < deductions.length; i++) {
      if (i != deductionIndex) {
        deductions[i].deductionTileCtrl.collapse();
      }
    }

    // close other tiles
    settlemetDetails.value.info?.asMap().forEach((index, element) {
      closeShipmentsTiles(index);
      closeReimbursementTiles(index);
    });

    closeTruckDeductionTiles();
    closeTruckReimbursementTiles();
  }

  onReimbursementExpantionChanged({
    required infoIndex,
    required int reimbursementIndex,
    required bool expanded,
  }) {
    final reimbursements =
        settlemetDetails.value.info?[infoIndex].reimbursements;
    reimbursements?[reimbursementIndex].isExpanded.value = expanded;
    if (!expanded) {
      return;
    }

    if (reimbursements == null || reimbursements.isEmpty) {
      return;
    }

    for (int i = 0; i < reimbursements.length; i++) {
      if (i != reimbursementIndex) {
        reimbursements[i].reimbursementTileCtrl.collapse();
      }
    }

    // close other tiles
    settlemetDetails.value.info?.asMap().forEach((index, element) {
      closeShipmentsTiles(index);
      closeDeductionTiles(index);
    });

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
    settlemetDetails.value.info?.asMap().forEach((index, element) {
      closeShipmentsTiles(index);
      closeDeductionTiles(index);
      closeReimbursementTiles(index);
    });

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

    settlemetDetails.value.info?.asMap().forEach((index, element) {
      closeShipmentsTiles(index);
      closeDeductionTiles(index);
      closeReimbursementTiles(index);
    });

    // close other tiles
    closeTruckDeductionTiles();
  }

  void closeShipmentsTiles(int infoIndex) {
    final shipments = settlemetDetails.value.info?[infoIndex].shipments;
    if (shipments == null || shipments.isEmpty) {
      return;
    }
    for (int i = 0; i < shipments.length; i++) {
      shipments[i].shipmentsTileCtrl.collapse();
    }
  }

  void closeDeductionTiles(int infoIndex) {
    final deductions = settlemetDetails.value.info?[infoIndex].deductions;
    if (deductions == null || deductions.isEmpty) {
      return;
    }
    for (int i = 0; i < deductions.length; i++) {
      deductions[i].deductionTileCtrl.collapse();
    }
  }

  void closeReimbursementTiles(int infoIndex) {
    final reimbursements =
        settlemetDetails.value.info?[infoIndex].reimbursements;
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
