import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../core/widgets/app_screen.dart';
import '../../../../theme/theme_extensions.dart';
import '../controllers/documents_controller.dart';
import 'components/document_request_card.dart';
import 'components/documents_app_bar.dart';
import 'components/documents_empty.dart';
import 'components/documents_progress_strip.dart';
import 'components/documents_skeleton.dart';
import 'components/documents_upload_bar.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            const DocumentsAppBar(),
            Expanded(child: Obx(() => _body(context))),
          ],
        ),
        bottomNavigationBar: Obx(
          () => controller.docs.isEmpty
              ? const SizedBox.shrink()
              : const DocumentsUploadBar(),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.isLoading) return const DocumentsSkeleton();

    // Keep AnimationLimiter above SmartRefresher or pull-to-refresh breaks.
    return AnimationLimiter(
      child: SmartRefresher(
        controller: controller.refreshController,
        header: const WaterDropMaterialHeader(),
        onRefresh: () async {
          await controller.getAllDocuments();
          controller.refreshController.refreshCompleted();
        },
        child: controller.docs.isEmpty ? _empty() : _list(context),
      ),
    );
  }

  Widget _empty() {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: DocumentsEmpty(),
        ),
      ],
    );
  }

  Widget _list(BuildContext context) {
    return ListView.builder(
      // Always scrollable so a short list can still be pulled to refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: controller.docs.length + 1,
      itemBuilder: (context, position) {
        if (position == 0) return const DocumentsProgressStrip();
        final index = position - 1;
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, index == 0 ? 6.h : 14.h, 20.w, 0),
          child: AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 24.h,
              child: FadeInAnimation(
                child: DocumentRequestCard(
                  index: index,
                  doc: controller.docs[index],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
