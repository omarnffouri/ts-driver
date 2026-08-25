import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/location_controller.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/shipments/presentation/views/tabs/completed_shipments.dart';

import 'package:ts_driver/app/routes/app_pages.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../core/data/error/failures.dart';
import '../../../../core/enum/trip_type.dart';
import '../../../../core/services/injection_service.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/common_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/usecases/complete_shipment_usecase.dart';
import '../../domain/usecases/get_all_shipments_usecase.dart';
import '../../domain/usecases/update_shipment_usecase.dart';
import '../../data/shipment_seed.dart';
import '../views/bottom_sheets/accept_shipment_bottom_sheet.dart';
import '../views/bottom_sheets/details_bottom_sheet.dart';
import '../views/bottom_sheets/upload_bol_bottom_sheet.dart';
import '../views/tabs/all_shipments.dart';
import '../views/tabs/rejected_shipments.dart';

/// Pagination + scroll state for a single paginated tab (Completed / Rejected).
class PagedShipments {
  final items = RxList<ShipmentEntity>();
  final hasMore = true.obs;
  final isLoading = false.obs; // first page
  final isPaginating = false.obs; // load-more
  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int page = 1;

  /// True once a fetch has succeeded — so a genuinely-empty tab isn't re-fetched
  /// every time it's opened (`items.isEmpty` alone can't tell the difference).
  bool loaded = false;

  bool get busy => isLoading.value || isPaginating.value;

  /// No-op until loaded; replaces by id so the row can't duplicate.
  void upsertIfLoaded(ShipmentEntity item) {
    if (!loaded) return;
    items.removeWhere((e) => e.id == item.id);
    items.add(item);
  }

  void reset() {
    page = 1;
    hasMore.value = true;
  }

  void dispose() {
    scrollController.dispose();
    refreshController.dispose();
  }
}

class ShipmentsController extends GetxController {
  final Rx<UserEntity> _user = Get.find<AuthController>().user;
  UserEntity get user => _user.value;

  final getAllShipmentsUsecase = sl<GetAllShipmentsUsecase>();
  final updateShipmentUsecase = sl<UpdateShipmentUsecase>();
  final completeShipmentUsecase = sl<CompleteShipmentUsecase>();

  // ── New Load tab — all active loads fetched in one call, bucketed by status.
  final assigned = RxList<ShipmentEntity>();
  final waiting = RxList<ShipmentEntity>();
  final transitTrip = RxList<ShipmentEntity>();
  final bolRejected = RxList<ShipmentEntity>();
  final RxBool isLoadingActive = false.obs;
  final ScrollController activeScrollController = ScrollController();
  final RefreshController activeRefreshController =
      RefreshController(initialRefresh: false);

  bool get isNewShipmentsEmpty =>
      assigned.isEmpty &&
      waiting.isEmpty &&
      transitTrip.isEmpty &&
      bolRejected.isEmpty;

  // ── Completed / Rejected tabs — paginated, each with its own state.
  final completedTab = PagedShipments();
  final rejectedTab = PagedShipments();

  static const int _pageLimit = 10;

  /// Id of the shipment whose accept/reject is in flight (drives its spinner).
  final updatingShipmentId = RxnInt();

  final RxBool isUploadingBolNumber = false.obs;

  final RxList<File> bolNumberFiles = RxList<File>();
  TextEditingController bolNumberController = TextEditingController();
  final RxList<File> lumberFiles = RxList<File>();
  final RxList<File> fuelFiles = RxList<File>();
  final RxList<File> otherFiles = RxList<File>();

  /// Inline validation messages for the Upload-BOL sheet (null = no error).
  final bolNumberError = RxnString();
  final bolFilesError = RxnString();

  bool get isBolReady => bolNumberFiles.isNotEmpty;

  final currentTab = 0.obs;
  final tabs = [
    const AllShipments(),
    const CompletedShipments(),
    const RejectedShipments(),
  ];

  /// Loading flag for the visible tab (used to disable the tab switcher).
  bool get isLoading {
    switch (currentTab.value) {
      case 1:
        return completedTab.isLoading.value;
      case 2:
        return rejectedTab.isLoading.value;
      default:
        return isLoadingActive.value;
    }
  }

  @override
  void onInit() {
    super.onInit();
    CommonVariables.tracking.write(isShipmentServiceRunning, false);

    completedTab.scrollController
        .addListener(() => _onScrollEnd(completedTab, 'completed'));
    rejectedTab.scrollController
        .addListener(() => _onScrollEnd(rejectedTab, 'rejected'));

    currentTab.listen((index) {
      if (index == 1 && !completedTab.loaded) {
        refreshPaged(completedTab, 'completed');
      } else if (index == 2 && !rejectedTab.loaded) {
        refreshPaged(rejectedTab, 'rejected');
      }
    });

    fetchActiveLoads();
  }

  @override
  void onClose() {
    activeScrollController.dispose();
    activeRefreshController.dispose();
    completedTab.dispose();
    rejectedTab.dispose();
    bolNumberController.dispose();
    super.onClose();
  }

  void _onScrollEnd(PagedShipments tab, String action) {
    final position = tab.scrollController.position;
    // _loadMore guards hasMore/isPaginating; just trigger at the bottom.
    if (position.pixels == position.maxScrollExtent && tab.hasMore.value) {
      _loadMore(tab, action);
    }
  }

  // ── New Load (active) ────────────────────────────────────────────────────

  /// Fetches every active load in one call (no pagination) and buckets it.
  Future<void> fetchActiveLoads() async {
    isLoadingActive.value = true;
    try {
      if (kUseShipmentSeed) {
        assigned.value = ShipmentSeed.assigned();
        waiting.value = ShipmentSeed.waiting();
        transitTrip.value = ShipmentSeed.transit();
        bolRejected.value = ShipmentSeed.bolRejected();
        return; // skip _syncTransitTracking so seed data doesn't start GPS
      }
      final response =
          await getAllShipmentsUsecase.call({'action': 'assigned'});
      response.fold((BaseResponse<List<ShipmentEntity>> res) {
        final data = res.data ?? [];
        assigned.value = _withStatus(data, 'assigned');
        waiting.value = _withStatus(data, 'waiting');
        transitTrip.value = _withStatus(data, 'transit');
        bolRejected.value = _withStatus(data, 'bol-rejected');
        _syncTransitTracking();
      }, (Failure failure) {
        Get.snackbar('Error', failure.message);
      });
    } catch (e) {
      debugPrint('fetchActiveLoads failed: $e');
    } finally {
      isLoadingActive.value = false;
    }
  }

  // ── Completed / Rejected (paginated) ─────────────────────────────────────

  Future<void> refreshPaged(PagedShipments tab, String action) async {
    if (tab.busy) return;
    tab.reset();
    tab.isLoading.value = true;
    await _loadPage(tab, action, 1);
    tab.isLoading.value = false;
  }

  Future<void> _loadMore(PagedShipments tab, String action) async {
    if (tab.busy || !tab.hasMore.value) return;
    tab.isPaginating.value = true;
    final nextPage = tab.page + 1;
    if (await _loadPage(tab, action, nextPage)) tab.page = nextPage;
    tab.isPaginating.value = false;
  }

  Future<bool> _loadPage(PagedShipments tab, String action, int page) async {
    try {
      if (kUseShipmentSeed) {
        tab.items.value = action == 'completed'
            ? ShipmentSeed.completed()
            : ShipmentSeed.rejected();
        tab.hasMore.value = false;
        tab.loaded = true;
        return true;
      }
      final body = {
        'page': page,
        'limit': _pageLimit,
        'action': action,
      };
      final response = await getAllShipmentsUsecase.call(body);
      return response.fold((BaseResponse<List<ShipmentEntity>> res) {
        final data = res.data ?? [];
        if (page == 1) {
          tab.items.value = data;
        } else {
          final existingIds = tab.items.map((e) => e.id).toSet();
          tab.items.addAll(data.where((e) => !existingIds.contains(e.id)));
        }
        tab.hasMore.value = res.hasMore ?? false;
        tab.loaded = true;
        return true;
      }, (Failure failure) {
        Get.snackbar('Error', failure.message);
        return false;
      });
    } catch (e) {
      debugPrint('load $action failed: $e');
      return false;
    }
  }

  /// Re-fetch everything (used after a shipment-related push notification).
  Future<void> refreshAll() async {
    await fetchActiveLoads();
    await Future.wait([
      if (completedTab.loaded) refreshPaged(completedTab, 'completed'),
      if (rejectedTab.loaded) refreshPaged(rejectedTab, 'rejected'),
    ]);
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> updateShipment({
    required ShipmentEntity shipment,
    required String status,
    String? reason,
  }) async {
    try {
      final shipmentId = shipment.id.toString();
      final body = {
        'shipment_id': shipmentId,
        'driver_id': user.personalDetails?.applicantId.toString(),
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      };
      updatingShipmentId.value = shipment.id;
      final result = await updateShipmentUsecase.call(body);
      result.fold((ShipmentEntity updatedShipment) {
        assigned.removeWhere((element) => element.id.toString() == shipmentId);
        if (updatedShipment.driverStatus == 'transit') {
          transitTrip.add(updatedShipment);
        } else if (updatedShipment.driverStatus == 'waiting') {
          waiting.add(updatedShipment);
        } else if (updatedShipment.driverStatus == 'rejected') {
          rejectedTab.upsertIfLoaded(updatedShipment);
        }

        if (updatedShipment.driverStatus == 'transit') {
          Get.toNamed(Routes.MAP, arguments: {
            "shipment": updatedShipment,
            "redirect": true,
          });
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: ''.tr,
          message: r.message,
          isError: false,
        );
        if (r.code == 406) {
          assigned
              .removeWhere((element) => element.id.toString() == shipmentId);
          assigned.refresh();
        }
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
    } finally {
      updatingShipmentId.value = null;
    }
  }

  /// Returns true when the trip completed successfully — the caller owns any
  /// post-success UI (closing the sheet, showing the success dialog).
  Future<bool> completeShipment({
    required String shipmentId,
    required bool isBolRejected,
  }) async {
    try {
      bolNumberError.value = bolNumberController.text.trim().isEmpty
          ? 'Enter the BOL number'
          : null;
      bolFilesError.value =
          bolNumberFiles.isEmpty ? 'Add at least one BOL photo' : null;
      if (bolNumberError.value != null || bolFilesError.value != null) {
        return false;
      }

      Map<String, dynamic> bodyToSend = {
        'shipment_id': shipmentId,
        'driver_id': user.personalDetails?.applicantId.toString(),
        'bol_number': bolNumberController.text.trim()
      };

      for (int i = 0; i < bolNumberFiles.length; i++) {
        bodyToSend['proof_of_delivery[$i]'] = dio.MultipartFile.fromFileSync(
            bolNumberFiles[i].path,
            filename: basename(bolNumberFiles[i].path));
      }

      for (int i = 0; i < lumberFiles.length; i++) {
        bodyToSend['lumper[$i]'] = dio.MultipartFile.fromFileSync(
            lumberFiles[i].path,
            filename: basename(lumberFiles[i].path));
      }

      for (int i = 0; i < fuelFiles.length; i++) {
        bodyToSend['fuel[$i]'] = dio.MultipartFile.fromFileSync(
            fuelFiles[i].path,
            filename: basename(fuelFiles[i].path));
      }

      for (int i = 0; i < otherFiles.length; i++) {
        bodyToSend['others[$i]'] = dio.MultipartFile.fromFileSync(
            otherFiles[i].path,
            filename: basename(otherFiles[i].path));
      }

      final formDataToSend = dio.FormData.fromMap(bodyToSend);

      isUploadingBolNumber.value = true;
      final result = await completeShipmentUsecase.call(formDataToSend);
      return await result.fold<Future<bool>>(
          (ShipmentEntity completedShipment) async {
        if (isBolRejected) {
          bolRejected
              .removeWhere((element) => element.id.toString() == shipmentId);
        } else {
          transitTrip
              .removeWhere((element) => element.id.toString() == shipmentId);
        }

        completedTab.upsertIfLoaded(completedShipment);
        await CommonVariables.tracking.write(isShipmentServiceRunning, false);
        Get.put<LocationController>(LocationController()).releaseTracking();
        return true;
      }, (Failure r) async {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
          isError: false,
        );
        return false;
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      return false;
    } finally {
      isUploadingBolNumber.value = false;
    }
  }

  void clearFiles() {
    bolNumberFiles.clear();
    lumberFiles.clear();
    fuelFiles.clear();
    otherFiles.clear();
  }

  List<ShipmentEntity> _withStatus(
    List<ShipmentEntity> list,
    String status,
  ) =>
      list.where((element) => element.driverStatus == status).toList();

  Future<void> _syncTransitTracking() async {
    if (transitTrip.isNotEmpty) {
      await CommonVariables.tracking.write(isShipmentServiceRunning, true);
      CommonVariables.tracking
          .write(currentTransit, jsonEncode(transitTrip[0].toEntity()));
      Get.put<LocationController>(LocationController()).startTrack();
    } else {
      await CommonVariables.tracking.write(isShipmentServiceRunning, false);
      Get.put<LocationController>(LocationController()).releaseTracking();
    }
  }

  void showConfirmBottomSheet({required ShipmentEntity shipment}) =>
      _showHalfSheet(AcceptShipmentBottomSheet(shipment: shipment));

  void showDetailsBottomSheet({
    required ShipmentEntity shipment,
    required TripType tripType,
  }) =>
      _showHalfSheet(
          DetailsBottomSheet(shipment: shipment, tripType: tripType));

  /// Shows [child] in a bottom sheet with a half-screen minimum height.
  void _showHalfSheet(Widget child) {
    showAppBottomSheet(
      child: Container(
        constraints: BoxConstraints(minHeight: Get.height * 0.5),
        child: child,
      ),
    );
  }

  Future<void> showUploadBolBottomSheet({
    required ShipmentEntity shipment,
    bool isBolRejected = false,
  }) async {
    bolNumberController.clear();
    clearFiles();
    bolNumberError.value = null;
    bolFilesError.value = null;
    // UploadBolBottomSheet self-constrains (min 0.3 / max 0.85), so no wrapper.
    showAppBottomSheet(
      enableDrag: false,
      showGrabber: true,
      child: UploadBolBottomSheet(
        shipment: shipment,
        isBolRejected: isBolRejected,
      ),
    );
  }
}
