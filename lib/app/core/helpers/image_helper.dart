import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ts_driver/app/core/utils/image_selection_cropper.dart';

class ImageHelper {
  //
  //
  /// function to pick image from camera, this will automatically convert ios
  /// heic or heif file to jpeg
  static Future<XFile?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    // check if image extinsion is heic or heif
    if (image != null) {
      final String ext = image.path.split('.').last;
      if (ext == 'heic' || ext == 'heif') {
        return convertHeicOrHeifToJpeg(image);
      }
    }
    return image;
  }

  //
  //
  /// function to convert heic or heif to jpeg
  static Future<XFile?> convertHeicOrHeifToJpeg(XFile heicOrHeifImage) async {
    final Uint8List imageBytes = await heicOrHeifImage.readAsBytes();

    // Check if the image format is HEIC or HEIF based on the file extension or other criteria.
    // Perform the conversion to JPEG using the flutter_image_compress package.
    final Uint8List jpegBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      format: CompressFormat.jpeg,
      quality: 70, // Adjust the quality as needed.
    );

    if (jpegBytes.isNotEmpty) {
      // Save the converted JPEG bytes to a temporary file and return its path.
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String tempFileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpeg';
      final File tempFile = File('$tempPath/$tempFileName');
      await tempFile.writeAsBytes(jpegBytes);
      return XFile(tempFile.path);
    }
    return null; // Return null if the conversion failed.
  }

  //
  //
  /// function to pick image from camera and will pass to selection crop
  /// and will return a cropped image
  static Future<Uint8List?> pickImageFromCameraSelectionCrop(
      String title, String noteDescription) async {
    //
    // pick image from camera
    final image = await pickImageFromCamera();

    if (image == null) {
      return null;
    }

    // making selection crop and returning a cropped image
    return await makeSelectionCropper(
      FileImage(File(image.path)),
      title: title,
      noteDescription: noteDescription,
    );
  }

  //
  //
  /// function will take image provider and shows crop bottom sheet
  /// and will return a cropped image if cropped was sucessful
  static Future<Uint8List?> makeSelectionCropper(ImageProvider image,
      {String title = "", String noteDescription = ""}) async {
    //
    Uint8List? croppedImage;

    // crop bottom sheet
    await showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: Get.height * .95),
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return ImageSelectionCropper(
          title: title,
          image: image,
          size: Size(Get.width, Get.height * 0.70),
          noteDescription: noteDescription,
          onSuccess: (Uint8List? image) {
            Get.back();
            croppedImage = image;
          },
        );
      },
      backgroundColor: Colors.transparent,
    );

    return croppedImage;
  }

  //
  //
  /// function will take image bytes return a jpeg file
  static Future<File?> compressBytesToJpeg(Uint8List bytes) async {
    try {
      //
      // if bytes not null them compress them in a file
      if (bytes.isNotEmpty) {
        // Save the  bytes to a temporary file and return its path.
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = tempDir.path;
        final String tempFileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpeg';
        final File tempFile = File('$tempPath/$tempFileName');
        await tempFile.writeAsBytes(bytes);
        return tempFile;
      }
    } catch (_) {}
    return null; // Return null if the compression failed.
  }
}
