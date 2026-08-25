import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:ts_driver/app/core/utils/widget_utils.dart';
import '../../bottom_sheets/inspection_sheets.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import '../../../domain/usecases/create_inspection_usecase.dart';
import '../../../domain/usecases/get_inspection_options_usecase.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../../core/data/error/failures.dart';
import '../../../../../core/utils/functions.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../domain/entities/inspection_options_entity.dart';
import '../../../domain/entities/tire.dart';
import '../../../domain/entities/inspection_damage.dart';
import '../../../domain/entities/inspection_enums.dart';
import '../../../domain/entities/tire_layout.dart';
import '../../bottom_sheets/tire_editor_sheet.dart';

class InspectionController extends GetxController {
  late String tripNo;
  late String shipmentNo;
  late String trailerNo;
  late String driverId;

  // storing the state of the active tab
  final Rx<InspectionTabs> _activeTab = InspectionTabs.van.obs;
  InspectionTabs get activeTab => _activeTab.value;

  final RxList<InspectionDamage> containerDamagesSide1 = RxList();
  final RxList<InspectionDamage> containerDamagesSide2 = RxList();
  final RxList<InspectionDamage> containerDamagesSide3 = RxList();
  final RxList<InspectionDamage> containerDamagesSide4 = RxList();
  final RxList<InspectionDamage> containerDamagesSide5 = RxList();

  final Rx<Tire> tire1 =
      Rx<Tire>(Tire(name: "tire_1", pressure: 100, depth: 15));
  final Rx<Tire> tire2 =
      Rx<Tire>(Tire(name: "tire_2", pressure: 100, depth: 15));
  final Rx<Tire> tire3 =
      Rx<Tire>(Tire(name: "tire_3", pressure: 100, depth: 15));
  final Rx<Tire> tire4 =
      Rx<Tire>(Tire(name: "tire_4", pressure: 100, depth: 15));
  final Rx<Tire> tire5 =
      Rx<Tire>(Tire(name: "tire_5", pressure: 100, depth: 15));
  final Rx<Tire> tire6 =
      Rx<Tire>(Tire(name: "tire_6", pressure: 100, depth: 15));
  final Rx<Tire> tire7 =
      Rx<Tire>(Tire(name: "tire_7", pressure: 100, depth: 15));
  final Rx<Tire> tire8 =
      Rx<Tire>(Tire(name: "tire_8", pressure: 100, depth: 15));

  // get inspection options usecase
  final getInspectionOptionsUseCase = sl<GetInspectionOptionsUseCase>();

  // oil state
  final Rx<OilStatus> _oilStatus = OilStatus.full.obs;
  OilStatus get oilStatus => _oilStatus.value;

  // inspection option response rx value
  final Rxn<InspectionOptionResponseEntity> _inspectionOptionsResponse =
      Rxn<InspectionOptionResponseEntity>();

  // fule state
  final Rx<String> _fuelStatus = FuelStatus.full.obs;
  String get fuelStatus => _fuelStatus.value;

  // inspection option loading state
  final Rx<bool> _isLoadingInspectionOptions = false.obs;
  bool get isLoadingInspectionOptions => _isLoadingInspectionOptions.value;

  // notes controller
  final TextEditingController notesController = TextEditingController();

  // create inspection usecase
  final createInspectionUseCase = sl<CreateInspectionUserCase>();

  // inspection creation loading state
  final Rx<bool> _isCreatingInspection = false.obs;
  bool get isCreatingInspection => _isCreatingInspection.value;

  @override
  onInit() {
    super.onInit();

    // getting shipment id from a args
    if (Get.arguments != null) {
      final arguments = Get.arguments;
      shipmentNo = arguments['shipment_id'] ?? "";
      trailerNo = arguments['trailer_id'] ?? "";
      driverId = arguments['driver_id'] ?? "";
    } else {
      Get.back();
    }

    // generating random string number
    tripNo = generateUniqueNumber(6, 15);

    // load inspection options
    loadInspectionOptions();
  }

  // changing tab
  changeTab(InspectionTabs inspectionTab) {
    _activeTab(inspectionTab);
  }

  // add image file to the containerImagesSide1 list
  addContainerImagePressed(
      ContainerSides containerSide,
      ScrollController imagesScrollController,
      RxList<InspectionDamage> containerDamages) async {
    if (!(await PermissionHelper.haveCameraPermission(
        "Grant camera permission in settings to click photos."))) {
      return;
    }
    final File? file = await getImage(
      imageSource: ImageSource.camera,
    );
    if (file == null) return;
    final image = File(file.path);
    showAddDamageSheet(
      image: image,
      isLoading: _isLoadingInspectionOptions,
      response: _inspectionOptionsResponse,
      onRetry: loadInspectionOptions,
      onConfirm: (category) {
        containerDamages.add(InspectionDamage(
          damageId: category.id ?? -1,
          damage: category.name ?? '',
          image: image,
        ));
        Future.delayed(const Duration(milliseconds: 400), () {
          if (imagesScrollController.hasClients) {
            imagesScrollController.animateTo(
              imagesScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  // Damages list / change-type sheets (shared with the truck flow).
  showDamagesBottomSheet(
    ContainerSides containerSide,
    RxList<InspectionDamage> containerDamagesList,
    ScrollController imagesScrollController,
  ) {
    showDamagesListSheet(
      damages: containerDamagesList,
      onAdd: () => addContainerImagePressed(
          containerSide, imagesScrollController, containerDamagesList),
      onRemove: (index) =>
          removeDamage(containerDamagesList, index, containerSide),
      onChangeType: (index) => _changeDamageType(containerDamagesList, index),
    );
  }

  void _changeDamageType(RxList<InspectionDamage> list, int index) {
    final categories =
        _inspectionOptionsResponse.value?.payload?.categories ?? [];
    if (categories.isEmpty) {
      loadInspectionOptions();
      return;
    }
    final current = list[index];
    showChangeDamageTypeSheet(
      categories: categories,
      current: current,
      onPick: (category) {
        current.damageId = category.id ?? -1;
        current.damage = category.name ?? '';
        list.refresh();
      },
    );
  }

  // calling api in order to load inpection options
  loadInspectionOptions() async {
    try {
      _isLoadingInspectionOptions(true);

      final Either<InspectionOptionResponseEntity, Failure> result =
          await getInspectionOptionsUseCase.call(const NoParams());
      result.fold((InspectionOptionResponseEntity inspectionOptionsResponse) {
        _inspectionOptionsResponse(inspectionOptionsResponse);
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: ''.tr,
          message: r.message,
          isError: false,
        );
      });
      _isLoadingInspectionOptions(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoadingInspectionOptions(false);
    }
  }

  /// All 8 tires in axle order (index 0 = Axle 1 Left … 7 = Axle 4 Right).
  /// Cached: the backing [Rx] fields are stable so the list never changes.
  late final List<Rx<Tire>> tires = [
    tire1,
    tire2,
    tire3,
    tire4,
    tire5,
    tire6,
    tire7,
    tire8,
  ];

  /// Trailer axle layout: 4 axles, one tire per side.
  late final TireLayout tireLayout = TireLayout([
    for (var axle = 0; axle < 4; axle++)
      AxleConfig(
        name: 'Axle ${axle + 1}',
        left: [TireSlot(tireIndex: axle * 2, side: AxleSide.left)],
        right: [TireSlot(tireIndex: axle * 2 + 1, side: AxleSide.right)],
      ),
  ]);

  /// Opens the guided per-tire editor starting at [startIndex] of the layout.
  void showTireBottomSheet(int startIndex) {
    showAppBottomSheet(
      child: TireEditorSheet(
        layout: tireLayout,
        tires: tires,
        startIndex: startIndex,
      ),
    );
  }

  // oil bottom sheet
  showOilBottomSheet() {
    showSelectionSheet(
      title: 'Oil Status',
      options: const ['Full', 'Low'],
      selected: oilStatus == OilStatus.full ? 'Full' : 'Low',
      onSelect: (v) => _oilStatus(v == 'Full' ? OilStatus.full : OilStatus.low),
    );
  }

  void showFuelBottomSheet() {
    showSelectionSheet(
      title: 'Fuel Status',
      options: FuelStatus.status,
      selected: fuelStatus,
      onSelect: (v) => _fuelStatus(v),
    );
  }

  // remove damage
  removeDamage(RxList<InspectionDamage> containerDamagesList, int index,
      ContainerSides containerSide) {
    containerDamagesList.removeAt(index);
  }

  onSubmitClicked() async {
    final Map<String, dynamic> bodyToSend = {
      'shipment_id': shipmentNo,
      'trip_number': tripNo,
      'driver_id': int.parse(driverId.toString()),
      'truck': jsonEncode({})
    };

    // list to store damages and images
    final List<dynamic> damagesList = [];
    final List<dio.MultipartFile> images = [];

    // left side damages adding into damagesList
    for (var element in containerDamagesSide1) {
      damagesList.add({
        'side': TruckSides.left,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // front side damages adding into damagesList
    for (var element in containerDamagesSide2) {
      damagesList.add({
        'side': TruckSides.front,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // right side damages adding into damagesList
    for (var element in containerDamagesSide3) {
      damagesList.add({
        'side': TruckSides.right,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // back side damages adding into damagesList
    for (var element in containerDamagesSide4) {
      damagesList.add({
        'side': TruckSides.back,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }

    //
    // in-side damages adding into damagesList
    for (var element in containerDamagesSide5) {
      damagesList.add({
        'side': TruckSides.inside,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }

    bodyToSend['trailer'] = jsonEncode({
      'note': notesController.text.toString(),
      'oil': oilStatus == OilStatus.full ? 'full' : 'low',
      'fuel': fuelStatus.toLowerCase(),
      'type': activeTab == InspectionTabs.van ? 'van' : 'reefer',
      'damages': damagesList,
      'tire_inspection': tires
          .map((t) => {
                'tire_name': t.value.name,
                'pressure': t.value.pressure,
                'depth': t.value.depth,
              })
          .toList(),
    });

    for (int i = 0; i < images.length; i++) {
      bodyToSend['trailer_images[$i]'] = images[i];
    }

    final formDataToSend = dio.FormData.fromMap(bodyToSend);

    try {
      // calling api in order to create inspection
      _isCreatingInspection(true);
      final response = await createInspectionUseCase.call(formDataToSend);
      response.fold((l) async {
        if (l.message?.isNotEmpty ?? false) {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: l.message ?? "",
            isError: false,
          );
        } else if (l.code == 200 && l.status == "success") {
          await Get.toNamed(Routes.TRUCK_INSPECTION, arguments: {
            'shipment_no': shipmentNo,
            'trip_no': tripNo,
            'driver_id': driverId
          });
          Get.back(result: true);
        } else {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: "Something went wrong! Unable to create inspection.",
            isError: false,
          );
        }
      }, (r) {
        CommonWidgets.showSnackBar(
          title: ''.tr,
          message: r.message,
        );
      });
      _isCreatingInspection(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isCreatingInspection(false);
    }
  }
}

enum InspectionTabs { van, reefer }

enum ContainerSides { none, one, two, three, four, five }
