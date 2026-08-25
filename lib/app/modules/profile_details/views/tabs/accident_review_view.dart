// ignore_for_file: unnecessary_string_interpolations

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/profile_details/views/components/bubble_menu_widget.dart';
import 'package:ts_driver/app/modules/profile_details/views/components/personal_info_card.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/utils/widget_utils.dart';
import '../../controllers/profile_details_controller.dart';

class AccidentReviewView extends GetView<ProfileDetailsController> {
  const AccidentReviewView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionBubble(
        items: BubbleMenuItems.buildBubbles(controller),
        animation: controller.animation!,
        onPress: () => controller.animationController!.isCompleted
            ? controller.animationController!.reverse()
            : controller.animationController!.forward(),
        iconColor: kWhiteColor,
        iconData: Icons.add,
        backGroundColor: kMainColor,
      ),
      body: Obx(() {
        final app = controller.user.personalDetails?.activeApplication;
        final accidents = app?.accidentReviewPastYears ?? [];
        final trafficConvictions = app?.trafficConvictionPastYears ?? [];

        if (app == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 64.r, color: kHintColor),
                SizedBox(height: 12.h),
                const AppText(
                  text: 'No application data available',
                  size: 15,
                  weight: FontWeight.w500,
                  color: kHintColor,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Accident Review Section
              Container(
                margin: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: context.dividerColor),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 14),
                      child: Text(
                        '* Accident Review for Past 5 Years',
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: context.dividerColor,
                    ),
                    Column(
                      children: [
                        if (accidents.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                            child: Row(
                              children: [
                                addHorizontalSpace(20.w),
                                Expanded(
                                  child: CustomCheckbox(
                                      value: true,
                                      text: 'No Accidents to report'),
                                ),
                              ],
                            ),
                          ),
                        ListView.separated(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: accidents.length,
                          itemBuilder: (context, index) {
                            final accidentReview = accidents[index];
                            return Column(
                              spacing: 8,
                              children: [
                                infoWidget("Date", accidentReview.accidentDate),
                                infoWidget('Description',
                                    accidentReview.accidentDescription),
                                infoWidget('Fatalities',
                                    accidentReview.accidentFatalities),
                                infoWidget('Injuries',
                                    accidentReview.accidentInjuries),
                                infoWidget('Vehicle Type',
                                    accidentReview.accidentVehicleType),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            height: 24,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpace(20.h)
                  ],
                ),
              ),

              // Traffic Convictions Section
              Container(
                margin: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: context.dividerColor),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 14),
                      child: Text(
                        '* Traffic Convictions & Forfeitures for Past 5 Years',
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: context.dividerColor,
                    ),
                    if (trafficConvictions.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Row(
                          children: [
                            addHorizontalSpace(20.w),
                            Expanded(
                              child: CustomCheckbox(
                                value: true,
                                text:
                                    'No Traffic Convictions or Forfeitures to report',
                              ),
                            ),
                          ],
                        ),
                      ),
                    Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: trafficConvictions.length,
                          itemBuilder: (context, index) {
                            final traffic = trafficConvictions[index];
                            return Column(
                              spacing: 10,
                              children: [
                                if (traffic.trafficConvictionDate != null)
                                  infoWidget(
                                      'Date', traffic.trafficConvictionDate),
                                infoWidget('Description',
                                    traffic.trafficConvictionDescription),
                                infoWidget('Fatalities',
                                    traffic.trafficConvictionFatalities),
                                infoWidget('Injuries',
                                    traffic.trafficConvictionInjuries),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            height: 24,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpace(20.h)
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
