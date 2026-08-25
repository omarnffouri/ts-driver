import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/views/tabs/announcements_tab.dart';
import 'package:ts_driver/app/modules/home/presentation/views/tabs/application_tab.dart';
import 'package:ts_driver/app/modules/home/presentation/views/tabs/document_tab.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/home_tab_bar.dart';

class HomeTabsCard extends StatelessWidget {
  const HomeTabsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: const Column(
        children: [
          HomeTabBar(),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: _TabBody(),
          ),
        ],
      ),
    );
  }
}

class _TabBody extends GetView<HomeController> {
  const _TabBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentSelection.value != 0) {
        return const DocumentTab();
      }
      return controller.isHired
          ? const AnnouncementsTab()
          : const ApplicationTab();
    });
  }
}
