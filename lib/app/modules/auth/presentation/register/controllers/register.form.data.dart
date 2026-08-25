// register_form_data.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/user_entity.dart';

// Form controllers for Personal Information
class PersonalInfoForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final refferedBYController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final socialSecNoController = TextEditingController();
  final mobileController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyMobileController = TextEditingController();
  final otherMobileController = TextEditingController();
  final emailController = TextEditingController();

  void fill(PersonalDetailsEntity? details) {
    if (details == null) return;
    firstNameController.text = details.firstName ?? '';
    middleNameController.text = details.middleName ?? '';
    lastNameController.text = details.lastName ?? '';
    emailController.text = details.email ?? '';
    mobileController.text = details.mobileNumber ?? '';
    emergencyMobileController.text = details.emergencyContactNumber ?? '';
    emergencyNameController.text = details.emergencyContactName ?? '';
    birthDateController.text = details.dob ?? '';
    otherMobileController.text = details.otherMobileNumber ?? '';
  }

  void clear() {
    refferedBYController.clear();
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    birthDateController.clear();
    // socialSecNoController.clear();
    mobileController.clear();
    emergencyNameController.clear();
    emergencyMobileController.clear();
    otherMobileController.clear();
    emailController.clear();
  }

  void dispose() {
    refferedBYController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    socialSecNoController.dispose();
    mobileController.dispose();
    emergencyNameController.dispose();
    emergencyMobileController.dispose();
    otherMobileController.dispose();
    emailController.dispose();
  }

  @override
  String toString() {
    return 'PersonalInfoForm('
        'refferedBYController: $refferedBYController, '
        'firstNameController: $firstNameController, '
        'middleNameController: $middleNameController, '
        'lastNameController: $lastNameController, '
        'birthDateController: $birthDateController, '
        'socialSecNoController: $socialSecNoController, '
        'mobileController: $mobileController, '
        'emergencyNameController: $emergencyNameController, '
        'emergencyMobileController: $emergencyMobileController, '
        'otherMobileController: $otherMobileController, '
        'emailController: $emailController)';
  }
}

// Form controllers for Present Address
class PresentAddressForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final address = TextEditingController();
  final country = TextEditingController(text: 'United States');
  final state = TextEditingController();
  final city = TextEditingController();
  final zip = TextEditingController();
  final year = TextEditingController();
  final selectedPresentState = Rxn<String>(null);
  final selectedPresentCity = Rxn<String>(null);

  void dispose() {
    address.dispose();
    country.dispose();
    state.dispose();
    city.dispose();
    zip.dispose();
    year.dispose();
  }

  @override
  String toString() {
    return 'PresentAddressForm('
        'address: $address, '
        'country: $country, '
        'state: $state, '
        'city: $city, '
        'zip: $zip, '
        'year: $year, '
        'selectedPresentState: $selectedPresentState, '
        'selectedPresentCity: $selectedPresentCity)';
  }
}

// Form controllers for Previous Address
class PreviousAddressForm {
  final address = TextEditingController();
  final country = TextEditingController();
  final state = TextEditingController();
  final city = TextEditingController();
  final zip = TextEditingController();
  final year = TextEditingController();
  final selectedPrevState = Rxn<String>(null);
  final selectedPrevCity = Rxn<String>(null);

  void dispose() {
    address.dispose();
    country.dispose();
    state.dispose();
    city.dispose();
    zip.dispose();
    year.dispose();
  }

  // add toString method for debugging
  @override
  String toString() {
    return 'PreviousAddressForm('
        'address: $address, '
        'country: $country, '
        'state: $state, '
        'city: $city, '
        'zip: $zip, '
        'year: $year, '
        'selectedPrevState: $selectedPrevState, '
        'selectedPrevCity: $selectedPrevCity)';
  }
}

// Form controllers for Commercial Driver's License
class CommercialLicenseForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final licenseExpDate = TextEditingController();
  final licenseNumber = TextEditingController();
  final cdlExp = TextEditingController();
  final dotMedicalExpDate = TextEditingController();
  final issuingState = TextEditingController();
  final dryVanExpYears = TextEditingController();
  final flatbedExpYears = TextEditingController();
  final reeferExpYears = TextEditingController();
  final selectedDriverState = Rxn<String>(null);

  void dispose() {
    name.dispose();
    licenseExpDate.dispose();
    licenseNumber.dispose();
    cdlExp.dispose();
    dotMedicalExpDate.dispose();
    issuingState.dispose();
    dryVanExpYears.dispose();
    flatbedExpYears.dispose();
    reeferExpYears.dispose();
  }

  // add toString method for debugging
  @override
  String toString() {
    return 'CommercialLicenseForm('
        'name: $name, '
        'licenseExpDate: $licenseExpDate, '
        'licenseNumber: $licenseNumber, '
        'cdlExpDate: $cdlExp, '
        'dotMedicalExpDate: $dotMedicalExpDate, '
        'issuingState: $issuingState, '
        'dryVanExpYears: $dryVanExpYears, '
        'flatbedExpYears: $flatbedExpYears, '
        'reeferExpYears: $reeferExpYears, '
        'selectedDriverState: $selectedDriverState)';
  }
}

// Form controllers for Accident Review
class AccidentReviewForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final date = TextEditingController();
  final description = TextEditingController();
  final fatalities = TextEditingController();
  final injuries = TextEditingController();
  final aVehicleType = 'Personal'.obs;

  void dispose() {
    date.dispose();
    description.dispose();
    fatalities.dispose();
    injuries.dispose();
  }

  @override
  String toString() {
    return 'AccidentReviewForm('
        'date: $date, '
        'description: $description, '
        'fatalities: $fatalities, '
        'injuries: $injuries, '
        'aVehicleType: $aVehicleType)';
  }
}

// Form controllers for Traffic Conviction
class TrafficConvictionForm {
  final date = TextEditingController();
  final description = TextEditingController();
  final fatalities = TextEditingController();
  final injuries = TextEditingController();
  final tVehicleType = 'Personal'.obs;

  void dispose() {
    date.dispose();
    description.dispose();
    fatalities.dispose();
    injuries.dispose();
  }

  // add toString method for debugging
  @override
  String toString() {
    return 'TrafficConvictionForm('
        'date: $date, '
        'description: $description, '
        'fatalities: $fatalities, '
        'injuries: $injuries, '
        'tVehicleType: $tVehicleType)';
  }
}

// Form controllers for Employment History
class EmploymentHistoryForm {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final companyName = TextEditingController();
  final supervisorName = TextEditingController();
  final supervisorMobileNumber = TextEditingController();
  final supervisorOtherMobileNumber = TextEditingController();
  final salary = TextEditingController();
  final streetAddress = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final zip = TextEditingController();
  final positionHeld = TextEditingController();
  final fromDate = TextEditingController();
  final toDate = TextEditingController();
  final faxNumber = TextEditingController();
  final email = TextEditingController();
  final reasonForLeaving = TextEditingController();
  final haulingWhat = TextEditingController(text: 'Dry Van');
  final numberOfMonths = TextEditingController();
  final equipment = TextEditingController();
  final selectedEmploymentState = Rxn<String>(null);
  final selectedEmploymentCity = Rxn<String>(null);
  final dHaulingWhatTxt = 'Dry Van'.obs;

  void dispose() {
    companyName.dispose();
    supervisorName.dispose();
    supervisorMobileNumber.dispose();
    supervisorOtherMobileNumber.dispose();
    salary.dispose();
    streetAddress.dispose();
    city.dispose();
    state.dispose();
    zip.dispose();
    positionHeld.dispose();
    fromDate.dispose();
    toDate.dispose();
    faxNumber.dispose();
    email.dispose();
    reasonForLeaving.dispose();
    haulingWhat.dispose();
    numberOfMonths.dispose();
    equipment.dispose();
  }

  // add toString method for debugging
  @override
  String toString() {
    return 'EmploymentHistoryForm('
        'companyName: $companyName, '
        'supervisorName: $supervisorName, '
        'supervisorMobileNumber: $supervisorMobileNumber, '
        'supervisorOtherMobileNumber: $supervisorOtherMobileNumber, '
        'salary: $salary, '
        'streetAddress: $streetAddress, '
        'city: $city, '
        'state: $state, '
        'zip: $zip, '
        'positionHeld: $positionHeld, '
        'fromDate: $fromDate, '
        'toDate: $toDate, '
        'faxNumber: $faxNumber, '
        'email: $email, '
        'reasonForLeaving: $reasonForLeaving, '
        'haulingWhat: $haulingWhat, '
        'numberOfMonths: $numberOfMonths, '
        'equipment: $equipment, '
        'selectedEmploymentState: $selectedEmploymentState, '
        'selectedEmploymentCity: $selectedEmploymentCity, '
        'dHaulingWhatTxt: $dHaulingWhatTxt)';
  }
}

// Data Transfer Object (DTO) for the API payload
class RegisterPayload {
  final PersonalInfoForm personalInfo;
  final PresentAddressForm presentAddress;
  final PreviousAddressForm previousAddress;
  final CommercialLicenseForm commercialLicense;
  final AccidentReviewForm accidentReview;
  final TrafficConvictionForm trafficConviction;
  final EmploymentHistoryForm employmentHistory;

  RegisterPayload({
    required this.personalInfo,
    required this.presentAddress,
    required this.previousAddress,
    required this.commercialLicense,
    required this.accidentReview,
    required this.trafficConviction,
    required this.employmentHistory,
  });

  // add print statement to debug the payload

  @override
  String toString() {
    return 'RegisterPayload('
        'personalInfo: ${personalInfo.toString()}, '
        'presentAddress: ${presentAddress.toString()}, '
        'previousAddress: ${previousAddress.toString()}, '
        'commercialLicense: ${commercialLicense.toString()}, '
        'accidentReview: ${accidentReview.toString()}, '
        'trafficConviction: ${trafficConviction.toString()}, '
        'employmentHistory: ${employmentHistory.toString()})';
  }

  Map<String, dynamic> toJson({
    required String jobCategory,
    required String cdlType,
    required String signatureBase64,
    required String medicalImgBase64,
    required String driverImgBase64,
    required bool hasNoAccident,
    required bool hasNoTrafficConviction,
    required bool hasAnyLicense,
    required bool haveYouConvicted,
    required bool haveYouRefused,
    required bool convictedMisdemeanor,
    required bool isFMCSRs,
    required bool safetySensitive,
  }) {
    final Map<String, dynamic> payload = {
      "first_name": personalInfo.firstNameController.text,
      "middle_name": personalInfo.middleNameController.text,
      "last_name": personalInfo.lastNameController.text,
      "ss_no": personalInfo.socialSecNoController.text,
      "dob": personalInfo.birthDateController.text,
      "mobile_number": personalInfo.mobileController.text,
      "emergency_contact_name": personalInfo.emergencyNameController.text,
      "emergency_contact_number": personalInfo.emergencyMobileController.text,
      "other_mobile_number": personalInfo.otherMobileController.text,
      "email": personalInfo.emailController.text,
      "active_application": {
        "job_category": jobCategory,
        "referred_by": personalInfo.refferedBYController.text,
        "present_address": presentAddress.address.text,
        "present_country": presentAddress.country.text,
        "present_state": presentAddress.state.text,
        "present_city": presentAddress.city.text,
        "present_zip": presentAddress.zip.text,
        "years_at_this_address": presentAddress.year.text,
        "previous_address": previousAddress.address.text,
        "previous_state": previousAddress.state.text,
        "previous_city": previousAddress.city.text,
        "previous_zip": previousAddress.zip.text,
        "previous_country": previousAddress.country.text,
        "previous_years_at_this_address": previousAddress.year.text,
        "cdl_name": commercialLicense.name.text,
        "cdl_license_expiration": commercialLicense.licenseExpDate.text,
        "current_license_num": commercialLicense.licenseNumber.text,
        "cdl_type": cdlType,
        "cdl_exp": commercialLicense.cdlExp.text,
        "cdl_dot_mc_expire_date": commercialLicense.dotMedicalExpDate.text,
        "cdl_issuing_state": commercialLicense.issuingState.text,
        "cdl_dry_van_exp": commercialLicense.dryVanExpYears.text,
        "cdl_flatbed_exp": commercialLicense.flatbedExpYears.text,
        "cdl_reefer_exp": commercialLicense.reeferExpYears.text,
        "has_any_license": hasAnyLicense.toString(),
        "have_you_convicted": haveYouConvicted.toString(),
        "refused": haveYouRefused == true ? "1" : "0",
        "convicted_misdemeanor": convictedMisdemeanor ? "1" : "0",
        "accident_review_past_years": <Map<String, String>>[
          {
            "accident_date": accidentReview.date.text,
            "accident_description": accidentReview.description.text,
            "accident_fatalities": accidentReview.fatalities.text,
            "accident_injuries": accidentReview.injuries.text,
            "accident_vehicle_type": accidentReview.aVehicleType.value,
          },
        ],
        "traffic_conviction_past_years": <Map<String, String>>[
          {
            "traffic_conviction_date": trafficConviction.date.text,
            "traffic_conviction_description":
                trafficConviction.description.text,
            "traffic_conviction_fatalities": trafficConviction.fatalities.text,
            "traffic_conviction_injuries": trafficConviction.injuries.text,
            "traffic_conviction_vehicle_type":
                trafficConviction.tVehicleType.value,
          },
        ],
        "employment_histories": <Map<String, String>>[
          {
            "id": idGenerator(),
            "company_name": employmentHistory.companyName.text,
            "supervisor_name": employmentHistory.supervisorName.text,
            "emp_supervisor_phone":
                employmentHistory.supervisorMobileNumber.text,
            "emp_salary": employmentHistory.salary.text,
            "emp_street_address": employmentHistory.streetAddress.text,
            "emp_city": employmentHistory.city.text,
            "emp_state": employmentHistory.state.text,
            "emp_zipcode": employmentHistory.zip.text,
            "position_held": employmentHistory.positionHeld.text,
            "from_date": employmentHistory.fromDate.text,
            "to_date": employmentHistory.toDate.text,
            "fax_number": employmentHistory.faxNumber.text,
            "email_address": employmentHistory.email.text,
            "eReasonForLeaving": employmentHistory.reasonForLeaving.text,
            "hauling_what": employmentHistory.haulingWhat.text,
            "employer_fmcs": isFMCSRs ? "Yes" : "No",
            "hauling_equipment": employmentHistory.equipment.text,
            "hauling_experience": employmentHistory.numberOfMonths.text,
            "employer_designated": safetySensitive ? "Yes" : "No",
          }
        ],
        "applicant_signature_file": signatureBase64,
        "medical_card_file": "data:image/png;base64,$medicalImgBase64",
        "driver_license_file": "data:image/png;base64,$driverImgBase64",
        "job_applied_for": "",
        "proof_of_dot": "1",
        "present_address_2": "",
        "previous_address_2": "",
        "maiden_name": "",
        "abr": "",
        "atr": "",
        "cdl_dot_mc": "",
        "cdl_endorsement": "",
        "addition_licenses": "",
        "contact_current_employer": "",
        "status_code": "",
        "action_code": "",
        "geolocation": "",
        "review_previous_employer": "Yes",
        "review_previous_employer_driving": "Yes",
        "review_psp_consent": "Yes",
        "review_consent_release_info": "Yes",
        "review_pre_employment": "Yes",
        "review_driver_rights": "Yes",
      },
    };

    return payload;
  }
}
