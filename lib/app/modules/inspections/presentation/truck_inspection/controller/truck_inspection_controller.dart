import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import '../../../domain/usecases/create_inspection_usecase.dart';
import '../../../domain/usecases/get_inspection_options_usecase.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';

import '../../../../../core/data/error/failures.dart';
import '../../../../../core/utils/functions.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../domain/entities/inspection_options_entity.dart';
import '../../../domain/entities/tire.dart';
import '../../../domain/entities/inspection_damage.dart';
import '../../../domain/entities/inspection_enums.dart';
import '../../bottom_sheets/inspection_sheets.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import '../../../domain/entities/tire_layout.dart';
import '../../bottom_sheets/tire_editor_sheet.dart';

class TruckInspectionController extends GetxController {
  late String tripNo;
  late String shipmentNo;
  late String driverId;

  final RxList<InspectionDamage> truckLeftSideDamages = RxList();
  final RxList<InspectionDamage> truckFrontSideDamages = RxList();
  final RxList<InspectionDamage> truckRightSideDamages = RxList();
  final RxList<InspectionDamage> truckBackSideDamages = RxList();
  final RxList<InspectionDamage> truckInsideDamages = RxList();

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
  final Rx<Tire> tire9 =
      Rx<Tire>(Tire(name: "tire_9", pressure: 100, depth: 15));
  final Rx<Tire> tire10 =
      Rx<Tire>(Tire(name: "tire_10", pressure: 100, depth: 15));

  /// All 10 tires in layout order. Cached: the backing [Rx] fields are stable.
  late final List<Rx<Tire>> tires = [
    tire1,
    tire2,
    tire3,
    tire4,
    tire5,
    tire6,
    tire7,
    tire8,
    tire9,
    tire10,
  ];

  /// Truck axle layout: a steer axle (one tire per side) + two drive axles
  /// with dual tires (outer + inner) per side.
  late final TireLayout tireLayout = TireLayout([
    const AxleConfig(
      name: 'Steer',
      left: [TireSlot(tireIndex: 0, side: AxleSide.left)],
      right: [TireSlot(tireIndex: 1, side: AxleSide.right)],
    ),
    _dualAxle('Axle 2', 2, 3, 4, 5),
    _dualAxle('Axle 3', 6, 7, 8, 9),
  ]);

  AxleConfig _dualAxle(
    String name,
    int lOuter,
    int lInner,
    int rOuter,
    int rInner,
  ) {
    return AxleConfig(
      name: name,
      left: [
        TireSlot(tireIndex: lOuter, side: AxleSide.left, isDual: true),
        TireSlot(
            tireIndex: lInner,
            side: AxleSide.left,
            isDual: true,
            isInner: true),
      ],
      right: [
        TireSlot(tireIndex: rOuter, side: AxleSide.right, isDual: true),
        TireSlot(
            tireIndex: rInner,
            side: AxleSide.right,
            isDual: true,
            isInner: true),
      ],
    );
  }

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

  // inspection details updated
  final Rx<bool> _haveInspectionData = false.obs;
  bool get haveInspectionData => _haveInspectionData.value;

  @override
  onInit() {
    super.onInit();

    // getting shipment_no and trip_no from args
    if (Get.arguments != null) {
      final arguments = Get.arguments;
      shipmentNo = arguments['shipment_no'] ?? "";
      tripNo = arguments['trip_no'] ?? "";
      driverId = arguments['driver_id'] ?? "";
    } else {
      Get.back();
    }

    notesController.addListener(
      () {
        _updateInspectionDataState();
      },
    );

    loadInspectionOptions();
  }

  _updateInspectionDataState() {
    if (_haveAnyDamage() ||
        _haveAnyTireInspection() ||
        _haveAnyNotes() ||
        _haveFuelOrOilInspection()) {
      _haveInspectionData(true);
    } else {
      _haveInspectionData(false);
    }
    _haveInspectionData.refresh();
  }

  bool _haveFuelOrOilInspection() {
    return ((oilStatus != OilStatus.full) || fuelStatus != FuelStatus.full);
  }

  bool _haveAnyNotes() {
    return notesController.text.isNotEmpty;
  }

  bool _haveAnyTireInspection() =>
      tires.any((t) => t.value.pressure != 100 || t.value.depth != 15);

  bool _haveAnyDamage() {
    return truckLeftSideDamages.isNotEmpty ||
        truckFrontSideDamages.isNotEmpty ||
        truckRightSideDamages.isNotEmpty ||
        truckBackSideDamages.isNotEmpty ||
        truckInsideDamages.isNotEmpty;
  }

  addContainerImagePressed(
      String truckSide,
      ScrollController imagesScrollController,
      RxList<InspectionDamage> truckDamages) async {
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
        truckDamages.add(InspectionDamage(
          damageId: category.id ?? -1,
          damage: category.name ?? '',
          image: image,
        ));
        _updateInspectionDataState();
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

  // container damages selection bottom sheet
  void showDamagesBottomSheet(
    String truckSide,
    RxList<InspectionDamage> truckDamagesList,
    ScrollController imagesScrollController,
  ) {
    showDamagesListSheet(
      damages: truckDamagesList,
      onAdd: () => addContainerImagePressed(
          truckSide, imagesScrollController, truckDamagesList),
      onRemove: (index) => removeDamage(truckDamagesList, index, truckSide),
      onChangeType: (index) => _changeDamageType(truckDamagesList, index),
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
        current.damage = category.name ?? "";
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

  /// Opens the guided per-tire editor starting at [startIndex] of the layout.
  void showTireBottomSheet(int startIndex) {
    showAppBottomSheet(
      child: TireEditorSheet(
        layout: tireLayout,
        tires: tires,
        startIndex: startIndex,
        onCommit: _updateInspectionDataState,
      ),
    );
  }

  // oil bottom sheet
  void showOilBottomSheet() {
    showSelectionSheet(
      title: "Oil Status",
      options: const ["Full", "Low"],
      selected: oilStatus == OilStatus.full ? "Full" : "Low",
      onSelect: (v) {
        _oilStatus(v == "Full" ? OilStatus.full : OilStatus.low);
        _updateInspectionDataState();
      },
    );
  }

  void showFuelBottomSheet() {
    showSelectionSheet(
      title: "Fuel Status",
      options: FuelStatus.status,
      selected: fuelStatus,
      onSelect: (v) {
        _fuelStatus(v);
        _updateInspectionDataState();
      },
    );
  }

  // remove damage
  removeDamage(
      RxList<InspectionDamage> truckDamagesList, int index, String truckSide) {
    truckDamagesList.removeAt(index);
    _updateInspectionDataState();
  }

  onSubmitClicked() async {
    if (!haveInspectionData) {
      Get.back();
      return;
    }
    final Map<String, dynamic> bodyToSend = {
      'shipment_id': shipmentNo,
      'trip_number': tripNo,
      'driver_id': int.parse(driverId.toString()),
      'trailer': jsonEncode({})
    };

    // list to store damages and images
    final List<dynamic> damagesList = [];
    final List<dio.MultipartFile> images = [];

    // left side damages adding into damagesList
    for (var element in truckLeftSideDamages) {
      damagesList.add({
        'side': TruckSides.left,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // front side damages adding into damagesList
    for (var element in truckFrontSideDamages) {
      damagesList.add({
        'side': TruckSides.front,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // right side damages adding into damagesList
    for (var element in truckRightSideDamages) {
      damagesList.add({
        'side': TruckSides.right,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }
    //
    // back side damages adding into damagesList
    for (var element in truckBackSideDamages) {
      damagesList.add({
        'side': TruckSides.back,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }

    //
    // in-side damages adding into damagesList
    for (var element in truckInsideDamages) {
      damagesList.add({
        'side': TruckSides.inside,
        'damage_category': element.damageId.toString()
      });
      images.add(dio.MultipartFile.fromFileSync(element.image.path,
          filename: basename(element.image.path)));
    }

    bodyToSend['truck'] = jsonEncode({
      'note': notesController.text.toString(),
      'oil': oilStatus == OilStatus.full ? 'full' : 'low',
      'fuel': fuelStatus.toLowerCase(),
      'type': 'truck',
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
      bodyToSend['truck_images[$i]'] = images[i];
    }

    final formDataToSend = dio.FormData.fromMap(bodyToSend);

    try {
      // calling api in order to create inspection
      _isCreatingInspection(true);
      final response = await createInspectionUseCase.call(formDataToSend);
      response.fold((l) {
        if (l.message?.isNotEmpty ?? false) {
          CommonWidgets.showSnackBar(
            title: 'Error'.tr,
            message: l.message ?? "",
            isError: false,
          );
        } else if (l.code == 200 && l.status == "success") {
          Get.back();
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
          isError: false,
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
