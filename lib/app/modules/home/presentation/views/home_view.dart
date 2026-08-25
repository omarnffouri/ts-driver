import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ts_driver/app/core/widgets/app_loading_wrapper_widget.dart';
import 'package:ts_driver/app/core/widgets/app_red_header.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/dashboard_card.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/home_tabs_card.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/pending_forms_card.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/user_info_header.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Built once so the Obx below only toggles IgnorePointer, not this subtree.
    final content = Stack(
      children: [
        const AppRedHeader(height: 200),
        Column(
          children: [
            const SizedBox(height: 15),
            const UserInfoHeader(),
            const DashboardCard(),
            Obx(
              () => LoadingWrapperWidget(
                isLoading: controller.isLoading,
                child: const PendingFormsCard(),
              ),
            ),
            const HomeTabsCard(),
            const SizedBox(height: 70),
          ],
        ),
      ],
    );

    final refresher = SmartRefresher(
      physics: const ClampingScrollPhysics(),
      controller: controller.refreshController,
      header: const WaterDropMaterialHeader(),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(child: content),
    );

    return SafeArea(
      child: Scaffold(
        // Block scroll + taps while loading (wraps the refresher so it catches
        // the scroll gesture itself).
        body: Obx(
          () => IgnorePointer(
            ignoring: controller.isInitializing,
            child: refresher,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await controller.reload();
    controller.refreshController.refreshCompleted();
  }
}
