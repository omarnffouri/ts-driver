import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/modules/annoucments/domain/entities/annoucement_entity.dart';
import 'package:ts_driver/app/modules/annoucments/domain/usecases/get_all_annoucements_usecase.dart';
import 'package:ts_driver/app/modules/annoucments/domain/usecases/update_annoucement__read_status_usecase.dart';

import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

class AnnoucmentsController extends GetxController {
  final refreshController = RefreshController();

  // usecases
  final getAllAnnoucementsUsecase = sl<GetAllAnnoucementsUsecase>();
  final updateAnnoucementUsecase = sl<UpdateAnnoucementReadStatusUsecase>();

  // list of annoucements
  final RxList<AnnoucementEntity> annoucements = RxList<AnnoucementEntity>();

  final RxBool _isLoadingAnnoucements = false.obs;
  bool get isLoadingAnnoucements => _isLoadingAnnoucements.value;

  // loading
  final RxBool _isupdatingAnnoucementStatus = false.obs;
  bool get isupdatingAnnoucementStatus => _isupdatingAnnoucementStatus.value;

  final updatingAnnouncementStatusIndex = (-1).obs;

  final annoucementsPageController = PageController();

  @override
  void onInit() {
    super.onInit();
    getAllAnnoucements();
  }

  Future<void> getAllAnnoucements() async {
    try {
      annoucements.clear();
      _isLoadingAnnoucements(true);
      final result = await getAllAnnoucementsUsecase.call(const NoParams());
      result.fold((List<AnnoucementEntity> annoucementList) {
        log('annoucements length: ${annoucementList.length}');
        annoucements.value = annoucementList;
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoadingAnnoucements(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingAnnoucements(false);
    }
  }

  Future<void> updateAnnoucementsReadStatus(
      AnnoucementEntity annoucement, int index) async {
    try {
      if (isupdatingAnnoucementStatus) {
        return;
      }
      if (annoucement.read == 1) {
        return;
      }
      if (annoucement.id == null) {
        return;
      }

      updatingAnnouncementStatusIndex(index);

      _isupdatingAnnoucementStatus(true);

      final result = await updateAnnoucementUsecase.call(annoucement.id!);

      result.fold((bool isReadSucessful) {
        log('annoucement read: $isReadSucessful ===> ${annoucement.id}');
        if (isReadSucessful) {
          annoucements
              .firstWhereOrNull((element) => ((element.id == annoucement.id) &&
                  (element.id != null && annoucement.id != null)))
              ?.read = 1;
        }
      }, (Failure r) {
        log('annoucement update read status error: ${r.message}');
      });

      _isupdatingAnnoucementStatus(false);
      updatingAnnouncementStatusIndex(-1);
      annoucements.refresh();
    } catch (e) {
      log('annoucement update read status error: $e');
      debugPrint(e.toString());
      _isupdatingAnnoucementStatus(false);
      updatingAnnouncementStatusIndex(-1);
    }
  }
}
