// To parse this JSON data, do
//
//     final userEntity = userEntityFromJson(jsonString);

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final PersonalDetailsEntity? personalDetails;
  final String? token;
  final String? profile;

  const UserEntity({
    this.personalDetails,
    this.token,
    this.profile,
  });

  UserEntity copyWith({
    PersonalDetailsEntity? personalDetails,
    String? token,
    String? profile,
  }) =>
      UserEntity(
        personalDetails: personalDetails ?? this.personalDetails,
        token: token ?? this.token,
        profile: profile ?? this.profile,
      );

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        personalDetails: json["personal_details"] == null
            ? null
            : PersonalDetailsEntity.fromJson(json["personal_details"]),
        token: json["token"],
        profile: json["profile"],
      );

  Map<String, dynamic> toJson() => {
        "personal_details": personalDetails?.toJson(),
        "token": token,
        "profile": profile,
      };

  // Check if user has a specific role
  bool hasAnyRole(List<String> roleNames) {
    return personalDetails?.roles?.any(
            (userRole) => roleNames.contains(userRole.name.toLowerCase())) ??
        false;
  }

  // Check if user has all the roles
  bool hasAllRoles(List<String> roleNames) {
    return roleNames.every((role) => hasAnyRole([role]));
  }

  // Check if user can view settlements
  bool get canViewSettlements {
    return personalDetails?.canViewSettlements ?? false;
  }

  @override
  List<Object?> get props => [
        personalDetails,
        token,
        profile,
      ];
}

// ignore: must_be_immutable
class PersonalDetailsEntity extends Equatable {
  final int? applicantId;
  final int? userId;
  final String? name;
  final String? firstName;
  final String? middleName;
  final dynamic maidenName;
  final String? lastName;
  final String? ssNo;
  final String? dob;
  final bool? twoFa;
  String? mobileNumber;
  String? emergencyContactName;
  String? emergencyContactNumber;
  final dynamic otherMobileNumber;
  final String? email;
  final ActiveApplicationEntity? activeApplication;
  final List<RoleEntity>? roles;
  final bool? canViewSettlements;

  PersonalDetailsEntity({
    this.applicantId,
    this.userId,
    this.name,
    this.firstName,
    this.middleName,
    this.maidenName,
    this.lastName,
    this.ssNo,
    this.dob,
    this.twoFa,
    this.mobileNumber,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.otherMobileNumber,
    this.email,
    this.activeApplication,
    this.roles,
    this.canViewSettlements,
  });

  PersonalDetailsEntity copyWith({
    int? applicantId,
    int? userId,
    String? name,
    String? firstName,
    String? middleName,
    dynamic maidenName,
    String? lastName,
    String? ssNo,
    String? dob,
    bool? twoFa,
    String? mobileNumber,
    String? emergencyContactName,
    String? emergencyContactNumber,
    dynamic otherMobileNumber,
    String? email,
    ActiveApplicationEntity? activeApplication,
    List<RoleEntity>? roles,
    bool? canViewSettlements,
  }) =>
      PersonalDetailsEntity(
        applicantId: applicantId ?? this.applicantId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        maidenName: maidenName ?? this.maidenName,
        lastName: lastName ?? this.lastName,
        ssNo: ssNo ?? this.ssNo,
        dob: dob ?? this.dob,
        twoFa: twoFa ?? this.twoFa,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        emergencyContactName: emergencyContactName ?? this.emergencyContactName,
        emergencyContactNumber:
            emergencyContactNumber ?? this.emergencyContactNumber,
        otherMobileNumber: otherMobileNumber ?? this.otherMobileNumber,
        email: email ?? this.email,
        activeApplication: activeApplication ?? this.activeApplication,
        roles: roles ?? this.roles,
        canViewSettlements: canViewSettlements ?? this.canViewSettlements,
      );

  factory PersonalDetailsEntity.fromJson(Map<String, dynamic> json) =>
      PersonalDetailsEntity(
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
        emergencyContactName: json["emergency_contact_name"],
        emergencyContactNumber: json["emergency_contact_number"],
        otherMobileNumber: json["other_mobile_number"],
        email: json["email"],
        activeApplication: json["active_application"] == null
            ? null
            : ActiveApplicationEntity.fromJson(json["active_application"]),
        roles: json["roles"] == null
            ? []
            : List<RoleEntity>.from(
                json["roles"].map((x) => RoleEntity.fromEntity(x))),
        canViewSettlements: json["can_view_settlements"],
      );

  Map<String, dynamic> toJson() => {
        "id": applicantId,
        "user_id": userId,
        "name": name,
        "first_name": firstName,
        "middle_name": middleName,
        "maiden_name": maidenName,
        "last_name": lastName,
        "ss_no": ssNo,
        "dob": dob,
        "two_fa": twoFa,
        "mobile_number": mobileNumber,
        "emergency_contact_name": emergencyContactName,
        "emergency_contact_number": emergencyContactNumber,
        "other_mobile_number": otherMobileNumber,
        "email": email,
        "active_application": activeApplication?.toJson(),
        "roles": List<dynamic>.from(roles!.map((x) => x.toEntity())),
        "can_view_settlements": canViewSettlements,
      };

  @override
  List<Object?> get props => [
        applicantId,
        userId,
        name,
        firstName,
        middleName,
        maidenName,
        lastName,
        ssNo,
        dob,
        twoFa,
        mobileNumber,
        emergencyContactNumber,
        otherMobileNumber,
        email,
        activeApplication,
        roles,
        canViewSettlements,
      ];
}

class RoleEntity extends Equatable {
  final int id;
  final String name;
  final String guardName;
  final String createdAt;
  final String updatedAt;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.guardName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleEntity.fromEntity(Map<String, dynamic> json) {
    return RoleEntity(
      id: json['id'],
      name: json['name'],
      guardName: json['guard_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toEntity() {
    return {
      "id": id,
      "name": name,
      "guard_name": guardName,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, name, guardName, createdAt, updatedAt];
}

// ignore: must_be_immutable
class ActiveApplicationEntity extends Equatable {
  final int? id;
  final int? applicantId;
  final dynamic jobAppliedFor;
  final dynamic companyName;
  final String? jobCategory;
  final dynamic referredBy;
  final String? presentAddress;
  final dynamic presentAddress2;
  final dynamic presentCity;
  final String? presentZip;
  final int? presentState;
  final String? presentCountry;
  final String? yearsAtThisAddress;
  final dynamic previousAddress;
  final dynamic previousAddress2;
  final dynamic previousCity;
  final dynamic previousState;
  final dynamic previousZip;
  final dynamic previousCountry;
  final dynamic previousYearsAtThisAddress;
  final String? cdlName;
  final String? cdlType;
  final String? cdlLicenseExpiration;
  final dynamic abr;
  final dynamic atr;
  final String? cdlExp;
  final String? currentLicenseNum;
  final dynamic cdlDotMc;
  final int? cdlIssuingState;
  final dynamic cdlDotMcExpireDate;
  final dynamic cdlDryVanExp;
  final dynamic cdlFlatbedExp;
  final dynamic cdlReeferExp;
  final String? hasAnyLicense;
  final String? haveYouBeenConvicted;
  final String? refused;
  final String? proofOfDot;
  final String? convictedMisdemeanor;
  final dynamic felonyDescriptionOffense1;
  final dynamic felonyDateConviction1;
  final dynamic felonyCityStateConviction1;
  final dynamic felonyDescriptionOffense2;
  final dynamic felonyDateConviction2;
  final dynamic felonyCityStateConviction2;
  List<AccidentReviewPastYearEntity>? accidentReviewPastYears;
  List<TrafficConvictionPastYearEntity>? trafficConvictionPastYears;
  final List<EmploymentHistoryEntity>? employmentHistories;
  final dynamic contactCurrentEmployer;
  final String? reviewPreviousEmployer;
  final String? reviewPreviousEmployerDriving;
  final String? reviewPspConsent;
  final String? reviewConsentReleaseInfo;
  final String? reviewPreEmployment;
  final String? reviewDriverRights;
  final String? printName;
  final dynamic geolocation;
  final dynamic actionCode;
  final String? medicalCardFile;
  final String? driverLicenseFile;
  final String? applicantSignatureFile;
  final List<UserFileEntity>? userFiles;

  ActiveApplicationEntity({
    this.id,
    this.applicantId,
    this.jobAppliedFor,
    this.companyName,
    this.jobCategory,
    this.referredBy,
    this.presentAddress,
    this.presentAddress2,
    this.presentCity,
    this.presentZip,
    this.presentState,
    this.presentCountry,
    this.yearsAtThisAddress,
    this.previousAddress,
    this.previousAddress2,
    this.previousCity,
    this.previousState,
    this.previousZip,
    this.previousCountry,
    this.previousYearsAtThisAddress,
    this.cdlName,
    this.cdlType,
    this.cdlLicenseExpiration,
    this.abr,
    this.atr,
    this.cdlExp,
    this.currentLicenseNum,
    this.cdlDotMc,
    this.cdlIssuingState,
    this.cdlDotMcExpireDate,
    this.cdlDryVanExp,
    this.cdlFlatbedExp,
    this.cdlReeferExp,
    this.hasAnyLicense,
    this.haveYouBeenConvicted,
    this.refused,
    this.proofOfDot,
    this.convictedMisdemeanor,
    this.felonyDescriptionOffense1,
    this.felonyDateConviction1,
    this.felonyCityStateConviction1,
    this.felonyDescriptionOffense2,
    this.felonyDateConviction2,
    this.felonyCityStateConviction2,
    this.accidentReviewPastYears,
    this.trafficConvictionPastYears,
    this.employmentHistories,
    this.contactCurrentEmployer,
    this.reviewPreviousEmployer,
    this.reviewPreviousEmployerDriving,
    this.reviewPspConsent,
    this.reviewConsentReleaseInfo,
    this.reviewPreEmployment,
    this.reviewDriverRights,
    this.printName,
    this.geolocation,
    this.actionCode,
    this.medicalCardFile,
    this.driverLicenseFile,
    this.applicantSignatureFile,
    this.userFiles,
  });

  ActiveApplicationEntity copyWith({
    int? id,
    int? applicantId,
    dynamic jobAppliedFor,
    dynamic companyName,
    String? jobCategory,
    dynamic referredBy,
    String? presentAddress,
    dynamic presentAddress2,
    dynamic presentCity,
    String? presentZip,
    int? presentState,
    String? presentCountry,
    String? yearsAtThisAddress,
    dynamic previousAddress,
    dynamic previousAddress2,
    dynamic previousCity,
    dynamic previousState,
    dynamic previousZip,
    dynamic previousCountry,
    dynamic previousYearsAtThisAddress,
    String? cdlName,
    String? cdlType,
    String? cdlLicenseExpiration,
    dynamic abr,
    dynamic atr,
    String? cdlExp,
    String? currentLicenseNum,
    dynamic cdlDotMc,
    int? cdlIssuingState,
    dynamic cdlDotMcExpireDate,
    dynamic cdlDryVanExp,
    dynamic cdlFlatbedExp,
    dynamic cdlReeferExp,
    String? hasAnyLicense,
    String? haveYouBeenConvicted,
    String? refused,
    String? proofOfDot,
    String? convictedMisdemeanor,
    dynamic felonyDescriptionOffense1,
    dynamic felonyDateConviction1,
    dynamic felonyCityStateConviction1,
    dynamic felonyDescriptionOffense2,
    dynamic felonyDateConviction2,
    dynamic felonyCityStateConviction2,
    List<AccidentReviewPastYearEntity>? accidentReviewPastYears,
    List<TrafficConvictionPastYearEntity>? trafficConvictionPastYears,
    List<EmploymentHistoryEntity>? employmentHistories,
    dynamic contactCurrentEmployer,
    String? reviewPreviousEmployer,
    String? reviewPreviousEmployerDriving,
    String? reviewPspConsent,
    String? reviewConsentReleaseInfo,
    String? reviewPreEmployment,
    String? reviewDriverRights,
    String? printName,
    dynamic geolocation,
    dynamic actionCode,
    String? medicalCardFile,
    String? driverLicenseFile,
    String? applicantSignatureFile,
    List<UserFileEntity>? userFiles,
  }) =>
      ActiveApplicationEntity(
        id: id ?? this.id,
        applicantId: applicantId ?? this.applicantId,
        jobAppliedFor: jobAppliedFor ?? this.jobAppliedFor,
        companyName: companyName ?? this.companyName,
        jobCategory: jobCategory ?? this.jobCategory,
        referredBy: referredBy ?? this.referredBy,
        presentAddress: presentAddress ?? this.presentAddress,
        presentAddress2: presentAddress2 ?? this.presentAddress2,
        presentCity: presentCity ?? this.presentCity,
        presentZip: presentZip ?? this.presentZip,
        presentState: presentState ?? this.presentState,
        presentCountry: presentCountry ?? this.presentCountry,
        yearsAtThisAddress: yearsAtThisAddress ?? this.yearsAtThisAddress,
        previousAddress: previousAddress ?? this.previousAddress,
        previousAddress2: previousAddress2 ?? this.previousAddress2,
        previousCity: previousCity ?? this.previousCity,
        previousState: previousState ?? this.previousState,
        previousZip: previousZip ?? this.previousZip,
        previousCountry: previousCountry ?? this.previousCountry,
        previousYearsAtThisAddress:
            previousYearsAtThisAddress ?? this.previousYearsAtThisAddress,
        cdlName: cdlName ?? this.cdlName,
        cdlType: cdlType ?? this.cdlType,
        cdlLicenseExpiration: cdlLicenseExpiration ?? this.cdlLicenseExpiration,
        abr: abr ?? this.abr,
        atr: atr ?? this.atr,
        cdlExp: cdlExp ?? this.cdlExp,
        currentLicenseNum: currentLicenseNum ?? this.currentLicenseNum,
        cdlDotMc: cdlDotMc ?? this.cdlDotMc,
        cdlIssuingState: cdlIssuingState ?? this.cdlIssuingState,
        cdlDotMcExpireDate: cdlDotMcExpireDate ?? this.cdlDotMcExpireDate,
        cdlDryVanExp: cdlDryVanExp ?? this.cdlDryVanExp,
        cdlFlatbedExp: cdlFlatbedExp ?? this.cdlFlatbedExp,
        cdlReeferExp: cdlReeferExp ?? this.cdlReeferExp,
        hasAnyLicense: hasAnyLicense ?? this.hasAnyLicense,
        haveYouBeenConvicted: haveYouBeenConvicted ?? this.haveYouBeenConvicted,
        refused: refused ?? this.refused,
        proofOfDot: proofOfDot ?? this.proofOfDot,
        convictedMisdemeanor: convictedMisdemeanor ?? this.convictedMisdemeanor,
        felonyDescriptionOffense1:
            felonyDescriptionOffense1 ?? this.felonyDescriptionOffense1,
        felonyDateConviction1:
            felonyDateConviction1 ?? this.felonyDateConviction1,
        felonyCityStateConviction1:
            felonyCityStateConviction1 ?? this.felonyCityStateConviction1,
        felonyDescriptionOffense2:
            felonyDescriptionOffense2 ?? this.felonyDescriptionOffense2,
        felonyDateConviction2:
            felonyDateConviction2 ?? this.felonyDateConviction2,
        felonyCityStateConviction2:
            felonyCityStateConviction2 ?? this.felonyCityStateConviction2,
        accidentReviewPastYears:
            accidentReviewPastYears ?? this.accidentReviewPastYears,
        trafficConvictionPastYears:
            trafficConvictionPastYears ?? this.trafficConvictionPastYears,
        employmentHistories: employmentHistories ?? this.employmentHistories,
        contactCurrentEmployer:
            contactCurrentEmployer ?? this.contactCurrentEmployer,
        reviewPreviousEmployer:
            reviewPreviousEmployer ?? this.reviewPreviousEmployer,
        reviewPreviousEmployerDriving:
            reviewPreviousEmployerDriving ?? this.reviewPreviousEmployerDriving,
        reviewPspConsent: reviewPspConsent ?? this.reviewPspConsent,
        reviewConsentReleaseInfo:
            reviewConsentReleaseInfo ?? this.reviewConsentReleaseInfo,
        reviewPreEmployment: reviewPreEmployment ?? this.reviewPreEmployment,
        reviewDriverRights: reviewDriverRights ?? this.reviewDriverRights,
        printName: printName ?? this.printName,
        geolocation: geolocation ?? this.geolocation,
        actionCode: actionCode ?? this.actionCode,
        medicalCardFile: medicalCardFile ?? this.medicalCardFile,
        driverLicenseFile: driverLicenseFile ?? this.driverLicenseFile,
        applicantSignatureFile:
            applicantSignatureFile ?? this.applicantSignatureFile,
        userFiles: userFiles ?? this.userFiles,
      );

  factory ActiveApplicationEntity.fromJson(Map<String, dynamic> json) =>
      ActiveApplicationEntity(
        id: json["id"],
        applicantId: json["applicant_id"],
        jobAppliedFor: json["job_applied_for"],
        companyName: json["company_name"],
        jobCategory: json["job_category"],
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
            : List<AccidentReviewPastYearEntity>.from(
                json["accident_review_past_years"]!
                    .map((x) => AccidentReviewPastYearEntity.fromJson(x))),
        trafficConvictionPastYears: json["traffic_conviction_past_years"] ==
                null
            ? []
            : List<TrafficConvictionPastYearEntity>.from(
                json["traffic_conviction_past_years"]!
                    .map((x) => TrafficConvictionPastYearEntity.fromJson(x))),
        employmentHistories: json["employment_histories"] == null
            ? []
            : List<EmploymentHistoryEntity>.from(json["employment_histories"]!
                .map((x) => EmploymentHistoryEntity.fromJson(x))),
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
            : List<UserFileEntity>.from(
                json["user_files"]!.map((x) => UserFileEntity.fromJson(x))),
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

  @override
  List<Object?> get props => [
        id,
        applicantId,
        jobAppliedFor,
        companyName,
        jobCategory,
        referredBy,
        presentAddress,
        presentAddress2,
        presentCity,
        presentZip,
        presentState,
        presentCountry,
        yearsAtThisAddress,
        previousAddress,
        previousAddress2,
        previousCity,
        previousState,
        previousZip,
        previousCountry,
        previousYearsAtThisAddress,
        cdlName,
        cdlType,
        cdlLicenseExpiration,
        abr,
        atr,
        cdlExp,
        currentLicenseNum,
        cdlDotMc,
        cdlIssuingState,
        cdlDotMcExpireDate,
        cdlDryVanExp,
        cdlFlatbedExp,
        cdlReeferExp,
        hasAnyLicense,
        haveYouBeenConvicted,
        refused,
        proofOfDot,
        convictedMisdemeanor,
        felonyDescriptionOffense1,
        felonyDateConviction1,
        felonyCityStateConviction1,
        felonyDescriptionOffense2,
        felonyDateConviction2,
        felonyCityStateConviction2,
        accidentReviewPastYears,
        trafficConvictionPastYears,
        employmentHistories,
        contactCurrentEmployer,
        reviewPreviousEmployer,
        reviewPreviousEmployerDriving,
        reviewPspConsent,
        reviewConsentReleaseInfo,
        reviewPreEmployment,
        reviewDriverRights,
        printName,
        geolocation,
        actionCode,
        medicalCardFile,
        driverLicenseFile,
        applicantSignatureFile,
        userFiles,
      ];
}

class AccidentReviewPastYearEntity extends Equatable {
  final String? accidentDate;
  final String? accidentInjuries;
  final String? accidentFatalities;
  final String? accidentDescription;
  final String? accidentVehicleType;

  const AccidentReviewPastYearEntity({
    this.accidentDate,
    this.accidentInjuries,
    this.accidentFatalities,
    this.accidentDescription,
    this.accidentVehicleType,
  });

  AccidentReviewPastYearEntity copyWith({
    String? accidentDate,
    String? accidentInjuries,
    String? accidentFatalities,
    String? accidentDescription,
    String? accidentVehicleType,
  }) =>
      AccidentReviewPastYearEntity(
        accidentDate: accidentDate ?? this.accidentDate,
        accidentInjuries: accidentInjuries ?? this.accidentInjuries,
        accidentFatalities: accidentFatalities ?? this.accidentFatalities,
        accidentDescription: accidentDescription ?? this.accidentDescription,
        accidentVehicleType: accidentVehicleType ?? this.accidentVehicleType,
      );

  factory AccidentReviewPastYearEntity.fromJson(Map<String, dynamic> json) =>
      AccidentReviewPastYearEntity(
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

  @override
  List<Object?> get props => [
        accidentDate,
        accidentInjuries,
        accidentFatalities,
        accidentDescription,
        accidentVehicleType,
      ];
}

class EmploymentHistoryEntity extends Equatable {
  final String? id;
  final dynamic toDate;
  final String? fromDate;
  final String? empCity;
  final String? empState;
  final String? faxNumber;
  final String? empZipcode;
  final String? companyName;
  final String? haulingWhat;
  final String? emailAddress;
  final dynamic employmerFmcs;
  final String? positionHeld;
  final String? supervisorName;
  final String? haulingEquipment;
  final String? empStreetAddress;
  final String? haulingExperience;
  final dynamic reasonForLeaving;
  final String? employerDesignated;
  final String? empSupervisorPhone;
  final bool? stillWorking;

  const EmploymentHistoryEntity({
    this.id,
    this.toDate,
    this.fromDate,
    this.empCity,
    this.empState,
    this.faxNumber,
    this.empZipcode,
    this.companyName,
    this.haulingWhat,
    this.emailAddress,
    this.employmerFmcs,
    this.positionHeld,
    this.supervisorName,
    this.haulingEquipment,
    this.empStreetAddress,
    this.haulingExperience,
    this.reasonForLeaving,
    this.employerDesignated,
    this.empSupervisorPhone,
    this.stillWorking,
  });

  EmploymentHistoryEntity copyWith({
    String? id,
    dynamic toDate,
    String? fromDate,
    String? empCity,
    String? empState,
    String? faxNumber,
    String? empZipcode,
    String? companyName,
    String? haulingWhat,
    String? emailAddress,
    dynamic employmerFmcs,
    String? positionHeld,
    String? supervisorName,
    String? haulingEquipment,
    String? empStreetAddress,
    String? haulingExperience,
    dynamic reasonForLeaving,
    String? employerDesignated,
    String? empSupervisorPhone,
    bool? stillWorking,
  }) =>
      EmploymentHistoryEntity(
        id: id ?? this.id,
        toDate: toDate ?? this.toDate,
        fromDate: fromDate ?? this.fromDate,
        empCity: empCity ?? this.empCity,
        empState: empState ?? this.empState,
        faxNumber: faxNumber ?? this.faxNumber,
        empZipcode: empZipcode ?? this.empZipcode,
        companyName: companyName ?? this.companyName,
        haulingWhat: haulingWhat ?? this.haulingWhat,
        emailAddress: emailAddress ?? this.emailAddress,
        employmerFmcs: employmerFmcs ?? this.employmerFmcs,
        positionHeld: positionHeld ?? this.positionHeld,
        supervisorName: supervisorName ?? this.supervisorName,
        haulingEquipment: haulingEquipment ?? this.haulingEquipment,
        empStreetAddress: empStreetAddress ?? this.empStreetAddress,
        haulingExperience: haulingExperience ?? this.haulingExperience,
        reasonForLeaving: reasonForLeaving ?? this.reasonForLeaving,
        employerDesignated: employerDesignated ?? this.employerDesignated,
        empSupervisorPhone: empSupervisorPhone ?? this.empSupervisorPhone,
        stillWorking: stillWorking ?? this.stillWorking,
      );

  factory EmploymentHistoryEntity.fromJson(Map<String, dynamic> json) =>
      EmploymentHistoryEntity(
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
        employerDesignated: json["employer_designated"],
        empSupervisorPhone: json["emp_supervisor_phone"],
        stillWorking: json["still_working"],
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

  @override
  List<Object?> get props => [
        id,
        toDate,
        fromDate,
        empCity,
        empState,
        faxNumber,
        empZipcode,
        companyName,
        haulingWhat,
        emailAddress,
        employmerFmcs,
        positionHeld,
        supervisorName,
        haulingEquipment,
        empStreetAddress,
        haulingExperience,
        reasonForLeaving,
        employerDesignated,
        empSupervisorPhone,
        stillWorking,
      ];
}

class UserFileEntity extends Equatable {
  final String? name;
  final String? url;

  const UserFileEntity({
    this.name,
    this.url,
  });

  UserFileEntity copyWith({
    String? name,
    String? url,
  }) =>
      UserFileEntity(
        name: name ?? this.name,
        url: url ?? this.url,
      );

  factory UserFileEntity.fromJson(Map<String, dynamic> json) => UserFileEntity(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };

  @override
  List<Object?> get props => [name, url];
}

class TrafficConvictionPastYearEntity extends Equatable {
  final String? trafficConvictionDate;
  final String? trafficConvictionInjuries;
  final String? trafficConvictionFatalities;
  final String? trafficConvictionDescription;

  const TrafficConvictionPastYearEntity({
    this.trafficConvictionDate,
    this.trafficConvictionInjuries,
    this.trafficConvictionFatalities,
    this.trafficConvictionDescription,
  });

  TrafficConvictionPastYearEntity copyWith({
    String? trafficConvictionDate,
    String? trafficConvictionInjuries,
    String? trafficConvictionFatalities,
    String? trafficConvictionDescription,
  }) =>
      TrafficConvictionPastYearEntity(
        trafficConvictionDate:
            trafficConvictionDate ?? this.trafficConvictionDate,
        trafficConvictionInjuries:
            trafficConvictionInjuries ?? this.trafficConvictionInjuries,
        trafficConvictionFatalities:
            trafficConvictionFatalities ?? this.trafficConvictionFatalities,
        trafficConvictionDescription:
            trafficConvictionDescription ?? this.trafficConvictionDescription,
      );

  factory TrafficConvictionPastYearEntity.fromJson(Map<String, dynamic> json) =>
      TrafficConvictionPastYearEntity(
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

  @override
  List<Object?> get props => [
        trafficConvictionDate,
        trafficConvictionInjuries,
        trafficConvictionFatalities,
        trafficConvictionDescription,
      ];
}
