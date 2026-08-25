import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_opener.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/vehicle_documents_manager.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/entities/trailer_entity.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/usecases/get_trailer_documents_usecase.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/usecases/get_truck_documents_usecase.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

import '../../../../core/services/injection_service.dart';
import '../../domain/entities/truck_entity.dart';

class VehicleDocumentsController extends GetxController {
  final Rx<VehicalDocsTabs> currentTab = VehicalDocsTabs.truck.obs;

  RefreshController truckDocsRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController trailerDocsRefreshController =
      RefreshController(initialRefresh: false);

  final getAllTruckDocumentsUsecase = sl<GetAllTruckDocumentsUsecase>();
  final getAllTrailerDocumentsUsecase = sl<GetAllTrailerDocumentsUsecase>();

  TextEditingController truckSearchController = TextEditingController();
  TextEditingController trailerSearchController = TextEditingController();

  final truckList = RxList<TruckEntity>();
  final trailerList = RxList<TrailerEntity>();
  final truckFiltered = RxList<TruckEntity>();
  final trailerFiltered = RxList<TrailerEntity>();

  final vehicleDocumentsManager = Get.put(VehicleDocumentsManager());

  // Per-tab loading so a refresh on one tab doesn't rebuild the other (both
  // stay alive in the IndexedStack).
  final RxBool _truckLoading = false.obs;
  bool get isTruckLoading => _truckLoading.value;

  final RxBool _trailerLoading = false.obs;
  bool get isTrailerLoading => _trailerLoading.value;

  // Trailer is search-first: show the prompt until a query is entered.
  final RxBool showSearchOnly = true.obs;

  late StreamSubscription<InternetConnectionStatus> _connectivitySubscription;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllTruckDocuments();
    getAllTrailerDocuments();
    _initConnectivity();
    _monitorConnectivity();
  }

  Future<void> getAllTruckDocuments() async {
    truckList.clear();
    try {
      _truckLoading(true);
      final Either<List<TruckEntity>, Failure> result =
          await getAllTruckDocumentsUsecase.call(const NoParams());
      result.fold((list) {
        truckList.value = list;
        truckFiltered.value = list;
        saveTruckDocuments(list);
      }, (Failure r) {
        CommonWidgets.showSnackBar(
            title: ''.tr, message: r.message, isError: false);
      });
      _truckLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error'.tr, message: e.toString());
      debugPrint(e.toString());
      _truckLoading(false);
    }
  }

  Future<void> getAllTrailerDocuments() async {
    trailerList.clear();
    try {
      _trailerLoading(true);
      final Either<List<TrailerEntity>, Failure> result =
          await getAllTrailerDocumentsUsecase.call(const NoParams());
      result.fold((list) {
        trailerList.value = list;
        trailerFiltered.value = list;
        saveTrailerDocuments(list);
      }, (Failure r) {
        CommonWidgets.showSnackBar(
            title: ''.tr, message: r.message, isError: false);
      });
      _trailerLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error'.tr, message: e.toString());
      debugPrint(e.toString());
      _trailerLoading(false);
    }

    clearTrailerSearch();
  }

  void truckSearch(String key) {
    if (key.isNotEmpty) {
      truckFiltered.value = truckList
          .where((element) =>
              element.name!.toLowerCase().contains(key.toLowerCase()))
          .toList();
    } else {
      truckFiltered.value = truckList;
    }
  }

  clearTruckSearch() {
    truckSearchController.clear();
    truckFiltered.value = truckList;
  }

  void trailerSearchChanged(String key) {
    final query = key.trim();
    if (query.isEmpty) {
      showSearchOnly.value = true;
      trailerFiltered.value = trailerList;
    } else {
      showSearchOnly.value = false;
      trailerFiltered.value = trailerList
          .where((element) => element.identifier
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  clearTrailerSearch() {
    trailerSearchController.clear();
    trailerFiltered.value = trailerList;
    showSearchOnly.value = true;
  }

  Future<void> saveTruckDocuments(List<TruckEntity> list) async {
    for (var element in list) {
      await vehicleDocumentsManager.getDocumentFile(
        element.path!,
        explicitFileName: element.name!,
        useDefaultExtension: true,
      );
    }
  }

  Future<void> saveTrailerDocuments(List<TrailerEntity> list) async {
    final saveTasks = <Future<void>>[];
    for (var trailer in list) {
      if (trailer.media != null) {
        for (var media in trailer.media!) {
          saveTasks.add(vehicleDocumentsManager.getDocumentFile(media.path!));
        }
      }
    }
    await Future.wait(saveTasks);
  }

  Future<void> openFile(String? path) async {
    final filePath = await vehicleDocumentsManager.getDocumentFile(path ?? "");
    if (filePath != null) {
      FileOpener.openFile(filePath);
    }
  }

  Future<void> _initConnectivity() async {
    final status = await InternetConnectionChecker().connectionStatus;
    isConnected.value = status != InternetConnectionStatus.disconnected;
  }

  void _monitorConnectivity() {
    _connectivitySubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      isConnected.value = status == InternetConnectionStatus.connected;
    });
  }

  @override
  void onClose() {
    try {
      _connectivitySubscription.cancel();
    } catch (_) {}
    super.onClose();
  }
}

enum VehicalDocsTabs { truck, trailer }
