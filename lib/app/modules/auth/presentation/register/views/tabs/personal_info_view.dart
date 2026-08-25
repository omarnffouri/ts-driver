import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import '../../../../../../core/utils/input_utils.dart';
import '../../controllers/register_controller.dart';
import '../widgets/mobile_number_section.dart';
import '../widgets/register_date_field.dart';
import '../widgets/register_field.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';

class PersonalInfoView extends GetView<RegisterController> {
  const PersonalInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final personalInfoForm = controller.personalInfoForm;

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isCheckingAccount.value,
        color: context.hintColor.withValues(alpha: 0.5),
        progressIndicator: const CircularProgressIndicator(
          color: AppColors.primary,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            child: Form(
              key: personalInfoForm.formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RegisterSection(
                    title: 'Identity',
                    icon: Icons.badge_outlined,
                    children: [
                      RegisterField(
                        controller: personalInfoForm.socialSecNoController,
                        label: 'Social Security No',
                        hint: '---- --- ---- ----',
                        icon: Icons.key_rounded,
                        keyboardType: TextInputType.number,
                        validatorMsg: 'Social Security No Required',
                        onChanged: controller.onSsnChanged,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                          SocialSecurityNumberFormatter(),
                        ],
                      ),
                      if (controller.hideNextBtn.value == false) ...[
                        RegisterField(
                          controller: personalInfoForm.refferedBYController,
                          label: 'Referred by',
                          hint: 'Referred by',
                          icon: Icons.person_search,
                          isRequired: false,
                        ),
                        RegisterField(
                          controller: personalInfoForm.firstNameController,
                          label: 'First Name',
                          hint: 'First Name',
                          icon: Icons.account_circle,
                          validatorMsg: 'First Name Required',
                        ),
                        RegisterField(
                          controller: personalInfoForm.middleNameController,
                          label: 'Middle Name',
                          hint: 'Middle Name',
                          icon: Icons.person_2_outlined,
                          isRequired: false,
                        ),
                        RegisterField(
                          controller: personalInfoForm.lastNameController,
                          label: 'Last Name',
                          hint: 'Last Name',
                          icon: Icons.account_circle_outlined,
                          validatorMsg: 'Last Name Required',
                        ),
                        RegisterDateField(
                          controller: personalInfoForm.birthDateController,
                          label: 'Date of Birth',
                          hint: 'Select Date of birth',
                          validatorMsg: 'Date of Birth Required',
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1940),
                          lastDate: DateTime(2002, 12, 31),
                        ),
                      ],
                    ],
                  ),
                  if (controller.hideNextBtn.value == false) ...[
                    SizedBox(height: 18.h),
                    RegisterSection(
                      title: 'Contact',
                      icon: Icons.contact_phone_outlined,
                      children: [
                        MobileNumberSection(controller: controller),
                        RegisterField(
                          controller: personalInfoForm.emergencyNameController,
                          label: 'Emergency Contact Name',
                          hint: 'Emergency Contact Name',
                          icon: Icons.person_pin_circle_outlined,
                          isRequired: false,
                        ),
                        RegisterField(
                          controller:
                              personalInfoForm.emergencyMobileController,
                          label: 'Emergency Contact Number',
                          hint: '(313)-111-1111',
                          icon: Icons.phone_android,
                          isRequired: false,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                          formatters: [UsNumberInputFormatter()],
                        ),
                        RegisterField(
                          controller: personalInfoForm.otherMobileController,
                          label: 'Other Phone No',
                          hint: '+1(313)111 1111',
                          icon: Icons.add_call,
                          isRequired: false,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                          formatters: [UsNumberInputFormatter()],
                        ),
                        RegisterField(
                          controller: personalInfoForm.emailController,
                          label: 'Email',
                          hint: 'abc123@gmail.com',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validatorMsg: 'Email Address Required',
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    SafeArea(
                      top: false,
                      minimum: EdgeInsets.only(bottom: 8.h),
                      child: Obx(
                        () => RegisterNavBar(
                          showBack: false,
                          enabled: controller.isNextBtnEnabled.value,
                          onNext: controller.onPersonalInfoNext,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
