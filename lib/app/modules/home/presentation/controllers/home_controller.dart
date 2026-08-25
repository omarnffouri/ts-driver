// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/helpers/base_response.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/helpers/shared_preferences_helper.dart';
import 'package:ts_driver/app/core/helpers/voip_helper.dart';
import 'package:ts_driver/app/modules/annoucments/presentation/controllers/annoucments_controller.dart';
import 'package:ts_driver/app/modules/auth/data/models/application_status.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/clock_in_usecase.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/clock_out_usecase.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/update_voip_token_usecase.dart';
import 'package:ts_driver/app/modules/main_screen/controllers/main_screen_controller.dart';
import 'package:uuid/uuid.dart';

import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/controllers/location_controller.dart';
import 'package:ts_driver/app/core/data/error/failures.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/modules/home/domain/entities/applicant_state_entity.dart';
import 'package:ts_driver/app/modules/home/domain/entities/check_clock_in_entity.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/check_clock_in_usecase.dart';
import 'package:ts_driver/app/modules/home/data/home_prewarm.dart';
import 'package:ts_driver/app/modules/home/domain/usecases/get_applicant_usecase.dart';
import 'package:ts_driver/app/core/services/injection_service.dart';

import 'package:ts_driver/app/core/widgets/common_widget.dart';

class HomeController extends GetxController {
  // controllers
  AuthController authController = Get.find<AuthController>();
  final annoucmentsController = Get.put(AnnoucmentsController(), tag: "home");
  final refreshController = RefreshController();

  // usecases
  final getApplicantUsecase = sl<GetApplicantUsecase>();
  final checkClockInUseCase = sl<CheckClockInUsecase>();
  final clockInUseCase = sl<ClockInUsecase>();
  final clockOutUseCase = sl<ClockOutUsecase>();
  final updateVoipTokenUsecase = sl<UpdateVoipTokenUsecase>();

  // --- User and Profile Data ---
  final user = Get.find<AuthController>().user;
  final _applicantState = const ApplicantStateEntity().obs;
  ApplicantStateEntity get applicantState => _applicantState.value;

  // UI States
  final currentSelection = 0.obs;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // True for the whole init() run (locks the page); isLoading is just the
  // applicant-state call. Starts true so the page is locked from first build
  // through the entrance transition until the deferred init() completes.
  final RxBool _isInitializing = true.obs;
  bool get isInitializing => _isInitializing.value;

  // Not reset on refresh: collapsing it mid-scroll makes the page jump.
  final RxBool hideClockSection = true.obs;
  final currentState = ApplicationState(
    id: 1,
    name: 'under_review',
    isSelected: true,
  ).obs;

  final _isHired = false.obs;
  bool get isHired => _isHired.value;

  final RxList<ApplicationState> myList = [
    ApplicationState(id: 1, name: 'under_review', isSelected: false),
    ApplicationState(id: 2, isSelected: false, name: 'phone_screening'),
    ApplicationState(id: 3, isSelected: false, name: 'in_process'),
    ApplicationState(id: 4, isSelected: false, name: 'approved'),
    ApplicationState(id: 5, isSelected: false, name: 'hired'),
  ].obs;

  static const List<String> allTopics = [
    'under_review',
    'phone_screening',
    'in_process',
    'approved',
    'hired',
    'on_hold',
    'rejected',
    'terminated',
  ];

  static const Map<String, String> statusNames = {
    'under_review': 'Under Review',
    'phone_screening': 'Phone Screening',
    'in_process': 'In Process',
    'approved': 'Approved',
    'hired': 'Hired',
    'on_hold': 'On Hold',
    'rejected': 'Rejected',
  };

  // --- Clock Duration States ---
  final RxInt days = 0.obs;
  final RxInt hours = 0.obs;
  final RxInt minutes = 0.obs;
  final RxInt seconds = 0.obs;

  int totalTicks = 0;

  // --- Clock In/Out States ---
  final _isClockedIn = false.obs;
  bool get isClockedIn => _isClockedIn.value;

  final _isCheckingClockInFailed = false.obs;
  bool get isCheckingClockInFailed => _isCheckingClockInFailed.value;

  final _isCheckingClockIn = false.obs;
  bool get isCheckingClockIn => _isCheckingClockIn.value;

  final _isClockingInOut = false.obs;
  bool get isClockingInOut => _isClockingInOut.value;

  int get unsignedFormsCount => applicantState.unsignedForms ?? 0;
  int get pendingDocumentsCount => applicantState.pendingDocumentRequests ?? 0;

  final _isLoadingWeekDetails = false.obs;
  bool get isLoadingWeekDetails => _isLoadingWeekDetails.value;

  // timer for showing live ticks and time in views
  Timer? _timer;
  StreamSubscription<AppLifecycleState>? _appStateSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    CommonVariables.tracking.write(isClockServiceRunning, false);

    // Apply splash-prewarmed applicant state synchronously so the reveal opens
    // onto a populated home; init() below then skips re-fetching it.
    final prewarmed = HomePrewarm.take();
    final hasPrewarm = prewarmed != null;
    if (prewarmed != null) {
      _applicantState.value = prewarmed;
      currentState.value.name = prewarmed.applicantStatus;
      validateStatus(currentState.value.name!);
      manageTopicSubscriptions(currentState.value.name!);
    }

    if (Get.isRegistered<MainScreenController>()) {
      final mainScreenController = Get.find<MainScreenController>();
      _appStateSubscription = mainScreenController.appState.listen((state) {
        if (state == AppLifecycleState.resumed) {
          if (authController.isAuthenticated == true) {
            _checkClockIn();
          }
        }
      });
    }

    _fetchAndUpdateVoipToken();

    // Defer the first load until the entrance transition finishes, so network
    // + relayout work doesn't compete with the animation.
    if (Get.isRegistered<MainScreenController>()) {
      await Get.find<MainScreenController>().entered;
    }
    await init(skipApplicantState: hasPrewarm);
  }

  Future<void> init({bool skipApplicantState = false}) async {
    _isInitializing(true);
    try {
      await Future.wait([
        if (!skipApplicantState)
          _safeRun("getApplicationState", getApplicationState),
        _safeRun("_checkClockIn", _checkClockIn),
      ]);
    } finally {
      _isInitializing(false);
    }
  }

  // Pull-to-refresh: the announcements controller isn't recreated, so refresh
  // it alongside init().
  Future<void> reload() => Future.wait([
        init(),
        annoucmentsController.getAllAnnoucements(),
      ]);

  Future<void> getApplicationState() async {
    try {
      _isLoading(true);
      final result = await getApplicantUsecase(const NoParams());
      result.fold((ApplicantStateEntity state) async {
        _applicantState.value = state;
        currentState.value.name = state.applicantStatus;
        validateStatus(currentState.value.name!);
        manageTopicSubscriptions(currentState.value.name!);
      }, (Failure r) {
        debugPrint(r.message);
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
      _isLoading(false);
    }
  }

  /// Refreshes the home tab/card data (counts + announcements) after returning
  /// from a sub-screen such as Forms or Documents.
  Future<void> refreshHomeData() async {
    await Future.wait([
      _safeRun("getApplicationState", getApplicationState),
      _safeRun("getAllAnnoucements", annoucmentsController.getAllAnnoucements),
    ]);
  }

  Future<void> _startTimer() async {
    CommonVariables.tracking.write(isClockServiceRunning, true);
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        totalTicks += 1;
        _formatDuration();
      },
    );
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();
    _resetClockTicks();
    _isClockedIn(false);
    await CommonVariables.tracking.write(isClockServiceRunning, false);
    Get.put<LocationController>(LocationController()).releaseTracking();
  }

  void _formatDuration() {
    var tick = totalTicks;
    // calculating days from tick
    days.value = tick ~/ (24 * 3600);

    // subracting days from the tick
    tick = tick % (24 * 3600);

    // calculating hours
    hours.value = tick ~/ 3600;

    // subracting hours from tick
    tick = tick % 3600;

    // calculating minutes
    minutes.value = tick ~/ 60;

    // removing minutes and getting seconds
    seconds.value = tick % 60;
  }

  void onClockInOutClicked() {
    if (isClockedIn) {
      _clockOut();
    } else {
      _clockIn();
    }
  }

  Future<void> refeshClockInState() {
    _stopTimer();
    _checkClockIn();
    return Future.value();
  }

  Future<void> _checkClockIn() async {
    CommonVariables.tracking.write(isClockServiceRunning, false);
    _isClockedIn(false);

    try {
      _isCheckingClockIn(true);
      _isCheckingClockInFailed(false);

      final result = await checkClockInUseCase.call(const NoParams());
      result.fold((CheckClockInDataEntity clockData) async {
        _isClockedIn(clockData.clockedIn ?? false);
        CommonVariables.tracking.write(
          isClockServiceRunning,
          clockData.clockedIn ?? false,
        );

        if (isClockedIn) {
          totalTicks = clockData.startStopWatchFrom ?? 0;
          _formatDuration();
          _startTimer();
          final uuid = const Uuid().v1();
          CommonVariables.tracking.writeIfNull(
            uuId,
            uuid,
          );
          await SharedPrefrencesHelper.storeClockInOutSessionId(uuid, true);
          Get.put<LocationController>(LocationController()).startTrack();
        } else {
          _stopTimer();
          SharedPrefrencesHelper.clearClockInOutSessionId();
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
        _isCheckingClockInFailed(true);
      });
      _isCheckingClockIn(false);
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isCheckingClockIn(false);
      _isCheckingClockInFailed(true);
    }
  }

  Future<void> _clockIn() async {
    if (isClockingInOut || isClockedIn) {
      return;
    }

    if (!(await PermissionHelper.haveLocationPermission(
        "Grant location permission in settings to clock-in."))) {
      return;
    }

    try {
      _isClockingInOut(true);

      final Either<BaseResponse<bool>, Failure> result =
          await clockInUseCase.call(const NoParams());

      _isClockingInOut(false);

      result.fold((BaseResponse<bool> clockData) async {
        if (clockData.code == 200 && clockData.data == true) {
          _isClockedIn(true);

          CommonVariables.tracking.write(
            isClockServiceRunning,
            true,
          );

          _resetClockTicks();
          _startTimer();

          // add firebase uuid collection
          final uuid = const Uuid().v1();
          CommonVariables.tracking.write(
            uuId,
            uuid,
          );
          await SharedPrefrencesHelper.storeClockInOutSessionId(uuid, true);
          Get.put<LocationController>(LocationController()).startTrack();
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isClockingInOut(false);
    }
  }

  Future<void> _clockOut() async {
    if (isClockingInOut || (!isClockedIn)) {
      return;
    }

    try {
      _isClockingInOut(true);

      final Either<BaseResponse<bool>, Failure> result =
          await clockOutUseCase.call(const NoParams());

      _isClockingInOut(false);

      result.fold((BaseResponse<bool> clockData) async {
        if (clockData.code == 200 && clockData.data == true) {
          _isClockedIn(false);

          CommonVariables.tracking.write(
            isClockServiceRunning,
            false,
          );

          _stopTimer();
          SharedPrefrencesHelper.clearClockInOutSessionId();
        }
      }, (Failure r) {
        CommonWidgets.showSnackBar(
          title: 'Error'.tr,
          message: r.message,
        );
      });
    } catch (e) {
      CommonWidgets.showSnackBar(
        title: 'Error'.tr,
        message: e.toString(),
      );
      debugPrint(e.toString());
      _isClockingInOut(false);
    }
  }

  void validateStatus(String key) {
    if (key == "rejected" || key == "on_hold") {
      return;
    }

    final id = myList.firstWhereOrNull((element) => element.name == key)?.id;
    if (id == null) {
      return;
    }
    currentState.value.id = id;
    for (var element in myList) {
      if (element.id! <= id) {
        element.isSelected = true;
      } else {
        element.isSelected = false;
      }
    }

    currentSelection.refresh();

    hideClockSection.value = currentState.value.id! < 5;
    _isHired.value = currentState.value.id! == 5;
    hideClockSection.refresh();

    myList.refresh();
  }

  void manageTopicSubscriptions(String userStatus) async {
    // Unsubscribe from all topics first
    await Future.wait(
      allTopics.map((topic) {
        debugPrint('unsubscribing from $topic');
        return FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }),
    );

    // Subscribe to the topic based on user status
    if (userStatus.isNotEmpty && allTopics.contains(userStatus)) {
      await FirebaseMessaging.instance.subscribeToTopic(userStatus);
      debugPrint('subscribing to $userStatus');
    }
  }

  String getStatusName(String key) {
    return statusNames[key] ?? '';
  }

  bool showWatchButton(ApplicationState e) {
    return getStatusName(e.name!) == "Approved" &&
        _applicantState.value.applicantStatus == "approved" &&
        _applicantState.value.hasSeenAllVideos == false;
  }

  String getExtension(String path) {
    final String ext = path.split('.').last;
    debugPrint('extension is $ext');
    return ext;
  }

  void _fetchAndUpdateVoipToken() async {
    if (!Platform.isIOS) {
      return;
    }
    //
    try {
      //
      final token = await VoipHelper.fetchVoipToken();
      if (token.isEmpty) {
        return;
      }

      //
      // hit update voip token api
      final response = await updateVoipTokenUsecase.call(token);

      response.fold((successful) {
        debugPrint("Voip update response ====> $successful");
      }, (failure) {
        debugPrint("Failure while updating voip token ===> ${failure.message}");
      });
    } catch (e) {
      debugPrint("Error while hitting update voip token api ===> $e");
    }
  }

  void _resetClockTicks() {
    totalTicks = 0;
    days.value = 0;
    hours.value = 0;
    minutes.value = 0;
    seconds.value = 0;
  }

  @override
  void dispose() {
    try {
      _timer?.cancel();
    } catch (_) {}
    _appStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _safeRun(
    String name,
    Future<void> Function() task,
  ) async {
    try {
      await task();
    } catch (error) {
      debugPrint("Error in $name: $error");
    }
  }
}
