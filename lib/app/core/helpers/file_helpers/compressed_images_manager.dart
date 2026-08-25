import 'dart:io';
import 'dart:typed_data';

import 'package:ts_driver/app/core/helpers/file_helpers/file_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart';

class CompressedImagesManager extends FileManager {
  @override
  String setDefaultExtension() {
    return ".jpg";
  }

  @override
  String setDirectory(String basePath) {
    //
    //
    // before changing please consider storage used,
    // and cache files disturbace
    // consider removing files from old folder
    return "$basePath/temp/compressed";
  }

  //
  //
  /// Function to check if the image needs compression (i.e., if width >= 2560)
  Future<bool> needsCompression(File imageFile) async {
    try {
      // Read the image file into memory
      final bytes = await imageFile.readAsBytes();
      final image = decodeImage(bytes);

      if (image == null) {
        return false;
      }

      // Check if the image's width is greater than or equal to 2560
      return image.width >= 2560;
    } catch (_) {
      return false;
    }
  }

  //
  //
  /// Function to compress the image (if necessary) and maintain aspect ratio
  /// will compress ( if width >= 2560) else return orignal file
  /// first periority will be fileBytes else it will take imageFile params
  Future<File> compressImage(File imageFile,
      {Uint8List? fileBytes, int width = 1600, int? height}) async {
    try {
      final bytes = fileBytes ?? await imageFile.readAsBytes();
      final originalImage = decodeImage(bytes);

      if (originalImage == null) {
        final file = await encodeFile(fileBytes, imageFile.path);
        return file ?? imageFile;
      }

      // Check if the image needs compression
      if (originalImage.width > 1600) {
        // Resize to 1600px width while maintaining aspect ratio
        int newWidth = width;
        int newHeight = height ??
            (originalImage.height * newWidth / originalImage.width).round();

        // Resize the image
        final resizedImage = copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
        );

        // Compress the image (jpg with quality 80, can be adjusted)
        final compressedBytes = encodeJpg(resizedImage, quality: 80);

        final file = await encodeFile(compressedBytes, imageFile.path);

        return file ?? imageFile;
      } else {
        // Return the original image or file from bytes if no compression is needed
        final file = await encodeFile(fileBytes, imageFile.path);
        return file ?? imageFile;
      }
    } catch (_) {
      final file = await encodeFile(fileBytes, imageFile.path);
      return file ?? imageFile;
    }
  }

  //
  //
  ///function to encode to encode bytes in a file
  Future<File?> encodeFile(Uint8List? bytes, String filePath) async {
    try {
      if (bytes == null) {
        return null;
      }
      //
      // file name
      final fileName = getFileName(
        filePath,
        withExtension: true,
        defaultExtension: setDefaultExtension(),
        forceExtensionOveride: true,
      );

      //
      //path to store compressed file
      final dirPath = await getWorkingDirectory();

      if (!(await checkDirectoryExists(dirPath, createIfNotExist: true))) {
        return null;
      }

      // Save the compressed image to a  file
      final compressedFile = File("$dirPath/$fileName")
        ..writeAsBytesSync(bytes);

      return compressedFile;
    } catch (_) {
      return null;
    }
  }

  //
  //
  /// function to clear the compressed from from temp
  Future<bool> clearImagesCompressedFolder() async {
    return await deleteWorkingDirectory();
  }
}
