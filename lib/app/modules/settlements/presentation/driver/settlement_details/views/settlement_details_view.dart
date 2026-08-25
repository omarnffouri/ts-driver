import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_loading_view.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/core/widgets/no_data.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

import '../controllers/settlement_details_controller.dart';
import 'components/deductions_info_widget.dart';
import 'components/reimbursements_info_widget.dart';
import 'components/settlement_info_widget.dart';
import 'components/shipments_info_widget.dart';
// import 'components/summary_charts.dart';

class SettlementDetailsView extends GetView<SettlementDetailsController> {
  const SettlementDetailsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreen(
        radius: 0,
        child: Container(
          color: context.backgroundColor,
          child: Column(
            children: [
              // header
              const _AppBar(),
              const SizedBox(height: 10),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.r),
                    bottomRight: Radius.circular(25.r),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const SettlementLoadingView()
                      : SmartRefresher(
                          controller: controller.detailsRefreshController,
                          header: const WaterDropMaterialHeader(),
                          onRefresh: controller.handleShipmentRefresh,
                          child: controller.settlemetDetails.value.total == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const NoDataView(),
                                    AppText(
                                      text: "Pull down to refresh",
                                      size: 16,
                                      color: context.hintColor,
                                    ),
                                  ],
                                )
                              : const SettlementDetailsCard(),
                        )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends GetView<SettlementDetailsController> {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: context.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const AppBackButton(),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  text: "Settlement Details",
                  weight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 2,
                ),
                AppText(
                  text:
                      "${controller.user.personalDetails?.name!.toString().capitalizeFirst!}",
                  size: 14,
                  color: Colors.white,
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.download_for_offline_rounded,
              color: Colors.white,
            ),
            iconSize: 40,
            onPressed: () {
              Get.to(
                FileViewer(
                  title: '${controller.settlementDataEntity.settlementNumber}',
                  path: '${controller.settlementDataEntity.path}',
                  folderName: "settelment_docs",
                  fileLoaded: () {},
                ),
              );
            },
          ),
        ],
      ).paddingOnly(top: 10, left: 10, right: 0, bottom: 6),
    );
  }
}

class SettlementDetailsCard extends GetView<SettlementDetailsController> {
  const SettlementDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settlemetDetails = controller.settlemetDetails.value;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      color: context.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // settlement general info
            const SettlementInfoWidget(),
            const SizedBox(height: 10),

            // shipments info
            const ShipmentsInfoWidget(),

            // Reimbursements info
            ReimbursementsInfoWidget(
              title: "Reimbursements",
              total: settlemetDetails.reimbursementTotal.toString(),
              reimbursementsData: settlemetDetails.reimbursements,
              infoIndex: -1,
            ),

            // Deductions info
            DeductionsInfoWidget(
              title: "Deductions",
              total: settlemetDetails.deductionTotal ?? "0",
              dudectionData: settlemetDetails.deductions,
              infoIndex: -1,
            ),

            // truck info
            if (controller.isTruckInfoAvailable)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.orange.shade300),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 5,
                      ),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: context.tileColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            Assets.svg.shipments,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColorsLight.disabledColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'Truck Charges',
                            style: Get.theme.textTheme.titleMedium?.copyWith(
                              color: AppColorsLight.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // truck reimbursements
                    ReimbursementsInfoWidget(
                      title: 'Truck Reimbursements',
                      reimbursementsData: settlemetDetails.truckReimbursements,
                      total: settlemetDetails.truckReimbursementTotal ?? '0',
                      infoIndex: null,
                    ),

                    // truck deductions
                    DeductionsInfoWidget(
                      title: 'Truck Deductions',
                      dudectionData: settlemetDetails.truckDeductions,
                      total: settlemetDetails.truckDeductionTotal ?? '0',
                      infoIndex: null,
                    ),
                  ],
                ),
              ),

            // todo : implement this from backend
            // // summary charts
            // const SizedBox(height: 10),
            // const RevenueChart(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
