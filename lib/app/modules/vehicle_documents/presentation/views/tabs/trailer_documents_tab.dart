import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/entities/trailer_entity.dart';
import 'package:ts_driver/app/modules/vehicle_documents/presentation/controllers/vehicle_documents_controller.dart';

import '../components/vehicle_doc_card.dart';
import '../components/vehicle_docs_empty.dart';
import '../components/vehicle_docs_skeleton.dart';
import '../trailer_media_view.dart';

class TrailerDocumentsTab extends GetView<VehicleDocumentsController> {
  const TrailerDocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Obx(() => _body()),
    );
  }

  Widget _body() {
    if (controller.isTrailerLoading) return const VehicleDocsSkeleton();

    if (controller.showSearchOnly.value) {
      return const VehicleDocsEmpty(
        icon: Icons.local_shipping_outlined,
        title: 'Find trailer documents',
        subtitle: 'Enter a trailer number above to see its documents.',
      );
    }

    final trailers = controller.trailerFiltered;
    return SmartRefresher(
      controller: controller.trailerDocsRefreshController,
      header: const WaterDropMaterialHeader(),
      onRefresh: () async {
        await controller.getAllTrailerDocuments();
        controller.trailerDocsRefreshController.refreshCompleted();
      },
      child: trailers.isEmpty
          ? const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: VehicleDocsEmpty(
                    icon: Icons.search_off_rounded,
                    title: 'No trailer found',
                    subtitle: 'Check the number and try again.',
                  ),
                ),
              ],
            )
          : _list(trailers),
    );
  }

  Widget _list(List<TrailerEntity> trailers) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: trailers.length,
      separatorBuilder: (_, __) => addVerticalSpace(12.h),
      itemBuilder: (context, index) {
        final trailer = trailers[index];
        final docCount = trailer.media?.length ?? 0;
        return VehicleDocCard(
          title: 'Trailer ${trailer.identifier}',
          subtitle: docCount == 1 ? '1 document' : '$docCount documents',
          icon: Icons.local_shipping_rounded,
          onTap: () => Get.to(() => TrailerMediaView(trailer: trailer)),
        );
      },
    );
  }
}
