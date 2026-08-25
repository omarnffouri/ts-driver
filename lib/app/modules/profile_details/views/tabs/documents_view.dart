import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_types.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:ts_driver/app/modules/auth/domain/entities/user_entity.dart';

import '../../controllers/profile_details_controller.dart';

final _fileHelper = FileExtensionHelper();

const _imageTypes = {FileTypes.png, FileTypes.jpg, FileTypes.jpeg};

bool _isImageType(FileTypes type) => _imageTypes.contains(type);

String _formatDocumentName(String? name) {
  if (name == null || name.isEmpty) return 'Untitled Document';
  final withoutExt = _fileHelper.removeFileNameExtension(name);
  return withoutExt
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

Color _badgeColor(FileTypes type) {
  if (_isImageType(type)) return const Color(0xFF4CAF50);
  if (type == FileTypes.pdf) return const Color(0xFFE53935);
  if (type == FileTypes.doc || type == FileTypes.docx) {
    return const Color(0xFF1E88E5);
  }
  if (type == FileTypes.xls ||
      type == FileTypes.xlsx ||
      type == FileTypes.csv) {
    return const Color(0xFF43A047);
  }
  return kHintColor;
}

IconData _typeIcon(FileTypes type) {
  if (_isImageType(type)) return Icons.image_outlined;
  if (type == FileTypes.pdf) return Icons.picture_as_pdf_outlined;
  if (type == FileTypes.doc || type == FileTypes.docx) {
    return Icons.description_outlined;
  }
  if (type == FileTypes.xls ||
      type == FileTypes.xlsx ||
      type == FileTypes.csv) {
    return Icons.table_chart_outlined;
  }
  return Icons.insert_drive_file_outlined;
}

// ─────────────────────────────────────────────────────────────
// Documents View
// ─────────────────────────────────────────────────────────────

class DocumentsView extends GetView<ProfileDetailsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = controller.user.personalDetails?.activeApplication;

    // TODO: Re-enable userFiles when media feature is ready
    // final userFiles =
    //     controller.user.personalDetails?.activeApplication?.userFiles ?? [];

    final userFiles = [
      UserFileEntity(name: 'Medical Card', url: app?.medicalCardFile),
      UserFileEntity(name: 'Driver License', url: app?.driverLicenseFile),
      UserFileEntity(
          name: 'Applicant Signature', url: app?.applicantSignatureFile),
    ];

    final availableDocs =
        userFiles.where((d) => d.url != null && d.url!.isNotEmpty).toList();

    if (availableDocs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64.r, color: kHintColor),
            SizedBox(height: 12.h),
            const AppText(
              text: 'No documents available',
              size: 15,
              weight: FontWeight.w500,
              color: kHintColor,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      itemCount: availableDocs.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final doc = availableDocs[index];
        return _DocumentCard(file: doc);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Document Card
// ─────────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.file});

  final UserFileEntity file;

  FileTypes get _fileType =>
      _fileHelper.getFileType(file.url ?? file.name ?? '');

  void _openFile() {
    final path = file.url ?? '';
    if (path.isEmpty) return;

    Get.to(
      () => FileViewer(
        title: _formatDocumentName(file.name),
        path: path,
        fileLoaded: () {},
        folderName: 'documents',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _fileType;
    final isImage = _isImageType(type);
    final displayName = _formatDocumentName(file.name);
    final ext = _fileHelper.getFileExtension(file.url ?? file.name ?? '');

    return GestureDetector(
      onTap: _openFile,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            _Thumbnail(url: file.url, type: type, isImage: isImage),

            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: displayName,
                      size: 14,
                      weight: FontWeight.w600,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _FileTypeBadge(ext: ext, type: type),
                        SizedBox(width: 8.w),
                        Icon(_typeIcon(type), size: 16.r, color: kHintColor),
                        SizedBox(width: 4.w),
                        const AppText(
                          text: 'Tap to view',
                          size: 11,
                          color: kHintColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: kHintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Thumbnail (left side — image preview or file icon)
// ─────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.url,
    required this.type,
    required this.isImage,
  });

  final String? url;
  final FileTypes type;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    if (isImage) {
      return CachedNetworkImage(
        imageUrl: url ?? '',
        width: 100.h,
        height: 100.h,
        fit: BoxFit.cover,
        memCacheHeight: 300,
        errorWidget: (_, __, ___) => Container(
          width: 100.h,
          height: 100.h,
          color: context.tileColor,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 36,
            color: kHintColor,
          ),
        ),
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: context.shimmerBaseColor,
          highlightColor: context.shimmerHighlightColor,
          child: Container(
            width: 100.h,
            height: 100.h,
            color: context.shimmerBaseColor,
          ),
        ),
      );
    }

    final iconPath = _fileHelper.getFileIcon(type);
    final color = _badgeColor(type);

    return Container(
      width: 100.h,
      height: 100.h,
      color: color.withValues(alpha: 0.08),
      child: Center(
        child: Image.asset(
          iconPath,
          width: 44.r,
          height: 44.r,
          errorBuilder: (_, __, ___) => Icon(
            Icons.insert_drive_file_outlined,
            size: 40.r,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// File Type Badge
// ─────────────────────────────────────────────────────────────

class _FileTypeBadge extends StatelessWidget {
  const _FileTypeBadge({required this.ext, required this.type});

  final String ext;
  final FileTypes type;

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor(type);
    final label = ext.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: kWhiteColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
