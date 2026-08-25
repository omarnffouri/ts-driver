import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../theme/theme_extensions.dart';
import '../../../domain/entities/document_entity.dart';
import '../../controllers/documents_controller.dart';
import 'attached_file_tile.dart';
import 'document_dropzone.dart';
import 'expiry_field.dart';

class DocumentRequestCard extends StatelessWidget {
  const DocumentRequestCard(
      {super.key, required this.index, required this.doc});

  final int index;
  final DocumentEntity doc;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    final title = doc.fileName?.isNotEmpty == true
        ? doc.fileName!
        : (doc.message?.isNotEmpty == true ? doc.message! : 'Requested file');

    return Obx(() {
      final ready = controller.isReady(index);
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: ready
                ? context.successTextColor.withValues(alpha: 0.45)
                : context.dividerColor,
          ),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusDot(ready: ready),
                addHorizontalSpace(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            text: ready ? 'READY' : 'PENDING',
                            size: 10,
                            weight: FontWeight.w700,
                            color: ready
                                ? context.successTextColor
                                : context.hintColor,
                          ),
                          const Spacer(),
                          if (doc.createdAt?.isNotEmpty == true)
                            AppText(
                              text: 'Requested ${doc.createdAt}',
                              size: 11,
                              color: context.hintColor,
                            ),
                        ],
                      ),
                      addVerticalSpace(4.h),
                      AppText(
                        text: title,
                        size: 15,
                        weight: FontWeight.w700,
                        maxLines: 1,
                        color: context.strongTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            addVerticalSpace(14.h),
            if (ready)
              AttachedFileTile(
                file: controller.uploadDocs[index].file!,
                name: controller.attachedFileName(index) ?? 'Attached file',
                size: controller.attachedFileSize(index) ?? '',
                isImage: controller.isImageAttachment(index),
                extension: controller.uploadDocs[index].extension,
                onRemove: () => controller.removeFile(index),
              )
            else
              DocumentDropzone(
                onTap: () => controller.chooseFile(doc.id!, title: title),
                hint: 'PDF, image or document',
              ),
            if (ready && controller.hasExpiration(index)) ...[
              addVerticalSpace(10.h),
              ExpiryField(index: index),
            ],
          ],
        ),
      );
    });
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: ready
          ? Container(
              key: const ValueKey<bool>(true),
              width: 26.w,
              height: 26.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.successTextColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 16.w, color: Colors.white),
            )
          : Container(
              key: const ValueKey<bool>(false),
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.hintColor, width: 2),
              ),
            ),
    );
  }
}
