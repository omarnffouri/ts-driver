import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/widget_utils.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_red_header.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/file_viewer.dart';
import '../../../../theme/theme_extensions.dart';
import '../../domain/entities/trailer_entity.dart';
import '../controllers/vehicle_documents_controller.dart';
import 'components/vehicle_doc_card.dart';
import 'components/vehicle_docs_empty.dart';

class TrailerMediaView extends GetView<VehicleDocumentsController> {
  const TrailerMediaView({super.key, required this.trailer});

  final TrailerEntity trailer;

  void _open(MediaEntity media) {
    if (controller.isConnected.value == false) {
      controller.openFile(media.path!);
      return;
    }
    Get.to(
      () => FileViewer(
        title: '${media.name}',
        path: '${media.path}',
        folderName: "trailer_docs",
        fileLoaded: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = trailer.media ?? const <MediaEntity>[];
    return AppScreen(
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            AppRedHeader(
              child: Row(
                children: [
                  const AppBackButton(),
                  addHorizontalSpace(10),
                  Expanded(
                    child: AppText(
                      text: 'Trailer ${trailer.identifier}',
                      weight: FontWeight.bold,
                      maxLines: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ).paddingOnly(top: 10, left: 10, right: 10, bottom: 12),
            ),
            Expanded(
              child: media.isEmpty
                  ? const VehicleDocsEmpty(
                      icon: Icons.folder_open_outlined,
                      title: 'No documents',
                      subtitle: 'This trailer has no documents yet.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      itemCount: media.length,
                      separatorBuilder: (_, __) => addVerticalSpace(12.h),
                      itemBuilder: (context, index) {
                        final item = media[index];
                        return VehicleDocCard(
                          title: item.name ?? 'Document',
                          iconSource: item.path,
                          onTap: () => _open(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
