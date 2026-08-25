// ignore_for_file: invalid_use_of_protected_member

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:ts_driver/app/core/gen/fonts.gen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/views/widgets/dropdown_widget.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/theme_extensions.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/widgets/common_widget.dart';
import '../../../auth/presentation/register/views/widgets/license_row.dart';
import '../../../../core/utils/input_utils.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_add_accident_history_controller.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.controller,
    required this.builderIndex,
  });
  final ProfileAddAccidentHistoryController controller;
  final int builderIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 10.w,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(20.r)),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppText(
                  text:
                      '(${builderIndex + 1}/${controller.employmentHistories.length})'),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  splashColor: kMainColor,
                  onTap: () {
                    controller.removeEmploymentHistory(builderIndex);
                  },
                  child: Icon(
                    Icons.delete_forever_outlined,
                    size: 25.h,
                    color: kMainColor,
                  ),
                ),
              )
            ],
          ),
          addVerticalSpace(8.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Company",
            labelText: "Company",
            validatorMsg: "Company required",
            textController: controller
                .employmentHistories[builderIndex].companyNameController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Supervisor's Name",
            labelText: "Supervisor's Name",
            validatorMsg: "Supervisor's Name required",
            textController: controller
                .employmentHistories[builderIndex].supervisorNameController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            inputFormater: [UsNumberInputFormatter()],
            keyboardType: TextInputType.number,
            hintText: "(313)-111-1111",
            labelText: "Supervisor's Phone",
            validatorMsg: "Supervisor's Phone required",
            textController: controller
                .employmentHistories[builderIndex].supervisorMobileController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.number,
            hintText: "Salary",
            labelText: "Salary",
            validatorMsg: "Salary required",
            textController:
                controller.employmentHistories[builderIndex].salaryController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Street Address",
            labelText: "Street Address",
            validatorMsg: "Street Address required",
            textController: controller
                .employmentHistories[builderIndex].streetAddressController,
          ),
          addVerticalSpace(10.h),
          StateDropdownWidget(
            list: controller.states.map((e) => e.name ?? "").toList(),
            selectedItem: controller.selectedEmploymentState[builderIndex],
            onItemSelected: (item) async {
              if (item != null) {
                controller.selectedEmploymentState[builderIndex] = item;
                controller.selectedEmploymentCity[builderIndex] = '';
                final state = controller.states.firstWhere(
                  (element) =>
                      element.name?.toLowerCase() == item.toLowerCase(),
                );
                controller.employmentHistories[builderIndex].stateController
                    .text = state.id.toString();
                controller.isCitiesLoading.value = true;
                await controller.getCitiesByState(state.id.toString());
                controller.isCitiesLoading.value = false;
              }
            },
            isLoading: controller.isStatesLoading,
          ),
          addVerticalSpace(10.h),
          Obx(
            () => CityDropdownWidget(
              list: controller.cities.map((e) => e.name ?? "").toList(),
              selectedItem: controller.selectedEmploymentCity[builderIndex],
              onItemSelected: (item) {
                if (item != null) {
                  controller.selectedEmploymentCity[builderIndex] = item;
                  controller.employmentHistories[builderIndex].cityController
                      .text = item;
                }
              },
              isLoading: controller.isCitiesLoading,
            ),
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.number,
            hintText: "Zip",
            labelText: "Zip",
            validatorMsg: "Zip required",
            textController:
                controller.employmentHistories[builderIndex].zipController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Position Held",
            labelText: "Position Held",
            validatorMsg: "Position Held required",
            textController: controller
                .employmentHistories[builderIndex].positionHeldController,
          ),
          addVerticalSpace(10.h),
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    child: TextFormField(
                      controller: controller
                          .employmentHistories[builderIndex].fromDateController,
                      readOnly: true,
                      style: TextStyle(fontSize: 15.sp),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'from Date is Required';
                        }
                        return null; // return null if the input is valid
                      },
                      onTap: () async {
                        final DateTime? pickedDate =
                            await showAppDatePicker(context);
                        if (pickedDate != null) {
                          final formattedDate =
                              DateFormat('MM-dd-yyyy').format(pickedDate);
                          controller.employmentHistories[builderIndex]
                              .fromDateController.text = formattedDate;
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 30.h, left: 10.w),
                        suffixIcon: const Icon(Icons.calendar_month),
                        suffixIconColor: context.secondaryTextColor,
                        labelStyle: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 14.sp,
                          fontFamily: FontFamily.poppins,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: context.dividerColor),
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 1, color: AppColors.primary),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        hintStyle: TextStyle(fontSize: 16.sp),
                        labelText: 'Select from date',
                        hintText: 'Select from date',
                      ),
                    ),
                  ),
                ),
                addHorizontalSpace(10.w),
                Visibility(
                  visible: !controller
                      .employmentHistories[builderIndex].isStillWorking.value,
                  child: Expanded(
                    child: GestureDetector(
                      child: TextFormField(
                        controller: controller
                            .employmentHistories[builderIndex].toDateController,
                        readOnly: true,
                        style: TextStyle(fontSize: 15.sp),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'to Date is Required';
                          }
                          return null; // return null if the input is valid
                        },
                        onTap: () async {
                          final DateTime? pickedDate =
                              await showAppDatePicker(context);
                          if (pickedDate != null) {
                            final formattedDate =
                                DateFormat('MM-dd-yyyy').format(pickedDate);
                            controller.employmentHistories[builderIndex]
                                .toDateController.text = formattedDate;
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 30.h, left: 10.w),
                          suffixIcon: const Icon(Icons.calendar_month),
                          suffixIconColor: context.secondaryTextColor,
                          labelStyle: TextStyle(
                            color: context.primaryTextColor,
                            fontSize: 14.sp,
                            fontFamily: FontFamily.poppins,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: context.dividerColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                width: 1, color: AppColors.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintStyle: TextStyle(fontSize: 16.sp),
                          labelText: 'Select to date',
                          hintText: 'Select to date',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          addVerticalSpace(10.h),
          Obx(
            () => CustomCheckbox(
              value: controller
                  .employmentHistories[builderIndex].isStillWorking.value,
              text: 'Still working here?',
              onChange: (val) {
                controller.employmentHistories[builderIndex].isStillWorking
                    .value = val!;
              },
            ),
          ),
          addVerticalSpace(20.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.number,
            hintText: "Fax Number",
            labelText: "Fax Number",
            isRequired: false,
            validatorMsg: "",
            textController: controller
                .employmentHistories[builderIndex].faxNumberController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.emailAddress,
            hintText: "Email",
            labelText: "Email",
            isRequired: false,
            validatorMsg: "",
            textController:
                controller.employmentHistories[builderIndex].emailController,
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.text,
            hintText: "Reason for leaving",
            labelText: "Reason for leaving",
            validatorMsg: "Reason for leaving required",
            textController: controller
                .employmentHistories[builderIndex].reasonForLeavingController,
          ),
          addVerticalSpace(20.h),
          const AppText(
            text: 'Driving/Hauling Experience With This Employer',
            size: 16,
            weight: FontWeight.bold,
          ),
          addVerticalSpace(10.h),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                      border: Border.all(color: context.dividerColor),
                      borderRadius: BorderRadius.all(Radius.circular(15.r))),
                  child: DropdownButton<String>(
                    dropdownColor: context.cardColor,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.primaryTextColor,
                    ),
                    iconSize: 30.h,
                    hint: AppText(
                      text: 'Hauling What'.tr,
                      size: 15,
                    ),
                    items: <String>['Dry Van', 'Flatbed', 'Reefer']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.employmentHistories[builderIndex]
                          .haulingWhatController.text = val!;
                      controller.employmentHistories[builderIndex]
                          .haulingWhatText.value = val;
                    },
                  ),
                ),
              ),
              addHorizontalSpace(20.w),
              Obx(() => Expanded(
                    flex: 4,
                    child: AppText(
                      text: controller.employmentHistories[builderIndex]
                          .haulingWhatText.value,
                      color: context.secondaryTextColor,
                    ),
                  )),
            ],
          ),
          addVerticalSpace(10.h),
          CustomTextFieldWidget(
            keyboardType: TextInputType.number,
            hintText: "Number of Months ",
            labelText: "Number of Months ",
            validatorMsg: "Number of Months required ",
            textController: controller
                .employmentHistories[builderIndex].numberOfMonthsController,
          ),
          addVerticalSpace(10.h),
          Obx(() => LicenseRowWidget(
                value:
                    controller.employmentHistories[builderIndex].isFMCSRs.value,
                onChange: (val) {
                  controller.employmentHistories[builderIndex].isFMCSRs.value =
                      val;
                  controller.employmentHistories[builderIndex].isFMCSRs
                      .refresh();
                },
                text:
                    'Were you subject to the FMCSRs while employed by this employer?',
              )),
          addVerticalSpace(10.h),
          Obx(
            () => LicenseRowWidget(
              value: controller
                  .employmentHistories[builderIndex].safetySensitive.value,
              onChange: (val) {
                controller.employmentHistories[builderIndex].safetySensitive
                    .value = val;
                controller.employmentHistories[builderIndex].safetySensitive
                    .refresh();
              },
              text:
                  'Was your job designated as a safety sensitive function in any DOT regulated mode subject to alcohol and controlled substances testing requirements as required by 49 CFR part 40?',
            ),
          ),
        ],
      ),
    );
  }
}

class StateDropdownWidget extends StatelessWidget {
  const StateDropdownWidget({
    super.key,
    required this.list,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isLoading,
    this.dropdownKey,
  });
  final List<String> list;
  final String? selectedItem;
  final void Function(String?) onItemSelected;
  final bool isLoading;
  final GlobalKey<DropdownSearchState>? dropdownKey;

  @override
  Widget build(BuildContext context) {
    return GenericDropdownWidget<String>(
      list: list,
      selectedItem: selectedItem,
      onItemSelected: onItemSelected,
      dropdownKey: dropdownKey,
      isLoading: isLoading,
      bottomSheetLabel: 'Select Your State',
      searchHint: 'search state',
      fieldLabel: 'State',
      fieldHint: 'Select Your State',
      isRequired: true,
      showOnlyLetters: true,
      getName: (item) => item,
    );
  }
}

class CityDropdownWidget extends StatelessWidget {
  const CityDropdownWidget({
    super.key,
    required this.list,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isLoading,
    this.dropdownKey,
  });
  final List<String> list;
  final String? selectedItem;
  final void Function(String?) onItemSelected;
  final RxBool isLoading;
  final GlobalKey<DropdownSearchState>? dropdownKey;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GenericDropdownWidget<String>(
        list: list,
        selectedItem: selectedItem,
        onItemSelected: onItemSelected,
        dropdownKey: dropdownKey,
        isLoading: isLoading.value,
        bottomSheetLabel: 'Select Your City',
        searchHint: 'search city',
        fieldLabel: 'City',
        fieldHint: 'Select Your City',
        isRequired: true,
        showOnlyLetters: true,
        getName: (item) => item,
      ),
    );
  }
}
