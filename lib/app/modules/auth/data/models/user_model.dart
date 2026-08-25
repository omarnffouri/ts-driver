// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

// ignore_for_file: annotate_overrides, overridden_fields, prefer_interpolation_to_compose_strings

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.token,
    required super.personalDetails,
    required super.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        personalDetails: json["personal_details"] == null
            ? null
            : PersonalDetails.fromJson(json["personal_details"]),
        token: json["token"] ?? '',
        profile: json["profile"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "personal_details": personalDetails!.toJson(),
        "token": token,
        "profile": profile,
      };
}

// ignore: must_be_immutable
class PersonalDetails extends PersonalDetailsEntity {
  PersonalDetails({
    super.applicantId,
    super.userId,
    super.name,
    super.firstName,
    super.middleName,
    super.maidenName,
    super.lastName,
    super.ssNo,
    super.dob,
    super.twoFa,
    super.mobileNumber,
    super.otherMobileNumber,
    super.email,
    super.activeApplication,
    super.roles,
    super.canViewSettlements,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      PersonalDetails(
        applicantId: json["id"],
        userId: json["user_id"],
        name: json["first_name"] + " " + json["last_name"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        maidenName: json["maiden_name"],
        lastName: json["last_name"],
        ssNo: json["ss_no"],
        dob: json["dob"],
        twoFa: json["two_fa"],
        mobileNumber: json["mobile_number"],
        otherMobileNumber: json["other_mobile_number"],
        email: json["email"],
        activeApplication: json["active_application"] == null
            ? null
            : ActiveApplication.fromJson(json["active_application"]),
        roles: json["roles"] == null
            ? []
            : List<RoleEntity>.from(
                json["roles"].map((x) => RoleEntity.fromEntity(x))),
        canViewSettlements: json["can_view_settlements"] is bool
            ? json["can_view_settlements"] as bool
            : json["can_view_settlements"] == 1,
      );

  Map<String, dynamic> toJson() => {
        "id": applicantId,
        "user_id": userId,
        "first_name": firstName,
        "middle_name": middleName,
        "maiden_name": maidenName,
        "last_name": lastName,
        "ss_no": ssNo,
        "dob": "$dob",
        "two_fa": twoFa,
        "mobile_number": mobileNumber,
        "other_mobile_number": otherMobileNumber,
        "email": email,
        "active_application": activeApplication?.toJson(),
        "roles": List<dynamic>.from(roles!.map((x) => x.toEntity())),
        "can_view_settlements": canViewSettlements,
      };
}

// ignore: must_be_immutable
class ActiveApplication extends ActiveApplicationEntity {
  ActiveApplication({
    super.id,
    super.applicantId,
    super.jobAppliedFor,
    super.companyName,
    super.jobCategory,
    super.referredBy,
    super.presentAddress,
    super.presentAddress2,
    super.presentCity,
    super.presentZip,
    super.presentState,
    super.presentCountry,
    super.yearsAtThisAddress,
    super.previousAddress,
    super.previousAddress2,
    super.previousCity,
    super.previousState,
    super.previousZip,
    super.previousCountry,
    super.previousYearsAtThisAddress,
    super.cdlName,
    super.cdlType,
    super.cdlLicenseExpiration,
    super.abr,
    super.atr,
    super.cdlExp,
    super.currentLicenseNum,
    super.cdlDotMc,
    super.cdlIssuingState,
    super.cdlDotMcExpireDate,
    super.cdlDryVanExp,
    super.cdlFlatbedExp,
    super.cdlReeferExp,
    super.hasAnyLicense,
    super.haveYouBeenConvicted,
    super.refused,
    super.proofOfDot,
    super.convictedMisdemeanor,
    super.felonyDescriptionOffense1,
    super.felonyDateConviction1,
    super.felonyCityStateConviction1,
    super.felonyDescriptionOffense2,
    super.felonyDateConviction2,
    super.felonyCityStateConviction2,
    super.accidentReviewPastYears,
    super.trafficConvictionPastYears,
    super.employmentHistories,
    super.contactCurrentEmployer,
    super.reviewPreviousEmployer,
    super.reviewPreviousEmployerDriving,
    super.reviewPspConsent,
    super.reviewConsentReleaseInfo,
    super.reviewPreEmployment,
    super.reviewDriverRights,
    super.printName,
    super.geolocation,
    super.actionCode,
    super.medicalCardFile,
    super.driverLicenseFile,
    super.applicantSignatureFile,
    super.userFiles,
  });

  factory ActiveApplication.fromJson(Map<String, dynamic> json) =>
      ActiveApplication(
        id: json["id"],
        applicantId: json["applicant_id"],
        jobAppliedFor: json["job_applied_for"],
        companyName: json["company_name"],
        jobCategory: json["job_category"] == "cat_driver"
            ? "Driver"
            : json["job_category"] == "cat_owner_partner"
                ? "Owner Partner"
                : "Owner Operator",
        referredBy: json["referred_by"],
        presentAddress: json["present_address"],
        presentAddress2: json["present_address2"],
        presentCity: json["present_city"],
        presentZip: json["present_zip"],
        presentState: json["present_state"],
        presentCountry: json["present_country"],
        yearsAtThisAddress: json["years_at_this_address"],
        previousAddress: json["previous_address"],
        previousAddress2: json["previous_address2"],
        previousCity: json["previous_city"],
        previousState: json["previous_state"],
        previousZip: json["previous_zip"],
        previousCountry: json["previous_country"],
        previousYearsAtThisAddress: json["previous_years_at_this_address"],
        cdlName: json["cdl_name"],
        cdlType: json["cdl_type"],
        cdlLicenseExpiration: json["cdl_license_expiration"],
        abr: json["abr"],
        atr: json["atr"],
        cdlExp: json["cdl_exp"],
        currentLicenseNum: json["current_license_num"],
        cdlDotMc: json["cdl_dot_mc"],
        cdlIssuingState: json["cdl_issuing_state"],
        cdlDotMcExpireDate: json["cdl_dot_mc_expire_date"],
        cdlDryVanExp: json["cdl_dry_van_exp"],
        cdlFlatbedExp: json["cdl_flatbed_exp"],
        cdlReeferExp: json["cdl_reefer_exp"],
        hasAnyLicense: json["has_any_license"],
        haveYouBeenConvicted: json["have_you_been_convicted"],
        refused: json["refused"],
        proofOfDot: json["proof_of_dot"],
        convictedMisdemeanor: json["convicted_misdemeanor"],
        felonyDescriptionOffense1: json["felony_description_offense1"],
        felonyDateConviction1: json["felony_date_conviction1"],
        felonyCityStateConviction1: json["felony_city_state_conviction1"],
        felonyDescriptionOffense2: json["felony_description_offense2"],
        felonyDateConviction2: json["felony_date_conviction2"],
        felonyCityStateConviction2: json["felony_city_state_conviction2"],
        accidentReviewPastYears: json["accident_review_past_years"] == null
            ? []
            : List<AccidentReviewPastYear>.from(
                json["accident_review_past_years"]!
                    .map((x) => AccidentReviewPastYear.fromJson(x))),
        trafficConvictionPastYears:
            json["traffic_conviction_past_years"] == null
                ? []
                : List<TrafficConvictionPastYear>.from(
                    json["traffic_conviction_past_years"]!
                        .map((x) => TrafficConvictionPastYear.fromJson(x))),
        employmentHistories: json["employment_histories"] == null
            ? []
            : List<EmploymentHistory>.from(
                json["employment_histories"]!.map((x) {
                if (x["from_date"] == null) {
                  return null;
                }
                return EmploymentHistory.fromJson(x);
              }).where((element) => element != null)),
        contactCurrentEmployer: json["contact_current_employer"],
        reviewPreviousEmployer: json["review_previous_employer"],
        reviewPreviousEmployerDriving: json["review_previous_employer_driving"],
        reviewPspConsent: json["review_psp_consent"],
        reviewConsentReleaseInfo: json["review_consent_release_info"],
        reviewPreEmployment: json["review_pre_employment"],
        reviewDriverRights: json["review_driver_rights"],
        printName: json["print_name"],
        geolocation: json["geolocation"],
        actionCode: json["action_code"],
        medicalCardFile: json["medical_card_file"],
        driverLicenseFile: json["driver_license_file"],
        applicantSignatureFile: json["applicant_signature_file"],
        userFiles: json["user_files"] == null
            ? []
            : List<UserFile>.from(
                json["user_files"]!.map((x) => UserFile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "applicant_id": applicantId,
        "job_applied_for": jobAppliedFor,
        "company_name": companyName,
        "job_category": jobCategory,
        "referred_by": referredBy,
        "present_address": presentAddress,
        "present_address2": presentAddress2,
        "present_city": presentCity,
        "present_zip": presentZip,
        "present_state": presentState,
        "present_country": presentCountry,
        "years_at_this_address": yearsAtThisAddress,
        "previous_address": previousAddress,
        "previous_address2": previousAddress2,
        "previous_city": previousCity,
        "previous_state": previousState,
        "previous_zip": previousZip,
        "previous_country": previousCountry,
        "previous_years_at_this_address": previousYearsAtThisAddress,
        "cdl_name": cdlName,
        "cdl_type": cdlType,
        "cdl_license_expiration": cdlLicenseExpiration,
        "abr": abr,
        "atr": atr,
        "cdl_exp": cdlExp,
        "current_license_num": currentLicenseNum,
        "cdl_dot_mc": cdlDotMc,
        "cdl_issuing_state": cdlIssuingState,
        "cdl_dot_mc_expire_date": cdlDotMcExpireDate,
        "cdl_dry_van_exp": cdlDryVanExp,
        "cdl_flatbed_exp": cdlFlatbedExp,
        "cdl_reefer_exp": cdlReeferExp,
        "has_any_license": hasAnyLicense,
        "have_you_been_convicted": haveYouBeenConvicted,
        "refused": refused,
        "proof_of_dot": proofOfDot,
        "convicted_misdemeanor": convictedMisdemeanor,
        "felony_description_offense1": felonyDescriptionOffense1,
        "felony_date_conviction1": felonyDateConviction1,
        "felony_city_state_conviction1": felonyCityStateConviction1,
        "felony_description_offense2": felonyDescriptionOffense2,
        "felony_date_conviction2": felonyDateConviction2,
        "felony_city_state_conviction2": felonyCityStateConviction2,
        "accident_review_past_years": accidentReviewPastYears == null
            ? []
            : List<dynamic>.from(
                accidentReviewPastYears!.map((x) => x.toJson())),
        "traffic_conviction_past_years": trafficConvictionPastYears == null
            ? []
            : List<dynamic>.from(
                trafficConvictionPastYears!.map((x) => x.toJson())),
        "employment_histories": employmentHistories == null
            ? []
            : List<dynamic>.from(employmentHistories!.map((x) => x.toJson())),
        "contact_current_employer": contactCurrentEmployer,
        "review_previous_employer": reviewPreviousEmployer,
        "review_previous_employer_driving": reviewPreviousEmployerDriving,
        "review_psp_consent": reviewPspConsent,
        "review_consent_release_info": reviewConsentReleaseInfo,
        "review_pre_employment": reviewPreEmployment,
        "review_driver_rights": reviewDriverRights,
        "print_name": printName,
        "geolocation": geolocation,
        "action_code": actionCode,
        "medical_card_file": medicalCardFile,
        "driver_license_file": driverLicenseFile,
        "applicant_signature_file": applicantSignatureFile,
        "user_files": userFiles == null
            ? []
            : List<dynamic>.from(userFiles!.map((x) => x.toJson())),
      };
}

class UserFile extends UserFileEntity {
  const UserFile({
    super.name,
    super.url,
  });

  factory UserFile.fromJson(Map<String, dynamic> json) => UserFile(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };
}

class AccidentReviewPastYear extends AccidentReviewPastYearEntity {
  const AccidentReviewPastYear({
    super.accidentDate,
    super.accidentInjuries,
    super.accidentFatalities,
    super.accidentDescription,
    super.accidentVehicleType,
  });

  factory AccidentReviewPastYear.fromJson(Map<String, dynamic> json) =>
      AccidentReviewPastYear(
        accidentDate: json["accident_date"],
        accidentInjuries: json["accident_injuries"],
        accidentFatalities: json["accident_fatalities"],
        accidentDescription: json["accident_description"],
        accidentVehicleType: json["accident_vehicle_type"],
      );

  Map<String, dynamic> toJson() => {
        "accident_date": accidentDate,
        "accident_injuries": accidentInjuries,
        "accident_fatalities": accidentFatalities,
        "accident_description": accidentDescription,
        "accident_vehicle_type": accidentVehicleType,
      };
}

class EmploymentHistory extends EmploymentHistoryEntity {
  const EmploymentHistory({
    super.id,
    super.toDate,
    super.fromDate,
    super.empCity,
    super.empState,
    super.faxNumber,
    super.empZipcode,
    super.companyName,
    super.haulingWhat,
    super.emailAddress,
    super.employmerFmcs,
    super.positionHeld,
    super.supervisorName,
    super.haulingEquipment,
    super.empStreetAddress,
    super.haulingExperience,
    super.reasonForLeaving,
    super.employerDesignated,
    super.empSupervisorPhone,
    super.stillWorking,
  });

  factory EmploymentHistory.fromJson(Map<String, dynamic> json) =>
      EmploymentHistory(
        id: json["id"],
        toDate: json["to_date"],
        fromDate: json["from_date"],
        empCity: json["emp_city"],
        empState: json["emp_state"],
        faxNumber: json["fax_number"],
        empZipcode: json["emp_zipcode"],
        companyName: json["company_name"],
        haulingWhat: json["hauling_what"],
        emailAddress: json["email_address"],
        employmerFmcs: json["employmer_fmcs"],
        positionHeld: json["position_held"],
        supervisorName: json["supervisor_name"],
        haulingEquipment: json["hauling_equipment"],
        empStreetAddress: json["emp_street_address"],
        haulingExperience: json["hauling_experience"],
        reasonForLeaving: json["reason_for_leaving"],
        employerDesignated: json["employer_designated"].toString(),
        empSupervisorPhone: json["emp_supervisor_phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "to_date": toDate,
        "from_date": fromDate,
        "emp_city": empCity,
        "emp_state": empState,
        "fax_number": faxNumber,
        "emp_zipcode": empZipcode,
        "company_name": companyName,
        "hauling_what": haulingWhat,
        "email_address": emailAddress,
        "employmer_fmcs": employmerFmcs,
        "position_held": positionHeld,
        "supervisor_name": supervisorName,
        "hauling_equipment": haulingEquipment,
        "emp_street_address": empStreetAddress,
        "hauling_experience": haulingExperience,
        "reason_for_leaving": reasonForLeaving,
        "employer_designated": employerDesignated,
        "emp_supervisor_phone": empSupervisorPhone,
        "still_working": stillWorking,
      };
}

class TrafficConvictionPastYear extends TrafficConvictionPastYearEntity {
  const TrafficConvictionPastYear({
    super.trafficConvictionDate,
    super.trafficConvictionInjuries,
    super.trafficConvictionFatalities,
    super.trafficConvictionDescription,
  });

  factory TrafficConvictionPastYear.fromJson(Map<String, dynamic> json) =>
      TrafficConvictionPastYear(
        trafficConvictionDate: json["traffic_conviction_date"],
        trafficConvictionInjuries: json["traffic_conviction_injuries"],
        trafficConvictionFatalities: json["traffic_conviction_fatalities"],
        trafficConvictionDescription: json["traffic_conviction_description"],
      );

  Map<String, dynamic> toJson() => {
        "traffic_conviction_date": trafficConvictionDate,
        "traffic_conviction_injuries": trafficConvictionInjuries,
        "traffic_conviction_fatalities": trafficConvictionFatalities,
        "traffic_conviction_description": trafficConvictionDescription,
      };
}
