import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/modules/vehicle_documents/domain/entities/truck_entity.dart';
import 'package:ts_driver/app/modules/vehicle_documents/presentation/controllers/vehicle_documents_controller.dart';

import '../components/vehicle_doc_card.dart';
import '../components/vehicle_docs_empty.dart';
import '../components/vehicle_docs_skeleton.dart';

class TruckDocumentsTab extends GetView<VehicleDocumentsController> {
  const TruckDocumentsTab({super.key});

  void _open(TruckEntity document) {
    if (controller.isConnected.value == false) {
      controller.openFile(document.path!);
      return;
    }
    Get.to(
      () => FileViewer(
        title: '${document.name}',
        path: '${document.path}',
        folderName: "truck_docs",
        fileLoaded: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Obx(() => _body()),
    );
  }

  Widget _body() {
    if (controller.isTruckLoading) return const VehicleDocsSkeleton();

    final docs = controller.truckFiltered;
    return SmartRefresher(
      controller: controller.truckDocsRefreshController,
      header: const WaterDropMaterialHeader(),
      onRefresh: () async {
        await controller.getAllTruckDocuments();
        controller.truckDocsRefreshController.refreshCompleted();
      },
      child: docs.isEmpty
          ? const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: VehicleDocsEmpty(
                    icon: Icons.description_outlined,
                    title: 'No documents found',
                  ),
                ),
              ],
            )
          : _list(docs),
    );
  }

  Widget _list(List<TruckEntity> docs) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: docs.length,
      separatorBuilder: (_, __) => addVerticalSpace(12.h),
      itemBuilder: (context, index) {
        final document = docs[index];
        return VehicleDocCard(
          title: document.name ?? 'Document',
          iconSource: document.path,
          onTap: () => _open(document),
        );
      },
    );
  }
}
