import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/utils/input_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../../controllers/register_controller.dart';
import '../widgets/register_date_field.dart';
import '../widgets/register_dropdown_field.dart';
import '../widgets/register_field.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';
import '../widgets/selectable_chip_group.dart';
import '../widgets/yes_no_field.dart';

class EmploymentHistoryView extends GetView<RegisterController> {
  const EmploymentHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final employmentHistory = controller.employmentHistoryForm;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        child: Obx(
          () => Form(
            key: employmentHistory.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  text:
                      'You must provide accurate dates of employment and phone numbers covering the last ten years (per DOT regulation). We cannot hire you without verifying employment.',
                  size: 13,
                  maxLines: 12,
                  color: context.secondaryTextColor,
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Employer',
                  icon: Icons.business_rounded,
                  children: [
                    RegisterField(
                      controller: employmentHistory.companyName,
                      label: 'Company',
                      hint: 'Company',
                      icon: Icons.business,
                      validatorMsg: 'Company required',
                    ),
                    RegisterField(
                      controller: employmentHistory.supervisorName,
                      label: "Supervisor's Name",
                      hint: "Supervisor's Name",
                      icon: Icons.person,
                      validatorMsg: "Supervisor's Name required",
                    ),
                    RegisterField(
                      controller: employmentHistory.supervisorMobileNumber,
                      label: "Supervisor's Phone",
                      hint: '(313)-111-1111',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.number,
                      formatters: [UsNumberInputFormatter()],
                      validatorMsg: "Supervisor's Phone required",
                    ),
                    RegisterField(
                      controller: employmentHistory.salary,
                      label: 'Salary',
                      hint: 'Salary',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Salary required',
                    ),
                    RegisterField(
                      controller: employmentHistory.streetAddress,
                      label: 'Street Address',
                      hint: 'Street Address',
                      icon: Icons.location_city,
                      validatorMsg: 'Street Address required',
                    ),
                    RegisterDropdownField(
                      label: 'State',
                      hint: 'Select Your State',
                      icon: Icons.map_outlined,
                      sheetTitle: 'Select Your State',
                      searchHint: 'search state',
                      isLoading: controller.isConfigrationLoading.value,
                      options: controller.stateNames,
                      value: employmentHistory.selectedEmploymentState.value,
                      onSelected: (item) async {
                        employmentHistory.selectedEmploymentState.value = item;
                        employmentHistory.selectedEmploymentCity.value = null;
                        final id = controller.stateIdByName(item);
                        employmentHistory.state.text = id ?? '-1';
                        if (id == null) return;
                        controller.isPrevCitiesLoading.value = true;
                        await controller.getCitiesByState(id);
                        controller.isPrevCitiesLoading.value = false;
                      },
                    ),
                    RegisterDropdownField(
                      label: 'City',
                      hint: 'Select Your City',
                      icon: Icons.location_on_outlined,
                      sheetTitle: 'Select Your City',
                      searchHint: 'search city',
                      isLoading: controller.isPrevCitiesLoading.value,
                      options: controller.cityNames,
                      value: employmentHistory.selectedEmploymentCity.value,
                      onSelected: (item) {
                        employmentHistory.selectedEmploymentCity.value = item;
                        employmentHistory.city.text = item;
                      },
                    ),
                    RegisterField(
                      controller: employmentHistory.zip,
                      label: 'Zip',
                      hint: 'Zip',
                      icon: Icons.confirmation_number_outlined,
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Zip required',
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Position & Dates',
                  icon: Icons.work_history_rounded,
                  children: [
                    RegisterField(
                      controller: employmentHistory.positionHeld,
                      label: 'Position Held',
                      hint: 'Position Held',
                      icon: Icons.work,
                      validatorMsg: 'Position Held required',
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RegisterDateField(
                            controller: employmentHistory.fromDate,
                            label: 'From',
                            hint: 'Select from date',
                            validatorMsg: 'from Date is Required',
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2050),
                          ),
                        ),
                        if (controller.isStillWorking.value == false) ...[
                          SizedBox(width: 10.w),
                          Expanded(
                            child: RegisterDateField(
                              controller: employmentHistory.toDate,
                              label: 'To',
                              hint: 'Select to date',
                              validatorMsg: 'to Date is Required',
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            ),
                          ),
                        ],
                      ],
                    ),
                    _StillWorkingCheckbox(
                      value: controller.isStillWorking.value,
                      onChanged: (val) {
                        controller.isStillWorking.value = val;
                      },
                    ),
                    RegisterField(
                      controller: employmentHistory.faxNumber,
                      label: 'Fax Number',
                      hint: 'Fax Number',
                      icon: Icons.fax,
                      isRequired: false,
                      keyboardType: TextInputType.number,
                    ),
                    RegisterField(
                      controller: employmentHistory.email,
                      label: 'Email',
                      hint: 'Email',
                      icon: Icons.email,
                      isRequired: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    RegisterField(
                      controller: employmentHistory.reasonForLeaving,
                      label: 'Reason for leaving',
                      hint: 'Reason for leaving',
                      icon: Icons.description,
                      validatorMsg: 'Reason for leaving required',
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Driving Experience',
                  icon: Icons.local_shipping_rounded,
                  children: [
                    AppText(
                      text: 'Driving/Hauling Experience With This Employer',
                      size: 13,
                      maxLines: 3,
                      weight: FontWeight.w600,
                      color: context.secondaryTextColor,
                    ),
                    SelectableChipGroup(
                      label: 'Hauling What',
                      options: const ['Dry Van', 'Flatbed', 'Reefer'],
                      value: employmentHistory.dHaulingWhatTxt.value,
                      onChanged: (v) {
                        employmentHistory.haulingWhat.text = v;
                        employmentHistory.dHaulingWhatTxt.value = v;
                      },
                    ),
                    RegisterField(
                      controller: employmentHistory.numberOfMonths,
                      label: 'Experience years',
                      hint: 'Experience years',
                      icon: Icons.work_history,
                      isRequired: false,
                      keyboardType: TextInputType.number,
                    ),
                    RegisterField(
                      controller: employmentHistory.equipment,
                      label: 'Equipment',
                      hint: 'Equipment',
                      icon: Icons.settings,
                      isRequired: false,
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                RegisterSection(
                  title: 'Compliance',
                  icon: Icons.verified_user_rounded,
                  children: [
                    YesNoField(
                      question:
                          'Were you subject to the FMCSRs while employed by this employer?',
                      value: controller.isFMCSRs.value,
                      onChanged: (val) {
                        controller.isFMCSRs.value = val;
                      },
                    ),
                    YesNoField(
                      question:
                          'Was your job designated as a safety sensitive function in any DOT regulated mode subject to alcohol and controlled substances testing requirements as required by 49 CFR part 40?',
                      value: controller.safetySensitive.value,
                      onChanged: (val) {
                        controller.safetySensitive.value = val;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SafeArea(
                  top: false,
                  minimum: EdgeInsets.only(bottom: 8.h),
                  child: RegisterNavBar(
                    onBack: () {
                      controller.previousPage();
                    },
                    onNext: () {
                      if (employmentHistory.state.text.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'State is required',
                        );
                        return;
                      }
                      if (employmentHistory.city.text.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'City is required',
                        );
                        return;
                      }
                      if (!employmentHistory.formKey.currentState!.validate()) {
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

class _StillWorkingCheckbox extends StatelessWidget {
  const _StillWorkingCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              height: 22.w,
              width: 22.w,
              child: Checkbox(
                value: value,
                activeColor: AppColors.success,
                checkColor: AppColors.onPrimary,
                side: BorderSide(color: context.dividerColor, width: 1.5.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (val) => onChanged(val ?? false),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AppText(
                text: 'Still working here?',
                size: 13,
                weight: FontWeight.w500,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
