import 'package:ts_driver/app/core/helpers/file_helpers/file_manager.dart';

class ChatDocumentsManager extends FileManager {
  @override
  String setDefaultExtension() {
    return ".pdf";
  }

  @override
  String setDirectory(String basePath) {
    //
    //
    // before changing please consider storage used,
    // and cache files disturbace
    // consider removing files from old folder
    return "$basePath/chat/documents";
  }

  Future<String?> getDocumentFile(
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
      // if file exist return file path
      final file = await getFile(fileName);
      if (file != null) {
        return file.path;
      }

      //
      //
      // if file not exist downloadFile
      return await downloadFile(
        url,
        explicitFileName: explicitFileName,
        useDefaultExtension: useDefaultExtension,
        onReceiveProgress: onReceiveProgress,
        onFailure: onFailure,
      );
    } catch (error) {
      if (onFailure != null) {
        onFailure(error.toString());
      }
      return null;
    }
  }
}
