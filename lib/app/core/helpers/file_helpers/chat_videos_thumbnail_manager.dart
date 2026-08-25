import 'dart:io';
import 'dart:typed_data';

import 'package:ts_driver/app/core/helpers/file_helpers/file_manager.dart';
import 'package:video_thumbnail_pro/index.dart';
import 'package:video_thumbnail_pro/video_thumbnail_pro.dart';

class ChatVideosThumbnailManager extends FileManager {
  @override
  String getFileName(
    String path, {
    bool withExtension = false,
    String defaultExtension = "",
    bool forceExtensionOveride = false,
  }) {
    return super.getFileName(
      path,
      withExtension: withExtension,
      defaultExtension: setDefaultExtension(),
      forceExtensionOveride: true,
    );
  }

  @override
  String setDefaultExtension() {
    return ".png";
  }

  @override
  String setDirectory(String basePath) {
    //
    //
    // before changing please consider storage used,
    // and cache files disturbace
    // consider removing files from old folder
    return "$basePath/chat/videos/thumbnails";
  }

  @override
  Future<String?> downloadFile(
    String url, {
    String explicitFileName = "",
    bool useDefaultExtension = false,
    void Function(int received, int total)? onReceiveProgress,
    void Function(String message)? onFailure,
  }) async {
    try {
      //
      // generating the thumbnail from url
      Uint8List? bytes = await VideoThumbnailPro.thumbnailData(
        video: url,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        maxWidth: 200,
        quality: 100,
      );

      return await saveVideoThumbnail(
          bytes, explicitFileName.isNotEmpty ? explicitFileName : url);
    } catch (_) {}
    return null;
  }

  @override
  Future<File?> getFile(String fileName) async {
    try {
      final name = getFileName(fileName, withExtension: true);
      return await super.getFile(name);
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> deleteFile(String fileName) async {
    try {
      final name = getFileName(fileName, withExtension: true);
      return await super.deleteFile(name);
    } catch (_) {}
    return false;
  }

  Future<String?> saveVideoThumbnail(Uint8List bytes, String fileName) async {
    try {
      // building file name
      final String newName = getFileName(
        fileName,
        withExtension: true,
      );

      // building file directory path
      String fileDirectory = await getWorkingDirectory();
      if (!(await checkDirectoryExists(
        fileDirectory,
        createIfNotExist: true,
      ))) {
        return null;
      }

      // final path for the file
      final path = "$fileDirectory/$newName";

      File file = File(path);
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> getVideoThumbnail({String? url, File? file}) async {
    try {
      if (file != null) {
        return await VideoThumbnailPro.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 200,
          maxWidth: 200,
          quality: 100,
        );
      }

      if ((url ?? "").isEmpty) {
        return null;
      }

      //
      // getting thumbnail file from the working dir
      var thumbnailFile = await getFile(url!);

      //
      // if thumbnail file found then return file as Uint8List
      // else download and save thumbnail and return thumbnail as Uint8List
      if (thumbnailFile != null) {
        return await thumbnailFile.readAsBytes();
      } else {
        final downloadedFilePath = await downloadFile(url);
        if (downloadedFilePath != null) {
          return await File(downloadedFilePath).readAsBytes();
        }
      }
    } catch (_) {}
    return null;
  }
}
