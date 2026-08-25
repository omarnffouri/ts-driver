import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../../core/widgets/glass_segmented_tabs.dart';
import '../../../../core/widgets/profile_image.dart';
import '../controllers/shipments_controller.dart';

class ShipmentsView extends GetView<ShipmentsController> {
  const ShipmentsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
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
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: Obx(
                  () => IndexedStack(
                    index: controller.currentTab.value,
                    children: controller.tabs,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends GetView<ShipmentsController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Obx(
        () => Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileImage.network(
                  url: controller.user.profile,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        text: "Shipments",
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
              ],
            ),
            const SizedBox(height: 12),
            GlassSegmentedTabs<int>(
              value: controller.currentTab.value,
              disabled: controller.isLoading,
              segments: const {
                0: 'New Load',
                1: 'Completed',
                2: 'Rejected',
              },
              onChanged: (v) {
                // Defer the IndexedStack swap until the indicator pill has
                // slid across, so the content doesn't jump ahead of it.
                Future.delayed(const Duration(milliseconds: 200), () {
                  controller.currentTab.value = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
