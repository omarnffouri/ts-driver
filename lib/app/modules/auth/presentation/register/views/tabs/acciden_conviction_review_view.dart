import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/modules/auth/presentation/register/controllers/register_controller.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import '../widgets/register_date_field.dart';
import '../widgets/register_field.dart';
import '../widgets/register_nav_bar.dart';
import '../widgets/register_section.dart';
import '../widgets/selectable_chip_group.dart';
import '../widgets/yes_no_field.dart';

class AccidenConvictionReviewView extends GetView<RegisterController> {
  const AccidenConvictionReviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accidentForm = controller.accidentReviewForm;
    final trafficForm = controller.trafficConvictionForm;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      child: Obx(
        () => Form(
          key: accidentForm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _reportSection(
                context,
                keyPrefix: 'accident',
                title: 'Accident Review for Past 5 Years',
                icon: Icons.car_crash_rounded,
                question: 'Any accidents reports?',
                note: '*No accidents reports',
                hasNoFlag: controller.hasNoAccedentToReport,
                date: accidentForm.date,
                dateLabel: 'Accident Date',
                dateHint: 'Select accident date',
                description: accidentForm.description,
                fatalities: accidentForm.fatalities,
                injuries: accidentForm.injuries,
                vehicleType: accidentForm.aVehicleType,
              ),
              SizedBox(height: 18.h),
              _reportSection(
                context,
                keyPrefix: 'traffic',
                title: 'Traffic Convictions',
                icon: Icons.gavel_rounded,
                question: 'Any traffic convictions or forfeitures reports?',
                note: '*No traffic convications',
                hasNoFlag: controller.hasNoTraffictConvictionToReport,
                date: trafficForm.date,
                dateLabel: 'Conviction Date',
                dateHint: 'Select conviction date',
                description: trafficForm.description,
                fatalities: trafficForm.fatalities,
                injuries: trafficForm.injuries,
                vehicleType: trafficForm.tVehicleType,
              ),
              SizedBox(height: 24.h),
              SafeArea(
                top: false,
                minimum: EdgeInsets.only(bottom: 8.h),
                child: RegisterNavBar(
                  onBack: controller.previousPage,
                  onNext: () {
                    if (controller.hasNoAccedentToReport.value &&
                        controller.hasNoTraffictConvictionToReport.value) {
                      controller.nextPage();
                    } else {
                      if (!accidentForm.formKey.currentState!.validate()) {
                        CommonWidgets.showSnackBar(
                          title: 'Error',
                          message: 'All required fields must be filled.',
                        );
                        return;
                      }
                      controller.nextPage();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One report block (accident or traffic conviction): a Yes/No question whose
  /// "No" answer collapses to a note, and whose "Yes" reveals the detail form.
  Widget _reportSection(
    BuildContext context, {
    required String keyPrefix,
    required String title,
    required IconData icon,
    required String question,
    required String note,
    required RxBool hasNoFlag,
    required TextEditingController date,
    required String dateLabel,
    required String dateHint,
    required TextEditingController description,
    required TextEditingController fatalities,
    required TextEditingController injuries,
    required RxString vehicleType,
  }) {
    final hasNone = hasNoFlag.value;
    return RegisterSection(
      title: title,
      icon: icon,
      children: [
        YesNoField(
          question: question,
          value: !hasNone,
          onChanged: (yes) => hasNoFlag.value = !yes,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: hasNone
              ? AppText(
                  key: ValueKey('${keyPrefix}_note'),
                  text: note,
                  size: 13,
                  color: context.secondaryTextColor,
                  maxLines: 4,
                )
              : Column(
                  key: ValueKey('${keyPrefix}_form'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RegisterDateField(
                      controller: date,
                      label: dateLabel,
                      hint: dateHint,
                      validatorMsg: 'Date is required',
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                    ),
                    SizedBox(height: 16.h),
                    RegisterField(
                      controller: description,
                      label: 'Description',
                      hint: 'Description',
                      icon: Icons.description_outlined,
                      validatorMsg: 'Description is Required',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    RegisterField(
                      controller: fatalities,
                      label: 'Fatalities',
                      hint: 'Fatalities',
                      icon: Icons.warning_amber_rounded,
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Fatalities is Required',
                    ),
                    SizedBox(height: 16.h),
                    RegisterField(
                      controller: injuries,
                      label: 'Injuries',
                      hint: 'Injuries',
                      icon: Icons.personal_injury_outlined,
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Injuries is Required',
                    ),
                    SizedBox(height: 16.h),
                    SelectableChipGroup(
                      label: 'Vehicle Type',
                      options: const ['Personal', 'Commercial'],
                      value: vehicleType.value,
                      onChanged: (val) => vehicleType.value = val,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
