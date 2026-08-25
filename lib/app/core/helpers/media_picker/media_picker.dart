import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/helpers/permission_helper.dart';
import 'package:ts_driver/app/core/utils/widget_utils.dart';
import 'package:ts_driver/app/modules/media_picker_previewer/bindings/media_picker_previewer_params.dart';
import 'package:ts_driver/app/routes/app_pages.dart';

class MediaPicker {
  static final instance = MediaPicker();

  static const defaultAllowedExtensions = [
    'DOCX',
    'DOC',
    'HTML',
    'ODT',
    'PDF',
    'XLS',
    'XLSX',
    'PPT',
    'PPTX',
    'ZIP',
    'TXT',
    'PSD',
    'AI',
    'docx',
    'doc',
    'html',
    'odt',
    'pdf',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'zip',
    'txt',
    'psd',
    'ai',
    'csv',
    'CSV',
  ];

  //
  //
  /// function to pick multiple images and videos
  static Future<List<File>> pickMultipleMedia({
    bool enablePreviewer = true,
    bool enableEditing = true,
    bool enableCompression = true,
  }) async {
    //
    // get selected file
    final files = await instance.selectMultipleImagesVideos();

    if (files.isEmpty || (!enablePreviewer)) {
      return files;
    }

    //
    // if preview is enabled the pass to previewer
    try {
      //
      // pass to previewer and getting result
      final result = await Get.toNamed(
        Routes.MEDIA_PICKER_PREVIEWER,
        arguments: MediaPickerPreviewerParams(
          files: files,
          enableEditing: enableEditing,
          enableCompression: enableCompression,
        ),
      );

      if (result is List<File>) {
        return result;
      }
    } catch (_) {}

    return files;
  }

  //
  /// function to select multiple image and videos base files
  Future<List<File>> selectMultipleImagesVideos() async {
    try {
      //
      // if platform ios then use ImagePicker package for media selection
      if (Platform.isIOS) {
        return (await ImagePicker().pickMultipleMedia())
            .map((file) => File(file.path))
            .toList();
      }

      //
      // if platform android then use FilePicker package for media selection
      if (Platform.isAndroid) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.media,
        );

        // if resturn is not null then map PlatformFile File
        if (result != null) {
          return result.files.map((file) => File(file.path!)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  //
  /// function to select multiple image and videos base files
  static Future<File?> selectSingleImage() async {
    try {
      //
      // if platform ios then use ImagePicker package for image selection
      if (Platform.isIOS) {
        final xFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        if (xFile != null) {
          return File(xFile.path);
        }
      }

      //
      // if platform android then use FilePicker package for image selection
      if (Platform.isAndroid) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.image,
        );

        // if resturn is not null then map PlatformFile File
        if (result != null) {
          if (result.files.isNotEmpty) {
            return File(result.files.first.path!);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  //
  //
  /// function to pick doc like pdf, xls, etc
  static Future<List<File>> pickDocuments(
      {List<String> allowedExtensions = defaultAllowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    }
    return [];
  }

  static Future<PlatformFile?> pickSingleFile(
      {List<String> allowedExtensions = defaultAllowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.single;
    }
    return null;
  }

  //
  //
  /// function to open camera capture image
  static Future<File?> openCameraAndCaptureImage({
    bool enablePreviewer = true,
    bool enableEditing = true,
    bool enableCompression = true,
  }) async {
    if (!(await PermissionHelper.haveCameraPermission(
        "Grant camera permission in settings to share photos in chat."))) {
      return null;
    }
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final file = File(image.path);

      if (!enablePreviewer) {
        return file;
      }

      //
      // if preview is enabled the pass to previewer
      try {
        //
        // pass to previewer and getting result
        final result = await Get.toNamed(
          Routes.MEDIA_PICKER_PREVIEWER,
          arguments: MediaPickerPreviewerParams(
            files: [file],
            enableEditing: enableEditing,
            enableCompression: enableCompression,
          ),
        );

        if (result is List<File>) {
          if (result.isNotEmpty) {
            return result.first;
          } else {
            return null;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  //
  //
  /// function to pick audio files
  static Future<List<File>> pickAudios() async {
    if (Platform.isIOS &&
        (!(await PermissionHelper.haveAppleMusicPermission(
            "Allow media library permission in settings to share any audio/music files.")))) {
      return [];
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    }
    return [];
  }

  //
  //
  /// function to show attahment picker options
  static void showAttachmentBottomSheet({
    void Function(List<File> files)? onDocumentPicked,
    void Function(File? file)? onCameraPicked,
    void Function(List<File>)? onGalleryPicked,
    void Function(List<File>)? onAudiosPicked,
    void Function()? onLocationPicked,
    bool enablePreviewer = true,
    bool enableEditing = true,
    bool enableCompression = true,
    List<String> allowedDocExtensions = defaultAllowedExtensions,
  }) {
    showAppBottomSheet(
      child: Builder(
        builder: (context) {
          const columns = 3;
          final hPad = 20.w;
          final gap = 12.w;
          final itemWidth =
              (Get.width - hPad * 2 - gap * (columns - 1)) / columns;

          final options = <Widget>[
            if (onDocumentPicked != null)
              _PickerButton(
                width: itemWidth,
                label: "Document",
                icon: Icons.insert_drive_file_rounded,
                iconBackgroundColor: Colors.blue,
                onClick: () async {
                  try {
                    Get.back();
                    final docs = await pickDocuments(
                        allowedExtensions: allowedDocExtensions);
                    onDocumentPicked(docs);
                  } catch (_) {}
                },
              ),
            if (onCameraPicked != null)
              _PickerButton(
                width: itemWidth,
                label: "Camera",
                icon: Icons.photo_camera_rounded,
                iconBackgroundColor: AppColors.primary,
                onClick: () async {
                  try {
                    Get.back();
                    final image = await openCameraAndCaptureImage(
                      enablePreviewer: enablePreviewer,
                      enableCompression: enableCompression,
                      enableEditing: enableEditing,
                    );
                    onCameraPicked(image);
                  } catch (_) {}
                },
              ),
            if (onGalleryPicked != null)
              _PickerButton(
                width: itemWidth,
                label: "Gallery",
                icon: Icons.image_rounded,
                iconBackgroundColor: Colors.purple,
                onClick: () async {
                  try {
                    Get.back();
                    final files = await pickMultipleMedia(
                      enablePreviewer: enablePreviewer,
                      enableCompression: enableCompression,
                      enableEditing: enableEditing,
                    );
                    onGalleryPicked(files);
                  } catch (_) {}
                },
              ),
            if (onAudiosPicked != null)
              _PickerButton(
                width: itemWidth,
                label: "Audio",
                icon: Icons.audiotrack_rounded,
                iconBackgroundColor: Colors.brown,
                onClick: () async {
                  try {
                    Get.back();
                    final audios = await pickAudios();
                    onAudiosPicked(audios);
                  } catch (_) {}
                },
              ),
            if (onLocationPicked != null)
              _PickerButton(
                width: itemWidth,
                label: "Location",
                icon: Icons.location_on_rounded,
                iconBackgroundColor: Colors.green,
                onClick: () async {
                  try {
                    Get.back();
                    onLocationPicked();
                  } catch (_) {}
                },
              ),
          ];

          return Padding(
            padding: EdgeInsets.fromLTRB(hPad, 4.h, hPad, 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share",
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: gap,
                  runSpacing: 20.h,
                  children: options,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final void Function() onClick;
  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final double width;
  const _PickerButton({
    required this.onClick,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackgroundColor,
                ),
                child: Icon(icon, color: Colors.white, size: 28.r),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
