// ignore_for_file: invalid_use_of_protected_member

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/app_configration_entity.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/region_entity.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/utils/functions.dart';
import '../../../core/values/constants.dart';
import '../../../core/services/injection_service.dart';
import '../../../core/widgets/common_widget.dart';
import '../../../core/data/error/failures.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/domain/usecases/get_app_configration_usecase.dart';
import '../../auth/domain/usecases/get_cities_by_state_usecase.dart';
import '../../auth/domain/usecases/update_profile_usecase.dart';
import '../forms/accident_review_form_data.dart';
import '../forms/traffic_conviction_form_data.dart';
import '../forms/employment_history_form_data.dart';

class ProfileAddAccidentHistoryController extends GetxController {
  AuthController authController = Get.find<AuthController>();
  final getAppConfigrationUseCase = sl<GetAppConfigrationUseCase>();
  final getCitiesByStateUseCase = sl<GetCitiesByStateUseCase>();
  final updateProfileUseCase = sl<UpdateProfileUseCase>();
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool isCitiesLoading = false.obs;

  final RxBool _isStatesLoading = false.obs;
  bool get isStatesLoading => _isStatesLoading.value;
  final type = ''.obs;

  final RxList<RegionEntity> _states = RxList<RegionEntity>();
  List<RegionEntity> get states => _states.value;

  final RxList<RegionEntity> _cities = RxList<RegionEntity>();
  List<RegionEntity> get cities => _cities.value;

  final accidentFormKey = GlobalKey<FormState>();
  //Accident Review for Past 5 years
  final RxList<AccidentReviewFormData> accidentReviews =
      RxList<AccidentReviewFormData>();

  //Traffic Conviction for Past 5 years
  final RxList<TrafficConvictionFormData> trafficConvictions =
      RxList<TrafficConvictionFormData>();

  //Employment History
  final employementFormKey = GlobalKey<FormState>();
  final RxList<EmploymentHistoryFormData> employmentHistories =
      RxList<EmploymentHistoryFormData>();

  final selectedEmploymentState = <String>[].obs;
  final selectedEmploymentCity = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      type.value = Get.arguments;
      switch (type.value) {
        case 'history':
          getAllStates();
          addEmploymentHistoryFields();
          break;
        case 'accident':
          addAccidentReviewFields();
          break;
        case 'traffict':
          addTrafficsConvictionFields();
          break;
        default:
      }
    }
    debugPrint(type.value);
  }

  String getTitle() {
    switch (type.value) {
      case 'history':
        return 'Employment History';
      case 'accident':
        return 'Accident Review';
      case 'traffict':
        return 'Traffic Conviction';
      default:
        return '';
    }
  }

  Future<void> getAllStates() async {
    try {
      _isStatesLoading(true);
      final res = await getAppConfigrationUseCase.call(const NoParams());
      res.fold((AppConfiguration data) {
        _states.value = data.states ?? [];
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isStatesLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isStatesLoading(false);
    }
  }

  Future<void> getCitiesByState(String stateId) async {
    try {
      debugPrint('State ID: $stateId');
      final res = await getCitiesByStateUseCase.call({"state_id": stateId});
      res.fold(
        (List<RegionEntity> cities) {
          _cities.value = cities;
          debugPrint('Cities: ${_cities.length}');
          debugPrint('Cities: ${_cities.map((e) => e.name).toList()}');
        },
        (Failure r) => CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        ),
      );
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
    }
  }

  void cleanAccidentFields() {
    for (var model in accidentReviews) {
      model.dispose();
    }
    accidentReviews.clear();
  }

  void cleanTraffictFields() {
    for (var model in trafficConvictions) {
      model.dispose();
    }
    trafficConvictions.clear();
  }

  void addAccidentReviewFields() {
    accidentReviews.add(AccidentReviewFormData());
  }

  void removeAccidentReviewFields(int index) {
    accidentReviews[index].dispose();
    accidentReviews.removeAt(index);
  }

  void addTrafficsConvictionFields() {
    trafficConvictions.add(TrafficConvictionFormData());
  }

  void removeTrafficsConvictionFields(int index) {
    trafficConvictions[index].dispose();
    trafficConvictions.removeAt(index);
  }

  void addEmploymentHistoryFields() {
    employmentHistories.add(EmploymentHistoryFormData());
    selectedEmploymentState.add('');
    selectedEmploymentCity.add('');
  }

  void removeEmploymentHistory(int index) {
    employmentHistories[index].dispose();
    employmentHistories.removeAt(index);
    selectedEmploymentState.removeAt(index);
    selectedEmploymentCity.removeAt(index);
  }

  submitAccidentUpdates() async {
    if (!accidentFormKey.currentState!.validate()) {
      return;
    }

    final accidentMap = accidentReviews.map((model) => model.toJson()).toList();
    final trafficMap =
        trafficConvictions.map((model) => model.toJson()).toList();

    Map<String, dynamic> body = {
      "accident_review_past_years": accidentMap,
      "traffic_conviction_past_years": trafficMap,
    };
    try {
      _isLoading(true);
      final Either<UserEntity, Failure> result =
          await updateProfileUseCase.call(body);
      result.fold((user) {
        final updatedUser = authController.user.value.copyWith(
          profile: user.profile,
          personalDetails: user.personalDetails,
        );
        authController.user.value = updatedUser;
        authController.user.refresh();
        CommonVariables.userData.write(USER_DATA, updatedUser.toJson());
        Get.back();
        CommonWidgets.showSnackBar(
          title: 'Success'.tr,
          isError: false,
          message: 'User Updated Successfully',
        );
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoading(false);
    }
  }

  submitEmploymentUpdates() async {
    if (!employementFormKey.currentState!.validate()) {
      return;
    }

    // Validate state and city for each employment history
    for (var model in employmentHistories) {
      if (model.cityController.text.isEmpty ||
          model.stateController.text.isEmpty) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: "State and City are required",
        );
        return;
      }
    }

    final historyMap = employmentHistories
        .map((model) => model.toJson(idGenerator()))
        .toList();

    Map<String, dynamic> body = {
      "employment_histories": historyMap,
    };
    debugPrint('Body: $body');
    try {
      _isLoading(true);
      final Either<UserEntity, Failure> result =
          await updateProfileUseCase.call(body);
      result.fold((user) {
        final updatedUser = authController.user.value.copyWith(
          profile: user.profile,
          personalDetails: user.personalDetails,
        );
        authController.user.value = updatedUser;
        authController.user.refresh();
        CommonVariables.userData.write(USER_DATA, updatedUser.toJson());
        Get.back();
        CommonWidgets.showSnackBar(
          title: 'Success'.tr,
          isError: false,
          message: 'User Updated Successfully',
        );
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
      _isLoading(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isLoading(false);
    }
  }

  @override
  void onClose() {
    // Dispose all Accident Review models
    for (var model in accidentReviews) {
      model.dispose();
    }

    // Dispose all Traffic Conviction models
    for (var model in trafficConvictions) {
      model.dispose();
    }

    // Dispose all Employment History models
    for (var model in employmentHistories) {
      model.dispose();
    }

    super.onClose();
  }
}
