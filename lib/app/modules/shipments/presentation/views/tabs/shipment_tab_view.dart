import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/enum/trip_type.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

import '../../../domain/entities/shipment_entity.dart';
import '../widgets/loading_view.dart';
import '../widgets/trips_section.dart';
import '../../controllers/shipments_controller.dart';

class ShipmentSection {
  final String title;
  final List<ShipmentEntity> Function(ShipmentsController) getShipments;
  final TripType tripType;

  const ShipmentSection({
    required this.title,
    required this.getShipments,
    required this.tripType,
  });
}

class ShipmentTabView extends GetView<ShipmentsController> {
  final ScrollController scrollController;
  final RefreshController refreshController;
  final Future<void> Function() onRefresh;
  final bool Function(ShipmentsController) isLoading;
  final bool Function(ShipmentsController) isPaginating;
  final bool Function(ShipmentsController) isEmptyCheck;
  final String loadingTitle;
  final String emptyMessage;
  final List<ShipmentSection> sections;
  final ScrollPhysics? physics;

  const ShipmentTabView({
    super.key,
    required this.scrollController,
    required this.refreshController,
    required this.onRefresh,
    required this.isLoading,
    required this.isPaginating,
    required this.isEmptyCheck,
    required this.loadingTitle,
    required this.emptyMessage,
    required this.sections,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = isLoading(controller);
      return IgnorePointer(
        ignoring: loading,
        child: SmartRefresher(
          physics: physics,
          controller: refreshController,
          header: const WaterDropMaterialHeader(),
          onRefresh: () async {
            await onRefresh();
            refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  child: loading
                      ? LoadingView(title: loadingTitle)
                      : isEmptyCheck(controller)
                          ? SizedBox(
                              height: Get.height * .7,
                              child: Center(
                                child: AppText(
                                  text: emptyMessage,
                                  color: context.hintColor,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              if (!loading)
                ...sections.map((section) {
                  final shipments = section.getShipments(controller);
                  if (shipments.isEmpty) return const SliverToBoxAdapter();

                  return SliverToBoxAdapter(
                    child: TripsSection(
                      title: section.title,
                      shipments: shipments,
                      tripType: section.tripType,
                    ),
                  );
                }),
              if (isPaginating(controller))
                SliverToBoxAdapter(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ).marginOnly(top: 10),
                ),
              SliverToBoxAdapter(child: addVerticalSpace(60)),
            ],
          ),
        ),
      );
    });
  }
}

/// A paginated shipment tab (Completed / Rejected) backed by a [PagedShipments]
/// holder. Collapses the otherwise-identical per-tab wiring into one place.
class PagedShipmentTab extends GetView<ShipmentsController> {
  final PagedShipments tab;
  final String action;
  final TripType tripType;
  final String title;
  final String emptyMessage;

  const PagedShipmentTab({
    super.key,
    required this.tab,
    required this.action,
    required this.tripType,
    required this.title,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ShipmentTabView(
      scrollController: tab.scrollController,
      refreshController: tab.refreshController,
      onRefresh: () => controller.refreshPaged(tab, action),
      isLoading: (_) => tab.isLoading.value,
      isPaginating: (_) => tab.isPaginating.value,
      isEmptyCheck: (_) => tab.items.isEmpty,
      loadingTitle: title,
      emptyMessage: emptyMessage,
      sections: [
        ShipmentSection(
          title: title,
          getShipments: (_) => tab.items,
          tripType: tripType,
        ),
      ],
    );
  }
}
