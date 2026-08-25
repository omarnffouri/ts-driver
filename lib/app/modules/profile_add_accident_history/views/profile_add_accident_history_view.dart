import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_botton.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/modules/profile_add_accident_history/views/components/history_card_widget.dart';
import 'package:ts_driver/app/modules/profile_add_accident_history/views/components/traffict_card_widget.dart';
import 'package:ts_driver/app/modules/profile_add_accident_history/views/components/traffict_header_widget.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/theme_extensions.dart';
import '../../../core/utils/widget_utils.dart';
import '../controllers/profile_add_accident_history_controller.dart';
import 'components/accident_card_widget.dart';
import 'components/accident_header_widget.dart';

class ProfileAddAccidentHistoryView
    extends GetView<ProfileAddAccidentHistoryController> {
  const ProfileAddAccidentHistoryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    log('ProfileAddAccidentHistoryView');
    return Obx(
      () => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: AppScreen(
            child: Column(
              children: [
                AppRedHeader(
                  child: Row(
                    children: [
                      const AppBackButton(),
                      addHorizontalSpace(10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text: 'Add ${controller.getTitle()}',
                              weight: FontWeight.bold,
                              color: Colors.white,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
                ),
                Expanded(
                  child: controller.isLoading
                      ? Container(
                          color: context.backgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: kMainColor,
                            ),
                          ),
                        )
                      : controller.type.value == "history"
                          ? employmentHistory(context)
                          : accidentReview(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container employmentHistory(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 16.w,
              ),
              child: Form(
                key: controller.employementFormKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    addVerticalSpace(10.h),
                    Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: AppText(
                            text:
                                'You must provide accurate dates of employment and phone numbers covering the last ten years (per DOT regulation). We cannot hire you without verifying employment.',
                            size: 14,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: kMainColor,
                              alignment: Alignment.center,
                            ),
                            child: const AppText(
                              text: 'Add',
                              size: 15,
                              color: kWhiteColor,
                              weight: FontWeight.bold,
                            ),
                            onPressed: () {
                              controller.addEmploymentHistoryFields();
                            },
                          ),
                        )
                      ],
                    ),
                    addVerticalSpace(10.h),
                    Obx(
                      () => Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: controller.employmentHistories.length,
                            itemBuilder: (context, builderIndex) {
                              return HistoryCard(
                                controller: controller,
                                builderIndex: builderIndex,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    addVerticalSpace(25.h),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.employmentHistories.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 20.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      bgColor: kMainColor,
                      text: 'Submit',
                      onPressed: () {
                        controller.submitEmploymentUpdates();
                      },
                    ),
                    addVerticalSpace(10.h)
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Container accidentReview(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: controller.accidentFormKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    if (controller.type.value == "accident")
                      AccidentHeader(controller: controller),
                    if (controller.type.value == "accident")
                      Obx(
                        () => Column(
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: controller.accidentReviews.length,
                              itemBuilder: (context, index) {
                                return AccidentCard(
                                  controller: controller,
                                  index: index,
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      addVerticalSpace(25.h),
                            ),
                          ],
                        ),
                      ),
                    if (controller.type.value == "traffict")
                      TraffictHeader(controller: controller),
                    if (controller.type.value == "traffict")
                      Obx(
                        () => Column(
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: controller.trafficConvictions.length,
                              itemBuilder: (context, index) {
                                return TraffictCard(
                                  controller: controller,
                                  index: index,
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      addVerticalSpace(25.h),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (controller.type.value == "accident" &&
                    controller.accidentReviews.isNotEmpty ||
                controller.type.value == "traffict" &&
                    controller.trafficConvictions.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      bgColor: kMainColor,
                      text: 'Submit',
                      onPressed: () {
                        controller.submitAccidentUpdates();
                      },
                    ),
                    addVerticalSpace(10.h)
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
