import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/modules/settlements/presentation/widgets/settlement_loading_view.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_screen.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/core/widgets/no_data.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

import '../controllers/partner_settlement_details_controller.dart';
import 'components/deductions_info_widget.dart';
import 'components/reimbursements_info_widget.dart';
import 'components/settlement_info_widget.dart';
import 'components/shipments_info_widget.dart';

class PartnerSettlementDetailsView
    extends GetView<PartnerSettlementDetailsController> {
  const PartnerSettlementDetailsView({Key? key}) : super(key: key);
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

class _AppBar extends GetView<PartnerSettlementDetailsController> {
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
          const SizedBox(width: 10),
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

class SettlementDetailsCard
    extends GetView<PartnerSettlementDetailsController> {
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

            if (controller.isInfoAvailable)
              //  builde info for each driver
              ListView.separated(
                itemCount: settlemetDetails.info!.length,
                shrinkWrap: true,
                primary: false,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 20);
                },
                itemBuilder: (context, index) {
                  final info = settlemetDetails.info?[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(5),
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
                              Text(
                                '${info?.driverName}',
                                style:
                                    Get.theme.textTheme.titleMedium?.copyWith(
                                  color: AppColorsLight.mainColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${info?.driverTotal?.decimalPattern()}',
                                style:
                                    Get.theme.textTheme.titleMedium?.copyWith(
                                  color: AppColorsLight.mainColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // shipments info
                        ShipmentsInfoWidget(infoIndex: index),

                        // Reimbursements info
                        ReimbursementsInfoWidget(
                          title: 'Reimbursements',
                          reimbursementsData: info?.reimbursements,
                          total: info?.reimbursementTotal ?? '0',
                          infoIndex: index,
                        ),

                        // Deductions info
                        DeductionsInfoWidget(
                          title: 'Deductions',
                          dudectionData: info?.deductions,
                          total: info?.deductionTotal ?? '0',
                          infoIndex: index,
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 10),

            // truck deductions and reimbursements
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
