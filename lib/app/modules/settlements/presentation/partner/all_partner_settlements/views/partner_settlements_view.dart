import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/controllers/auth_controller.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/routes/app_pages.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

import '../controllers/partner_settlements_controller.dart';
import 'components/settelment_card.dart';

class PartnerSettlementsView extends GetView<PartnerSettlementsController> {
  const PartnerSettlementsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // top header
                header(),

                // body
                Expanded(
                  child: Obx(
                    () => SmartRefresher(
                        controller: controller.refreshController,
                        header: const WaterDropMaterialHeader(),
                        onRefresh: () async {
                          await controller.applyDateFilter();
                          controller.refreshController.refreshCompleted();
                        },
                        child: controller.isLoadingSettlements
                            ? Center(
                                child: SizedBox(
                                  height: 200.h,
                                  child: Lottie.asset(Assets.json.pageLoader),
                                ),
                              )
                            : controller.isLoadingSettlementsFailed
                                ? _buildErrorView()
                                : controller.partnerSettlements.isEmpty
                                    ? _buildEmptySettlementsView()
                                    : ListView.builder(
                                        itemCount: controller.settlementsData
                                            .value!.months.length,
                                        itemBuilder: (context, index) {
                                          final month = controller
                                              .settlementsData
                                              .value!
                                              .months[index];

                                          final monthSettlements = controller
                                              .flattenListOfSettlemetsOfMonth(
                                                  month);

                                          return SettelmentCard(
                                            index: index,
                                            month: month,
                                            monthSettlements: monthSettlements,
                                          );
                                        },
                                      )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // top header
  Widget header() {
    return AppRedHeader(
      radius: 0,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Settelments",
                        style: Get.theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kWhiteColor,
                        ),
                        child: Text(
                          controller.authController.user.value.personalDetails
                                  ?.name ??
                              "",
                          style: Get.theme.textTheme.bodySmall
                              ?.copyWith(color: kMainColor),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            controller.yearMonthWeekDropdownClicked(),
                        icon: const Icon(
                          Icons.date_range,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Get.toNamed(Routes.PARTNER_DRIVERS_SETTELEMNTS),
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.find<AuthController>().logout(),
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  )
                ],
              ).marginOnly(left: 14),
            ),
            InkWell(
              onTap: () {
                controller.yearMonthWeekDropdownClicked();
              },
              child: Row(
                children: [
                  // year button
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Year",
                              style: Get.theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Obx(
                          () => Text(
                            controller.yearsList[controller.selectedYear.value]
                                .toString(),
                            style: Get.theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: Colors.white,
                      thickness: 1,
                      width: 20,
                    ),
                  ),

                  // month button
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Month",
                              style: Get.theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Obx(
                          () => Text(
                            controller
                                .monthsList[controller.selectedMonth.value],
                            style: Get.theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: Colors.white,
                      thickness: 1,
                      width: 20,
                    ),
                  ),

                  // week button
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Week",
                              style: Get.theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Obx(
                          () => Text(
                            controller.weeksList[controller.selectedWeek.value],
                            style: Get.theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ).marginSymmetric(horizontal: 14, vertical: 20),
            ),
          ],
        ),
      ),
    );
  }

  // error view
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Unable to load settlements. Please try again.")
              .paddingAll(10),
          GestureDetector(
            onTap: () {
              controller.applyDateFilter();
            },
            child: const Text(
              "Retry",
              style: TextStyle(color: kMainColor, fontSize: 16),
            ).paddingOnly(top: 10),
          )
        ],
      ),
    );
  }

  // empty settlements view
  Widget _buildEmptySettlementsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(Assets.json.noDataAnimation),
          const Text(
            "Pull to refresh",
            style: TextStyle(
              color: kMainColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

class EmptySettlements extends StatelessWidget {
  const EmptySettlements({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppText(color: kMainColor, text: "No Settlements Found.")
            .paddingAll(10),
      ],
    );
  }
}
