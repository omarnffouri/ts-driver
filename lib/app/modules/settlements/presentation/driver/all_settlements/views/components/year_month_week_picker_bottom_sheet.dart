import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/utils/vertical_scroll_menu.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';

class YearMonthWeekPickerBottomSheet extends GetView<SettlementsController> {
  const YearMonthWeekPickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // top header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 50,
          decoration: const BoxDecoration(
            color: kMainColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              "Select year, month, week",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.close_rounded,
                size: 25,
                color: Colors.white,
              ),
            )
          ]),
        ),
        GestureDetector(
          onTap: () {
            Get.back();
            controller.resetDate();
            controller.applyDateFilter();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            child: Text(
              "Clear Date",
              style: TextStyle(
                color: AppColorsLight.mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: VerticalScrollMenu(
                    highlighterBorder: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                      bottom: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                    ),
                    itemExtent: 40,
                    highlighterBorderWidth: 30,
                    magnification: 1.3,
                    onSelectedItemChanged: (value) {
                      controller.currentYear.value = value;
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: controller.selectedYear.value),
                    scrollPhysics: const FixedExtentScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      for (var i in controller.yearsList)
                        Center(
                          child: Text(
                            i.toString(),
                            style: TextStyle(
                                color: context.primaryTextColor, fontSize: 14),
                          ),
                        )
                    ]),
              ),

              // month picker
              Expanded(
                child: VerticalScrollMenu(
                    highlighterBorder: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                      bottom: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                    ),
                    itemExtent: 40,
                    highlighterBorderWidth: 30,
                    magnification: 1.3,
                    onSelectedItemChanged: (value) {
                      controller.currentMonth.value = value;
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: controller.selectedMonth.value),
                    scrollPhysics: const FixedExtentScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      for (var i in controller.monthsList)
                        Center(
                          child: Text(
                            i.toString(),
                            style: TextStyle(
                                color: context.primaryTextColor, fontSize: 14),
                          ),
                        )
                    ]),
              ),

              // week picker
              Expanded(
                child: VerticalScrollMenu(
                    highlighterBorder: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                      bottom: BorderSide(
                        width: 1.0,
                        color: context.dividerColor,
                      ),
                    ),
                    itemExtent: 40,
                    highlighterBorderWidth: 30,
                    magnification: 1.3,
                    onSelectedItemChanged: (value) {
                      controller.currentWeek.value = value;
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: controller.selectedWeek.value),
                    scrollPhysics: const FixedExtentScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      for (var i in controller.weeksList)
                        Center(
                          child: Text(
                            i.toString(),
                            style: TextStyle(
                                color: context.primaryTextColor, fontSize: 14),
                          ),
                        )
                    ]),
              ),
            ],
          ),
        ),

        InkWell(
          onTap: () {
            Get.back();
            controller.applyDateFilter();
          },
          child: Container(
            margin:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 15),
            width: double.infinity,
            height: 45,
            decoration: BoxDecoration(
              color: kMainColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child: Text(
              "Apply",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            )),
          ),
        )
      ],
    );
  }
}
