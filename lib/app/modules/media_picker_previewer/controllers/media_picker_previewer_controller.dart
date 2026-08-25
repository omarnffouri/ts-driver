import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/compressed_images_manager.dart';

import '../bindings/media_picker_previewer_params.dart';
import '../views/components/image_editor_bottom_sheet.dart';

class MediaPickerPreviewerController extends GetxController {
  late MediaPickerPreviewerParams params;

  final compressedImagesManager = Get.find<CompressedImagesManager>();

  final pageController = PageController();

  final RxList<MediaPickerFile> mediaFiles = RxList();

  var currentIndex = (-1).obs;

  final RxBool _canCompress = false.obs;
  bool get canCompress => _canCompress.value;

  final RxBool shouldCompress = true.obs;

  final RxBool isCompressing = false.obs;

  @override
  void onInit() {
    try {
      final args = Get.arguments;
      if (args is MediaPickerPreviewerParams) {
        // setting args
        params = args;

        // mapping to required data (MediaPickerFile)
        mediaFiles.addAll(
          params.files.map(
            (file) {
              // checking is image or video
              final type = compressedImagesManager
                      .isImageFile(lookupMimeType(file.path) ?? "")
                  ? MediaType.image
                  : MediaType.video;

              return MediaPickerFile(
                orignalFile: file,
                type: type,
              );
            },
          ),
        );

        if (mediaFiles.isNotEmpty) {
          currentIndex.value = 0;
        }

        //
        // function that will check if any can be compress
        if (params.enableCompression) {
          _checkForCompression();
        }
      } else {
        initDefaultParams();
      }
    } catch (_) {
      initDefaultParams();
    }

    mediaFiles.listen((value) async {
      if (value.isEmpty) {
        Get.back(result: await getResults(cancel: true));
      }
    });

    super.onInit();
  }

  //
  //
  /// function to initalize the deafult params
  initDefaultParams() {
    params = MediaPickerPreviewerParams(
      files: [],
      enableEditing: false,
      enableCompression: false,
    );
  }

  // Method to change the current index
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  //
  //
  /// function to show image editor
  showImageEditor() async {
    if (currentIndex.value < 0) {
      return;
    }

    //
    //
    // showing bottom sheet
    await showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: Get.height * 0.95),
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return ImageEditorBottomSheet(
          mediaPickerFile: mediaFiles.elementAt(currentIndex.value),
        );
      },
      backgroundColor: Colors.transparent,
    );
  }

  //
  //
  /// function to check that can any image is avaiable for compression
  _checkForCompression() async {
    try {
      _canCompress.value = false;
      for (var file in mediaFiles) {
        if (file.type == MediaType.image) {
          final compressable =
              await compressedImagesManager.needsCompression(file.orignalFile);
          if (compressable) {
            _canCompress.value = true;
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<List<File>> getResults({bool cancel = false}) async {
    if (cancel) {
      return [];
    }

    isCompressing.value = true;

    const maxSize = 2 * 1024 * 1024;

    List<File> files = [];

    try {
      for (var file in mediaFiles) {
        //
        // if media is image then compress if needed and add in files list
        // else add it as it is
        if (file.type == MediaType.image) {
          //
          // checking if compress enabled then compress image and add
          if (shouldCompress.value && params.enableCompression) {
            final compressedFile = await compressedImagesManager.compressImage(
              file.orignalFile,
              fileBytes: file.editedFile.value,
            );
            files.add(compressedFile);
          }

          //
          // else add image file as it is
          else {
            File? encodedFile;

            if (file.editedFile.value != null) {
              if (file.editedFile.value!.lengthInBytes > maxSize) {
                encodedFile = await compressedImagesManager.compressImage(
                  file.orignalFile,
                  fileBytes: file.editedFile.value,
                );
              } else {
                encodedFile = await compressedImagesManager.encodeFile(
                  file.editedFile.value,
                  file.orignalFile.path,
                );
              }
            }

            files.add(encodedFile ?? file.orignalFile);
          }
        }

        // adding other media files
        else {
          files.add(file.orignalFile);
        }
      }
    } catch (_) {}

    isCompressing.value = false;

    return files.isNotEmpty
        ? files
        : mediaFiles.map((file) => file.orignalFile).toList();
  }
}

class MediaPickerFile {
  final File orignalFile;
  final MediaType type;

  //
  // image editing data variables
  final Rxn<Uint8List> editedFile = Rxn();
  Map<String, dynamic>? editHistory;

  MediaPickerFile({
    required this.orignalFile,
    required this.type,
  });
}

enum MediaType {
  image,
  video,
}
