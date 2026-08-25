import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/annoucments/presentation/controllers/annoucments_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/controllers/home_controller.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/announcement_card.dart';
import 'package:ts_driver/app/modules/home/presentation/views/widgets/announcements_loading_view.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

class AnnouncementsTab extends GetView<HomeController> {
  const AnnouncementsTab({super.key});

  AnnoucmentsController get _ann => controller.annoucmentsController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        if (_ann.isLoadingAnnoucements) {
          return const AnnouncementsLoadingView();
        }

        final items = _ann.annoucements;
        if (items.isEmpty) return const _EmptyAnnouncements();

        return Column(
          children: [
            ExpandablePageView.builder(
              controller: _ann.annoucementsPageController,
              itemCount: items.length,
              itemBuilder: (_, index) =>
                  AnnouncementCard(announcement: items[index], index: index),
            ),
            SmoothPageIndicator(
              controller: _ann.annoucementsPageController,
              count: items.length,
              effect: const SwapEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                type: SwapType.yRotation,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EmptyAnnouncements extends StatelessWidget {
  const _EmptyAnnouncements();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.20,
      child: const Center(
        child: AppText(
          text: "No Announcements Yet.",
          size: 18,
          weight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
