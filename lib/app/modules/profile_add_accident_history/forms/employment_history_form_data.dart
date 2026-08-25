import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmploymentHistoryFormData {
  final TextEditingController companyNameController;
  final TextEditingController supervisorNameController;
  final TextEditingController supervisorMobileController;
  final TextEditingController supervisorOtherMobileController;
  final TextEditingController salaryController;
  final TextEditingController streetAddressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;
  final TextEditingController positionHeldController;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final TextEditingController faxNumberController;
  final TextEditingController emailController;
  final TextEditingController reasonForLeavingController;
  final TextEditingController haulingWhatController;
  final TextEditingController numberOfMonthsController;
  final TextEditingController equipmentController;

  final RxBool isStillWorking;
  final RxBool isFMCSRs;
  final RxBool safetySensitive;
  final RxString haulingWhatText;

  String selectedState;
  String selectedCity;

  EmploymentHistoryFormData({
    TextEditingController? companyNameController,
    TextEditingController? supervisorNameController,
    TextEditingController? supervisorMobileController,
    TextEditingController? supervisorOtherMobileController,
    TextEditingController? salaryController,
    TextEditingController? streetAddressController,
    TextEditingController? cityController,
    TextEditingController? stateController,
    TextEditingController? zipController,
    TextEditingController? positionHeldController,
    TextEditingController? fromDateController,
    TextEditingController? toDateController,
    TextEditingController? faxNumberController,
    TextEditingController? emailController,
    TextEditingController? reasonForLeavingController,
    TextEditingController? haulingWhatController,
    TextEditingController? numberOfMonthsController,
    TextEditingController? equipmentController,
    RxBool? isStillWorking,
    RxBool? isFMCSRs,
    RxBool? safetySensitive,
    RxString? haulingWhatText,
    this.selectedState = '',
    this.selectedCity = '',
  })  : companyNameController =
            companyNameController ?? TextEditingController(),
        supervisorNameController =
            supervisorNameController ?? TextEditingController(),
        supervisorMobileController =
            supervisorMobileController ?? TextEditingController(),
        supervisorOtherMobileController =
            supervisorOtherMobileController ?? TextEditingController(),
        salaryController = salaryController ?? TextEditingController(),
        streetAddressController =
            streetAddressController ?? TextEditingController(),
        cityController = cityController ?? TextEditingController(),
        stateController = stateController ?? TextEditingController(),
        zipController = zipController ?? TextEditingController(),
        positionHeldController =
            positionHeldController ?? TextEditingController(),
        fromDateController = fromDateController ?? TextEditingController(),
        toDateController = toDateController ?? TextEditingController(),
        faxNumberController = faxNumberController ?? TextEditingController(),
        emailController = emailController ?? TextEditingController(),
        reasonForLeavingController =
            reasonForLeavingController ?? TextEditingController(),
        haulingWhatController =
            haulingWhatController ?? TextEditingController(text: 'Dry Van'),
        numberOfMonthsController =
            numberOfMonthsController ?? TextEditingController(),
        equipmentController = equipmentController ?? TextEditingController(),
        isStillWorking = isStillWorking ?? false.obs,
        isFMCSRs = isFMCSRs ?? false.obs,
        safetySensitive = safetySensitive ?? false.obs,
        haulingWhatText = haulingWhatText ?? 'Dry Van'.obs;

  void dispose() {
    companyNameController.dispose();
    supervisorNameController.dispose();
    supervisorMobileController.dispose();
    supervisorOtherMobileController.dispose();
    salaryController.dispose();
    streetAddressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    positionHeldController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    faxNumberController.dispose();
    emailController.dispose();
    reasonForLeavingController.dispose();
    haulingWhatController.dispose();
    numberOfMonthsController.dispose();
    equipmentController.dispose();
  }

  Map<String, dynamic> toJson(String id) {
    return {
      "id": id,
      "company_name": companyNameController.text,
      "supervisor_name": supervisorNameController.text,
      "emp_supervisor_phone": supervisorMobileController.text,
      "emp_salary": salaryController.text,
      "emp_street_address": streetAddressController.text,
      "emp_city": cityController.text,
      "emp_state": stateController.text,
      "emp_zipcode": zipController.text,
      "position_held": positionHeldController.text,
      "from_date": fromDateController.text,
      "to_date": toDateController.text,
      "fax_number": faxNumberController.text,
      "email_address": emailController.text,
      "reason_for_leave": reasonForLeavingController.text,
      "hauling_what": haulingWhatController.text,
      "hauling_experience": numberOfMonthsController.text,
      "hauling_equipment": equipmentController.text,
      "employer_fmcs": isFMCSRs.value,
      "employer_designated": safetySensitive.value,
      "still_working": [isStillWorking.value],
    };
  }
}
