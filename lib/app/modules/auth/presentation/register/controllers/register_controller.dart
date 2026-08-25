// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/enum/job_category.dart';
import 'package:ts_driver/app/core/helpers/signature_helper.dart';
import 'package:ts_driver/app/core/helpers/base_use_case.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';
import 'package:ts_driver/app/core/values/constants.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/views/widgets/register_error_dialog.dart';

import '../../../../../core/data/error/failures.dart';
import '../../../../../core/utils/functions.dart';
import '../../../../../routes/app_pages.dart';
import '../../../../../core/services/injection_service.dart';
import '../../../../../core/widgets/common_widget.dart';
import '../../../data/models/authorization_agreement_model.dart';
import '../../../domain/entities/app_configration_entity.dart';
import '../../../domain/entities/region_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/check_email_verification_usecase.dart';
import '../../../domain/usecases/fetch_existing_profile_usecase.dart';
import '../../../domain/usecases/get_app_configration_usecase.dart';
import '../../../domain/usecases/get_cities_by_state_usecase.dart';
import '../../../domain/usecases/otp_send_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/verify_register_otp_usecase.dart';
import 'register.form.data.dart';

class RegisterController extends GetxController {
  // Dev-only: prefill every field on entry. Guarded by kDebugMode below, so it
  // CANNOT run in a release build — flip to false to test empty-form validation.
  static const bool _prefillInDebug = false;

  // Dev-only: tapping Submit shows the success dialog with fake data instead of
  // calling the API (kDebugMode-guarded). Flip to false for the real call.
  static const bool _previewSuccessInDebug = false;

  // --- Dependency Injection ---
  final _registerUseCase = sl<RegisterUseCase>();
  final _getCitiesByStateUseCase = sl<GetCitiesByStateUseCase>();
  final _fetchExistingProfileUseCase = sl<FetchExistingProfileUseCase>();
  final _checkEmailVerificationUseCase = sl<CheckEmailVerificationUseCase>();
  final _otpSendUseCase = sl<OtpSendUseCase>();
  final _otpRegisterVerifyUseCase = sl<OtpRegisterVerifyUseCase>();
  final _getAppConfigrationUseCase = sl<GetAppConfigrationUseCase>();

  // --- UI State Variables ---
  final pageIndex = 0.obs;
  final hideNextBtn = false.obs;

  // --- Loading States ---
  final isRegistering = false.obs;
  final isVerifying = false.obs;
  final isCitiesLoading = false.obs;
  final isPrevCitiesLoading = false.obs;
  final isConfigrationLoading = false.obs;
  final isCheckingAccount = false.obs;
  final showOtpDialog = false.obs;

  // --- Form Validation and Logic Flags ---
  final isNextBtnEnabled = true.obs;
  final isOtpEnabled = false.obs;
  final isVerified = false.obs;
  final isAllTermsAgreed = false.obs;
  final showPrevAddress = false.obs;
  final showSection = false.obs;
  // --- Form-specific Flags ---
  final hasNoAccedentToReport = true.obs;
  final hasNoTraffictConvictionToReport = true.obs;
  final hasAnyLicense = false.obs;
  final haveYouConvicted = false.obs;
  final haveYouRefused = false.obs;
  final convictedMisdemeanor = false.obs;
  final isFMCSRs = false.obs;
  final safetySensitive = false.obs;
  final isStillWorking = false.obs;

  // --- Form Data and Controllers (DTOs) ---
  final personalInfoForm = PersonalInfoForm();
  final presentAddressForm = PresentAddressForm();
  final previousAddressForm = PreviousAddressForm();
  final commercialLicenseForm = CommercialLicenseForm();
  final accidentReviewForm = AccidentReviewForm();
  final trafficConvictionForm = TrafficConvictionForm();
  final employmentHistoryForm = EmploymentHistoryForm();
  final signatureController = buildSignatureController();

  // --- Reactive Data Variables ---
  final cities = RxList<RegionEntity>();
  final configrations = const AppConfiguration().obs;

  final jobCategory = JobCategory.driver.obs;
  final cdlType = ''.obs;

  final Rxn<File> medicalCardFile = Rxn();
  File? get medicalCard => medicalCardFile.value;
  RxString medicalImg = ''.obs;

  final Rxn<File> driverLicenseFile = Rxn();
  File? get driverLicense => driverLicenseFile.value;
  RxString driverImg = ''.obs;

  // --- Timer and OTP ---
  final _start = 60.obs;
  int get start => _start.value;
  Timer? timer;
  final pinController = TextEditingController();
  final pinPutFocusNode = FocusNode();
  final pinText = ''.obs;
  final mobileText = ''.obs;

  // --- UI Controllers ---
  final pageController = PageController();
  final scrollController = ScrollController();

  // --- Helpers and Utilities ---
  final fileExtensionHelper = FileExtensionHelper();

  // Compact titles shown in the header (kept to a single line).
  final List<String> stepHeaderTitles = [
    'Personal Info',
    'Present Address',
    "Driver's License",
    'Accident Review',
    'Employment History',
    'Authorization',
  ];

  final List<String> stepIcons = [
    Assets.images.icons8Person48.path,
    Assets.images.icons8Address50.path,
    Assets.images.icons8License48.path,
    Assets.images.icons8Accident50.path,
    Assets.images.icons8History50.path,
    Assets.images.icons8License48.path,
  ];

  //Authorization Agreement
  RxList<AuthorizationAgreement> get agreementList => _agreementList;
  final _agreementList = [
    AuthorizationAgreement(
      title: AuthorizationTexts.electronicSignature,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.inquiryToPreviousEmployer,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.drivingHistory,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.pspConsentForm,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.releaseOfInfo,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.substanceConsent,
      isChecked: false,
    ),
    AuthorizationAgreement(
      title: AuthorizationTexts.driversRights,
      isChecked: false,
    ),
  ].obs;

  // --- Public Methods ---

  String get currentStepTitle => stepHeaderTitles[pageIndex.value];

  String get currentJobTitle => jobCategory.value.displayName;

  // State / city dropdown option lists, shared by the address & employment steps.
  List<String> get stateNames =>
      configrations.value.states?.map((e) => e.name ?? '').toList() ?? [''];
  List<String> get cityNames => cities.map((e) => e.name ?? '').toList();

  /// Resolves a state's id from its display name (case-insensitive); null if
  /// the name isn't found.
  String? stateIdByName(String name) {
    final states = configrations.value.states;
    if (states == null) return null;
    for (final s in states) {
      if (s.name?.toLowerCase() == name.toLowerCase()) return s.id?.toString();
    }
    return null;
  }

  void onBackPressed() {
    final currentIndex = pageIndex.value;
    if (currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      pageIndex.value = currentIndex - 1;
      _scrollToActiveStep();
      return;
    }
    Get.back();
  }

  void onPageChanged(int index) {
    pageIndex.value = index;
    _scrollToActiveStep();
  }

  /// Keeps the active step centered in the horizontal stepper rail.
  void _scrollToActiveStep() {
    if (!scrollController.hasClients) return;
    final target = (pageIndex.value * 74.w) - 80.w;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        target.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void checkAllTermsAgreed() {
    isAllTermsAgreed.value = agreementList.every((e) => e.isChecked == true);
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> onPersonalInfoNext() async {
    if (!personalInfoForm.formKey.currentState!.validate()) {
      return;
    }

    final ssn = personalInfoForm.socialSecNoController.text;
    final email = personalInfoForm.emailController.text;

    // Call checkEmail with both SSN and email
    await checkEmail(ssn: ssn, email: email);
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode && _prefillInDebug) _prefillForTesting();
    _setJobCategoryFromArgs();
    _getAppConfigrations();

    ever(isOtpEnabled, (_) => _updateNextBtnState());
    ever(isVerified, (_) => _updateNextBtnState());
  }

  //todo FINALIZED CENTRAL LOGIC for the "Next" button
  void _updateNextBtnState() {
    if (isOtpEnabled.value == false) {
      isNextBtnEnabled.value = true;
      return;
    }
  }

  void _setJobCategoryFromArgs() {
    final arg = Get.arguments as String?;
    if (arg != null) {
      final parsedCategory = JobCategoryExtension.fromApiValue(arg);
      if (parsedCategory != null) {
        debugPrint('Job Category from args: $parsedCategory');
        jobCategory.value = parsedCategory;
      }
    }
  }

  void onSsnChanged(String val) {
    hideNextBtn.value = false;
    if (val.length == 11) {
      checkAccount(ssn: val);
    } else {
      if (isOtpEnabled.value) {
        isNextBtnEnabled.value = false;
        isVerified.value = false;
      }
    }
  }

  bool validateSucc() {
    return presentAddressForm.formKey.currentState!.validate() &&
        showSection.value == false &&
        presentAddressForm.state.text.isNotEmpty &&
        presentAddressForm.city.text.isNotEmpty;
  }

  Future<void> sendOtp() async {
    _start.value = 60;
    final mobileNumber = personalInfoForm.mobileController.text.replaceAll(
      '-',
      '',
    );
    final body = {'mobile_number': mobileNumber};
    await _handleApiCall(
      () => _otpSendUseCase.call(body),
      onSuccess: (_) => startTimer(),
    );
  }

  Future<void> verifyOtp() async {
    final mobileNumber = personalInfoForm.mobileController.text.replaceAll(
      '-',
      '',
    );
    final body = {
      'code': pinController.text,
      'mobile_number': mobileNumber,
    };
    debugPrint("Verifying OTP: $body");
    await _handleApiCall(
      () => _otpRegisterVerifyUseCase.call(body),
      onSuccess: (_) async {
        isNextBtnEnabled.value = true;
        isVerified.value = true;
        showOtpDialog.value = false;
        CommonWidgets.showSnackBar(
          title: 'Success',
          message: 'OTP Verified',
          isError: false,
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(Get.context!);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      isLoadingRx: isVerifying,
    );
  }

  Future<void> register() async {
    // Dev-only preview: show the redesigned success dialog with fake data
    // instead of hitting the API. Never runs in release (kDebugMode).
    if (kDebugMode && _previewSuccessInDebug) {
      Get.back();
      await _showSuccessDialog(_fakeSuccessUser());
      return;
    }

    final Map<String, dynamic>? payload = await _buildRegisterPayload();
    if (payload == null) return;

    Get.back();

    await _handleApiCall(
      () => _registerUseCase.call(payload),
      onSuccess: (UserEntity user) async {
        await _showSuccessDialog(user);
        Get.offAllNamed(Routes.LOGIN);
      },
      isLoadingRx: isRegistering,
    );
  }

  UserEntity _fakeSuccessUser() => UserEntity(
        personalDetails: PersonalDetailsEntity(
          applicantId: 1824,
          firstName: 'John',
          lastName: 'Smith',
        ),
      );

  Future<void> checkAccount({required String ssn}) async {
    personalInfoForm.clear();
    isCheckingAccount.value = true;
    try {
      final result = await _fetchExistingProfileUseCase.call({"ss_no": ssn});
      result.fold(
        (UserEntity user) {
          isNextBtnEnabled.value = true;
          isVerified.value = true;
          mobileText.value = user.personalDetails?.mobileNumber ?? '';
          personalInfoForm.fill(user.personalDetails);
        },
        (Failure failure) {
          mobileText.value = '';
          if (failure.code == 302) {
            _showErrorDialog(failure.message);
          }
        },
      );
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error', message: e.toString());
    } finally {
      isCheckingAccount.value = false;
    }
  }

  Future<void> checkEmail({required String ssn, required String email}) async {
    isCheckingAccount.value = true;
    try {
      final body = {"ss_no": ssn, "email": email};
      final result = await _checkEmailVerificationUseCase.call(body);
      result.fold(
        (bool isVerified) {
          // If verified (true), proceed to next page
          nextPage();
        },
        (Failure failure) {
          final msg = failure.message;
          CommonWidgets.showSnackBar(title: 'Error', message: msg);
        },
      );
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error', message: e.toString());
    } finally {
      isCheckingAccount.value = false;
    }
  }

  Future<Map<String, dynamic>?> _buildRegisterPayload() async {
    if (!isAllTermsAgreed.value) {
      CommonWidgets.showSnackBar(
          title: 'Error', message: 'All Terms are required');
      return null;
    }
    if (signatureController.isEmpty) {
      CommonWidgets.showSnackBar(
          title: 'Error', message: 'You need to Sign First');
      return null;
    }

    final Uint8List? bytes = await signatureController.toPngBytes();
    if (bytes == null) return null;
    final String signatureBase64 = getSignatureBase64(bytes);

    final payload = RegisterPayload(
      personalInfo: personalInfoForm,
      presentAddress: presentAddressForm,
      previousAddress: previousAddressForm,
      commercialLicense: commercialLicenseForm,
      accidentReview: accidentReviewForm,
      trafficConviction: trafficConvictionForm,
      employmentHistory: employmentHistoryForm,
    );

    final Map<String, dynamic> data = payload.toJson(
      jobCategory: jobCategory.value.apiValue,
      cdlType: cdlType.value,
      signatureBase64: signatureBase64,
      medicalImgBase64: medicalImg.value,
      driverImgBase64: driverImg.value,
      hasAnyLicense: hasAnyLicense.value,
      haveYouConvicted: haveYouConvicted.value,
      hasNoAccident: hasNoAccedentToReport.value,
      hasNoTrafficConviction: hasNoTraffictConvictionToReport.value,
      haveYouRefused: haveYouRefused.value,
      convictedMisdemeanor: convictedMisdemeanor.value,
      isFMCSRs: isFMCSRs.value,
      safetySensitive: safetySensitive.value,
    );

    return data;
  }

  Future<void> _getAppConfigrations() async {
    await _handleApiCall(
      () => _getAppConfigrationUseCase.call(const NoParams()),
      onSuccess: (AppConfiguration data) {
        configrations.value = data;
        isOtpEnabled.value = data.isOtpEnabled ?? false;
      },
      isLoadingRx: isConfigrationLoading,
    );
  }

  Future<void> getCitiesByState(String stateId) async {
    await _handleApiCall(
      () => _getCitiesByStateUseCase.call({"state_id": stateId}),
      onSuccess: (List<RegionEntity> fetchedCities) {
        cities.value = fetchedCities;
        debugPrint('Cities: ${cities.length}');
      },
    );
  }

  Future<void> pickAndAssignImage({
    required Rx<File?> fileVariable,
    required RxString base64Variable,
  }) async {
    final File? image = await pickFile();
    if (image != null) {
      final file = File(image.path);
      fileVariable.value = file;
      base64Variable.value = getFileBase64(file);
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<bool?> _showSuccessDialog(UserEntity user) async {
    return await CommonWidgets().showSuccessDialog(user: user);
  }

  void _showErrorDialog(String message) {
    hideNextBtn.value = true;

    showErrorDialog(message);
  }

  String formatMaskedNumber(String number) {
    String cleanNumber =
        number.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    String visible = cleanNumber.substring(0, 4);
    String masked = '*' * (cleanNumber.length - 4);
    return '$visible$masked';
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          timer.cancel();
        } else {
          _start.value--;
        }
      },
    );
  }

  // Generic API call handler
  Future<void> _handleApiCall<T>(
    Future<Either<T, Failure>> Function() apiCall, {
    required void Function(T result) onSuccess,
    void Function(Failure failure)? onFailure,
    RxBool? isLoadingRx,
  }) async {
    isLoadingRx?.value = true;
    try {
      final result = await apiCall();
      result.fold(
        (data) => onSuccess(data),
        (failure) {
          CommonWidgets.showSnackBar(title: 'Error', message: failure.message);
          onFailure?.call(failure);
        },
      );
    } catch (e) {
      CommonWidgets.showSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingRx?.value = false;
    }
  }

  /// Fills every step with sample data so the flow can be walked through fast
  /// during development. Only ever called under [kDebugMode].
  void _prefillForTesting() {
    personalInfoForm.refferedBYController.text = 'Jane Doe';
    personalInfoForm.firstNameController.text = 'test';
    personalInfoForm.middleNameController.text = 'David';
    personalInfoForm.lastNameController.text = 'Smith';
    personalInfoForm.birthDateController.text = '01-15-1990';
    personalInfoForm.socialSecNoController.text = '987-65-4321';
    personalInfoForm.mobileController.text = '555-123-4567';
    personalInfoForm.emergencyNameController.text = 'Mary Smith';
    personalInfoForm.emergencyMobileController.text = '555-987-6543';
    personalInfoForm.otherMobileController.text = '555-555-5555';
    personalInfoForm.emailController.text = 'john.smith@example.com';

    presentAddressForm.address.text = '123 Main St';
    presentAddressForm.country.text = 'United States';
    presentAddressForm.state.text = '1';
    presentAddressForm.city.text = 'Los Angeles';
    presentAddressForm.zip.text = '90001';
    presentAddressForm.year.text = '5';

    previousAddressForm.address.text = '456 Oak Ave';
    previousAddressForm.country.text = 'United States';
    previousAddressForm.state.text = '1';
    previousAddressForm.city.text = 'New York City';
    previousAddressForm.zip.text = '10001';
    previousAddressForm.year.text = '3';

    commercialLicenseForm.name.text = 'John David Smith';
    commercialLicenseForm.licenseExpDate.text = '01-15-2030';
    commercialLicenseForm.licenseNumber.text = 'CDL-1234567';
    commercialLicenseForm.cdlExp.text = '8';
    commercialLicenseForm.dotMedicalExpDate.text = '08-08-2025';
    commercialLicenseForm.issuingState.text = '2';
    commercialLicenseForm.dryVanExpYears.text = '8';
    commercialLicenseForm.flatbedExpYears.text = '1';
    commercialLicenseForm.reeferExpYears.text = '2';

    accidentReviewForm.date.text = '01-15-1990';
    accidentReviewForm.description.text = 'Minor fender bender, no injuries.';
    accidentReviewForm.fatalities.text = '0';
    accidentReviewForm.injuries.text = '0';

    trafficConvictionForm.date.text = '01-15-1990';
    trafficConvictionForm.description.text =
        'Speeding ticket (15 mph over limit).';
    trafficConvictionForm.fatalities.text = '0';
    trafficConvictionForm.injuries.text = '0';

    employmentHistoryForm.companyName.text = 'Acme Trucking Inc.';
    employmentHistoryForm.supervisorName.text = 'Bob Johnson';
    employmentHistoryForm.supervisorMobileNumber.text = '555-444-3333';
    employmentHistoryForm.supervisorOtherMobileNumber.text = 'N/A';
    employmentHistoryForm.salary.text = '65000';
    employmentHistoryForm.streetAddress.text = '789 Industrial Blvd';
    employmentHistoryForm.city.text = 'Dallas';
    employmentHistoryForm.state.text = '1';
    employmentHistoryForm.zip.text = '75201';
    employmentHistoryForm.positionHeld.text = 'Senior Truck Driver';
    employmentHistoryForm.fromDate.text = '01-15-1990';
    employmentHistoryForm.toDate.text = '01-15-2000';
    employmentHistoryForm.faxNumber.text = '555-111-2222';
    employmentHistoryForm.email.text = 'hr@acmetrucking.com';
    employmentHistoryForm.reasonForLeaving.text = 'Relocated to a new city.';
    employmentHistoryForm.numberOfMonths.text = '57';
    employmentHistoryForm.equipment.text = 'Dry Van';
  }

  @override
  void onClose() {
    timer?.cancel();
    pinController.dispose();
    pinPutFocusNode.dispose();
    signatureController.dispose();
    personalInfoForm.dispose();
    presentAddressForm.dispose();
    previousAddressForm.dispose();
    commercialLicenseForm.dispose();
    accidentReviewForm.dispose();
    trafficConvictionForm.dispose();
    employmentHistoryForm.dispose();
    medicalCardFile.close();
    driverLicenseFile.close();
    super.onClose();
  }
}
