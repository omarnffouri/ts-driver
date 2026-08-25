import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/controllers/register_controller.dart';

import '../widgets/register_dropdown_field.dart';
import '../widgets/register_field.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';

class PresentAddressView extends GetView<RegisterController> {
  const PresentAddressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presentAddressForm = controller.presentAddressForm;
    final previousAddressForm = controller.previousAddressForm;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        child: Obx(
          () => Form(
            key: presentAddressForm.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegisterSection(
                  title: 'Present Address',
                  icon: Icons.home_outlined,
                  children: [
                    RegisterField(
                      controller: presentAddressForm.address,
                      label: 'Present Address',
                      hint: 'Street, ABCD, 5324',
                      icon: Icons.pin_drop_outlined,
                      validatorMsg: 'Present Address Required',
                      keyboardType: TextInputType.text,
                    ),
                    RegisterDropdownField(
                      label: 'State',
                      hint: 'Select Your State',
                      icon: Icons.map_outlined,
                      searchHint: 'search state',
                      sheetTitle: 'Select Your State',
                      isLoading: controller.isConfigrationLoading.value,
                      options: controller.stateNames,
                      value: presentAddressForm.selectedPresentState.value,
                      onSelected: (item) async {
                        presentAddressForm.selectedPresentState.value = item;
                        presentAddressForm.selectedPresentCity.value = null;
                        final id = controller.stateIdByName(item);
                        if (id == null) return;
                        presentAddressForm.state.text = id;
                        controller.isCitiesLoading.value = true;
                        await controller.getCitiesByState(id);
                        controller.isCitiesLoading.value = false;
                      },
                    ),
                    RegisterDropdownField(
                      label: 'City',
                      hint: 'Select Your City',
                      icon: Icons.location_city_outlined,
                      searchHint: 'search city',
                      sheetTitle: 'Select Your City',
                      isLoading: controller.isCitiesLoading.value,
                      options: controller.cityNames,
                      value: presentAddressForm.selectedPresentCity.value,
                      onSelected: (item) {
                        presentAddressForm.selectedPresentCity.value = item;
                        presentAddressForm.city.text = item;
                      },
                    ),
                    RegisterField(
                      controller: presentAddressForm.zip,
                      label: 'ZIP',
                      hint: '0000',
                      icon: Icons.confirmation_number_outlined,
                      validatorMsg: 'Zip Required',
                      keyboardType: TextInputType.phone,
                    ),
                    RegisterField(
                      controller: presentAddressForm.year,
                      label: 'Years at this address',
                      hint: '6',
                      icon: Icons.calendar_today_outlined,
                      validatorMsg: 'Years of this address Required',
                      keyboardType: TextInputType.phone,
                      onChanged: (val) {
                        if (val.isNotEmpty && int.parse(val) < 7) {
                          controller.showSection.value = true;
                        } else {
                          controller.showSection.value = false;
                          controller.showPrevAddress.value = false;
                        }
                      },
                    ),
                  ],
                ),
                if (controller.showSection.value) ...[
                  SizedBox(height: 14.h),
                  AppText(
                    text:
                        'If the current address is less than 7 years, List below the most recent addresses for past 7 years. (Click the add button to add more addresses)',
                    size: 13,
                    maxLines: 6,
                    color: context.secondaryTextColor,
                  ),
                  SizedBox(height: 12.h),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.showPrevAddress.value = true,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: context.primaryTint,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: .35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.primary, size: 20.w),
                            SizedBox(width: 8.w),
                            const AppText(
                              text: 'Add previous address',
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                Visibility(
                  visible: controller.showPrevAddress.value,
                  child: Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: RegisterSection(
                      title: 'Previous Address',
                      icon: Icons.history_rounded,
                      children: [
                        RegisterField(
                          controller: previousAddressForm.address,
                          label: 'Previous address',
                          hint: 'Your Previous Address Location',
                          icon: Icons.pin_drop_outlined,
                          isRequired: false,
                          validatorMsg:
                              'Your Previous Address Location  Required',
                          keyboardType: TextInputType.text,
                        ),
                        RegisterField(
                          controller: previousAddressForm.country,
                          label: 'Previous Country',
                          hint: 'Previous Country Name',
                          icon: Icons.public_outlined,
                          isRequired: false,
                          validatorMsg: 'Country Name Required',
                          keyboardType: TextInputType.text,
                        ),
                        RegisterDropdownField(
                          label: 'State',
                          hint: 'Select Your State',
                          icon: Icons.map_outlined,
                          searchHint: 'search state',
                          sheetTitle: 'Select Your State',
                          isRequired: false,
                          isLoading: controller.isConfigrationLoading.value,
                          options: controller.stateNames,
                          value: previousAddressForm.selectedPrevState.value,
                          onSelected: (item) async {
                            previousAddressForm.selectedPrevState.value = item;
                            previousAddressForm.selectedPrevCity.value = null;
                            final id = controller.stateIdByName(item);
                            if (id == null) return;
                            previousAddressForm.state.text = id;
                            controller.isPrevCitiesLoading.value = true;
                            await controller.getCitiesByState(id);
                            controller.isPrevCitiesLoading.value = false;
                          },
                        ),
                        RegisterDropdownField(
                          label: 'City',
                          hint: 'Select Your City',
                          icon: Icons.location_city_outlined,
                          searchHint: 'search city',
                          sheetTitle: 'Select Your City',
                          isRequired: false,
                          isLoading: controller.isPrevCitiesLoading.value,
                          options: controller.cityNames,
                          value: previousAddressForm.selectedPrevCity.value,
                          onSelected: (item) {
                            previousAddressForm.selectedPrevCity.value = item;
                            previousAddressForm.city.text = item;
                          },
                        ),
                        RegisterField(
                          controller: previousAddressForm.zip,
                          label: 'Zip',
                          hint: '0000',
                          icon: Icons.confirmation_number_outlined,
                          isRequired: false,
                          validatorMsg: 'Zip Name Required',
                          keyboardType: TextInputType.phone,
                        ),
                        RegisterField(
                          controller: previousAddressForm.year,
                          label: 'Years at address',
                          hint: 'Years at address',
                          icon: Icons.calendar_today_outlined,
                          isRequired: false,
                          validatorMsg: 'Years at address Required',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
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
                      if (presentAddressForm.state.text.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'State is required',
                        );
                        return;
                      }
                      if (presentAddressForm.city.text.isEmpty) {
                        CommonWidgets.showSnackBar(
                          title: 'Error'.tr,
                          message: 'City is required',
                        );
                        return;
                      }
                      if (!presentAddressForm.formKey.currentState!
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
