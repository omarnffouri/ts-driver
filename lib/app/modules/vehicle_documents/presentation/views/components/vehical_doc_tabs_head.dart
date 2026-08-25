import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/core/widgets/app_back_button.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/glass_segmented_tabs.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';

import '../../controllers/vehicle_documents_controller.dart';
import 'vehicle_doc_header_search.dart';

class VehicleDocTabsHead extends GetView<VehicleDocumentsController> {
  const VehicleDocTabsHead({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      width: double.infinity,
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppBackButton().marginOnly(left: 14),
              AppText(
                text: "Vehicle Docs",
                size: 20,
                weight: FontWeight.bold,
                color: context.onHeaderTextColor,
              ).marginOnly(left: 14),
            ],
          ).marginOnly(top: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                Obx(
                  () => GlassSegmentedTabs<VehicalDocsTabs>(
                    value: controller.currentTab.value,
                    segments: const {
                      VehicalDocsTabs.truck: 'Truck',
                      VehicalDocsTabs.trailer: 'Trailer',
                    },
                    badgeBuilder: (tab, selected) =>
                        tab == VehicalDocsTabs.truck
                            ? _TruckNumberBadge(selected: selected)
                            : const SizedBox.shrink(),
                    onChanged: (tab) => controller.currentTab.value = tab,
                  ),
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  final isTruck =
                      controller.currentTab.value == VehicalDocsTabs.truck;
                  return VehicleDocHeaderSearch(
                    controller: isTruck
                        ? controller.truckSearchController
                        : controller.trailerSearchController,
                    hint: isTruck ? 'Search documents' : 'Enter trailer number',
                    keyboardType: isTruck ? null : TextInputType.number,
                    onChanged: isTruck
                        ? controller.truckSearch
                        : controller.trailerSearchChanged,
                    onClear: isTruck
                        ? controller.clearTruckSearch
                        : controller.clearTrailerSearch,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TruckNumberBadge extends StatelessWidget {
  const _TruckNumberBadge({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final truck = Get.find<HomeController>().applicantState.truck;
      if (truck == null || truck == 'null') return const SizedBox.shrink();
      return SegmentedTabBadge(label: truck, selected: selected);
    });
  }
}
