import 'package:ts_driver/app/core/helpers/file_helpers/file_manager.dart';

class ChatImagesManager extends FileManager {
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
    return "$basePath/chat/images";
  }
}
