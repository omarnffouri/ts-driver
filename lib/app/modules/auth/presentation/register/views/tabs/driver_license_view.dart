import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/widgets/common_widget.dart';

import '../../controllers/register_controller.dart';
import '../widgets/document_upload_widget.dart';
import '../widgets/register_date_field.dart';
import '../widgets/register_dropdown_field.dart';
import '../widgets/register_field.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';
import '../widgets/selectable_chip_group.dart';
import '../widgets/yes_no_field.dart';

class DriverLicenseView extends GetView<RegisterController> {
  const DriverLicenseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commercialLicenseForm = controller.commercialLicenseForm;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        child: Obx(
          () => Form(
            key: commercialLicenseForm.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegisterSection(
                  title: 'Commercial Driver\'s License',
                  icon: Icons.badge_outlined,
                  children: [
                    RegisterField(
                      controller: commercialLicenseForm.name,
                      label: 'Name',
                      hint: "Exactly as your driver's license",
                      icon: Icons.person_outline,
                      validatorMsg:
                          "Name Required Exact as your driver's license",
                    ),
                    RegisterField(
                      controller: commercialLicenseForm.licenseNumber,
                      label: "Current Driver's License Number",
                      hint: "Current Driver's License Number",
                      icon: Icons.confirmation_number_outlined,
                      validatorMsg: "Current Driver's License Number Required",
                    ),
                    RegisterDateField(
                      controller: commercialLicenseForm.licenseExpDate,
                      label: 'License Expiration Date',
                      hint: 'License Expiration Date',
                      validatorMsg: 'License Expiration Date Required',
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    ),
                    RegisterDropdownField(
                      label: 'State',
                      hint: 'Select Your State',
                      icon: Icons.map_outlined,
                      sheetTitle: 'Select Your State',
                      searchHint: 'search state',
                      isLoading: controller.isConfigrationLoading.value,
                      value: commercialLicenseForm.selectedDriverState.value,
                      options: controller.stateNames,
                      onSelected: (item) {
                        commercialLicenseForm.selectedDriverState.value = item;
                        final id = controller.stateIdByName(item);
                        if (id == null) return;
                        commercialLicenseForm.issuingState.text = id;
                      },
                    ),
                    SelectableChipGroup(
                      label: 'CDL Type',
                      options: const ['A', 'B', 'C', 'None'],
                      value: controller.cdlType.value,
                      onChanged: (v) => controller.cdlType.value = v,
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Driving Experience',
                  icon: Icons.local_shipping_outlined,
                  children: [
                    RegisterField(
                      controller: commercialLicenseForm.cdlExp,
                      label: 'Years of CDL Experience',
                      hint: 'Years of CDL Experience',
                      icon: Icons.timelapse_outlined,
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      validatorMsg: 'Years of CDL Experience Required',
                    ),
                    RegisterDateField(
                      controller: commercialLicenseForm.dotMedicalExpDate,
                      label: 'DOT Medical Card Expiration Date',
                      hint: 'DOT Medical Card Expiration Date',
                      validatorMsg: 'DOT Medical Card Expiration Date Required',
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RegisterField(
                            controller: commercialLicenseForm.dryVanExpYears,
                            label: 'Dry Van',
                            hint: 'Years',
                            isRequired: false,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: RegisterField(
                            controller: commercialLicenseForm.flatbedExpYears,
                            label: 'Flatbed',
                            hint: 'Years',
                            isRequired: false,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: RegisterField(
                            controller: commercialLicenseForm.reeferExpYears,
                            label: 'Reefer',
                            hint: 'Years',
                            isRequired: false,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Safety Questions',
                  icon: Icons.shield_outlined,
                  gap: 18,
                  children: [
                    YesNoField(
                      question:
                          'Has any license, permit, or privilege ever been suspended, revoked, or denied?',
                      value: controller.hasAnyLicense.value,
                      onChanged: (v) => controller.hasAnyLicense.value = v,
                    ),
                    YesNoField(
                      question:
                          'Have you ever been convicted for driving under the influence of drugs or alcohol?',
                      value: controller.haveYouConvicted.value,
                      onChanged: (v) => controller.haveYouConvicted.value = v,
                    ),
                    YesNoField(
                      question:
                          'Have you ever tested positive or refused to test on any pre-employment drug and / or alcohol test administered by an employer to which you applied for but did not obtain safety sensitive transportation work covered by DOT agency drug and alcohol testing rules during the past 2 years?',
                      value: controller.haveYouRefused.value,
                      onChanged: (v) => controller.haveYouRefused.value = v,
                    ),
                    YesNoField(
                      question:
                          'Have you ever been convicted of a felony or misdemeanor?',
                      value: controller.convictedMisdemeanor.value,
                      onChanged: (v) =>
                          controller.convictedMisdemeanor.value = v,
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Documents',
                  icon: Icons.upload_file_outlined,
                  gap: 12,
                  children: [
                    DocumentUploadWidget(
                      imageFile: controller.medicalCard,
                      label: 'Medical Card',
                      onUpload: () => controller.pickAndAssignImage(
                        fileVariable: controller.medicalCardFile,
                        base64Variable: controller.medicalImg,
                      ),
                    ),
                    DocumentUploadWidget(
                      imageFile: controller.driverLicense,
                      label: "Driver's License",
                      onUpload: () => controller.pickAndAssignImage(
                        fileVariable: controller.driverLicenseFile,
                        base64Variable: controller.driverImg,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SafeArea(
                  top: false,
                  minimum: EdgeInsets.only(bottom: 8.h),
                  child: RegisterNavBar(
                    onBack: () => controller.previousPage(),
                    onNext: () {
                      if (commercialLicenseForm.issuingState.text.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'State is required',
                        );
                        return;
                      }
                      if (controller.cdlType.value.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'Please Select CDL Type',
                        );
                        return;
                      }
                      if (controller.driverLicense == null ||
                          controller.medicalCard == null) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message:
                              'Driver License and Medical Card Are Required',
                        );
                        return;
                      }
                      if (!commercialLicenseForm.formKey.currentState!
                          .validate()) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'Please complete all required fields',
                        );
                        return;
                      }
                      controller.nextPage();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
