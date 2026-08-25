import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/modules/forms/presintation/views/components/stepper_forms_widget.dart';

import '../../controllers/forms_controller.dart';

class FormAppbar extends GetView<FormsController> {
  const FormAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      child: Column(
        children: [
          //
          //
          // back buttonm, image, name
          Row(
            children: [
              const AppBackButton(),
              addHorizontalSpace(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      text: "Forms",
                      weight: FontWeight.bold,
                      color: Colors.white,
                      maxLines: 2,
                    ),
                    AppText(
                      text:
                          "${controller.user.personalDetails?.firstName!.toString().capitalizeFirst!}",
                      size: 14,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              ProfileImage.network(
                url: controller.user.profile,
                height: 40,
                width: 40,
              ),
            ],
          ).marginAll(10),

          //

          //
          // easy stepper header
          Obx(
            () => Visibility(
              visible: (!controller.isLoading),
              child: FormsStepperWidget(),
            ),
          ),
          const SizedBox(
            height: 8,
          ),

          //
          //
          // form title
          Obx(
            () => ((!controller.isLoading) && controller.forms.isNotEmpty)
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text(
                      controller.forms
                          .elementAt(controller.activeStep.value)
                          .formName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kMainColor,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
