import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/controllers/settlements_controller.dart';
import 'package:ts_driver/app/modules/settlements/presentation/driver/all_settlements/views/components/settelment_card.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class SettlementsView extends GetView<SettlementsController> {
  const SettlementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // top header
              header(context),

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
                            : controller.settlementsData.value == null
                                ? _buildEmptySettlementsView()
                                : ListView.builder(
                                    itemCount: controller
                                        .settlementsData.value!.months.length,
                                    itemBuilder: (context, index) {
                                      final month = controller
                                          .settlementsData.value!.months[index];

                                      final monthSettlements = controller
                                          .flattenListOfSettlemetsOfMonth(
                                              month);

                                      return SettelmentCard(
                                        index: index,
                                        month: month,
                                        monthSettlements: monthSettlements,
                                      );
                                    },
                                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    final theme = Get.theme;
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          AppRedHeader(
            height: 175,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProfileImage.network(
                      url: controller.user.profile,
                      width: 65,
                      height: 65,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 14,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.authController.user.value.personalDetails
                                    ?.name ??
                                "",
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            "Settlements",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: IconButton(
                        icon: const Icon(Icons.date_range),
                        color: Colors.white,
                        onPressed: controller.yearMonthWeekDropdownClicked,
                      ),
                    ),
                  ],
                ),
                // name badge
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.dividerColor),
                boxShadow: context.cardShadow,
              ),
              child: InkWell(
                onTap: controller.yearMonthWeekDropdownClicked,
                child: Row(
                  children: [
                    // Year
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Year",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.secondaryTextColor,
                                fontSize: 15,
                              )),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                controller
                                    .yearsList[controller.selectedYear.value]
                                    .toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: context.primaryTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ],
                      ),
                    ),
                    _vDivider(context),
                    // Month
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Month",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.secondaryTextColor,
                                fontSize: 15,
                              )),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                controller
                                    .monthsList[controller.selectedMonth.value],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: context.primaryTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ],
                      ),
                    ),
                    _vDivider(context),
                    // Week
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Week",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.secondaryTextColor,
                                fontSize: 15,
                              )),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                controller
                                    .weeksList[controller.selectedWeek.value],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: context.primaryTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider(BuildContext context) => Container(
        width: 1,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: context.dividerColor,
      );

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
