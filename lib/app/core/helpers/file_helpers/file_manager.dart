import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';

abstract class FileManager extends FileExtensionHelper {
  /// this function will return you a downloaded file path
  Future<String?> downloadFile(
    String url, {
    String explicitFileName = "",
    bool useDefaultExtension = false,
    void Function(int received, int total)? onReceiveProgress,
    void Function(String message)? onFailure,
  }) async {
    try {
      //
      //
      // building file name
      final String fileName = getFileName(
        explicitFileName.isNotEmpty ? explicitFileName : url,
        withExtension: true,
        defaultExtension: setDefaultExtension(),
        forceExtensionOveride: useDefaultExtension,
      );

      //
      //
      // building file directory path
      String fileDirectory = await getWorkingDirectory();
      if (!(await checkDirectoryExists(
        fileDirectory,
        createIfNotExist: true,
      ))) {
        if (onFailure != null) {
          onFailure("Unable to create directory for files");
        }
        return null;
      }

      final path = "$fileDirectory/$fileName";
      await Dio().download(
        url,
        path,
        onReceiveProgress: onReceiveProgress,
      );
      return path;
    } catch (error) {
      if (onFailure != null) {
        onFailure(error.toString());
      }
      return null;
    }
  }

  //
  //
  /// this takes the path of the directory and returns true if directory exist.
  /// if createIfNotExist is set to TRUE then this create the directory if not exist.
  /// by default createIfNotExist is set to false.
  Future<bool> checkDirectoryExists(String path,
      {bool createIfNotExist = false}) async {
    final dir = Directory(path);

    final exist = await dir.exists();

    if ((!exist) && createIfNotExist) {
      await dir.create(recursive: true);
      return await dir.exists();
    }

    return exist;
  }

  //
  //
  /// this will take the file name in params and
  /// check the existance of the file in the directory you returned in "setDirectory" method
  Future<bool> fileExist(String fileName) async {
    final file = File("${await getWorkingDirectory()}/$fileName");
    return await file.exists();
  }

  //
  //
  /// this will take the file name in params and
  /// will return the file from the directory you returned in "setDirectory"
  /// method if exist else it will return null
  Future<File?> getFile(String fileName) async {
    try {
      final file = File("${await getWorkingDirectory()}/$fileName");
      if (await file.exists()) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  //
  //
  /// this will take the file name in params and
  /// will delete the file from the directory you returned in "setDirectory"
  /// method if file delete successfully the it will return true else false
  Future<bool> deleteFile(String fileName) async {
    try {
      final file = File("${await getWorkingDirectory()}/$fileName");
      await file.delete();
      return true;
    } catch (_) {}
    return false;
  }

  //
  //
  /// this will return the path to the root directory + user configured directory
  Future<String> getWorkingDirectory() async {
    return setDirectory(await _getRootDirectory());
  }

  //
  //
  /// this will delete the working dorectory and all its contents
  Future<bool> deleteWorkingDirectory() async {
    try {
      final directory = Directory(await getWorkingDirectory());
      if (await directory.exists()) {
        // Recursively delete the directory and its contents
        await directory.delete(recursive: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  //
  //
  /// this will return the root documents directory of the platform system
  Future<String> _getRootDirectory() async {
    try {
      // final tempDirectory = await getApplicationDocumentsDirectory();
      // return tempDirectory.path;
      if (Platform.isIOS) {
        final tempDirectory = await getTemporaryDirectory();
        return tempDirectory.path;
      } else {
        final tempDirectory = await getExternalStorageDirectory();
        return "${tempDirectory?.path}";
      }
    } catch (e) {
      debugPrint('Error getting documents directory: $e');
    }
    return "";
  }

  //
  //
  /// basePath will be the root path to the private folder of the app
  /// and the path which will be returned bust be concatenated with the base path.
  ///  example : basePath => root/app/app_name/files and let suppose you want a
  /// child directory named "images" you must concat your directory name like this
  /// ===> return basePath+"/"+"images"; don't concat / on end.
  String setDirectory(String basePath);

  //
  //
  /// set the default extensions for the files of this directory,
  /// this extension will be used when extension is missing in url or file path
  /// or file name due to any error or miss handling
  String setDefaultExtension();
}
