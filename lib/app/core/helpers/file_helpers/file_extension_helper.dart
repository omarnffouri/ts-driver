import 'package:get/get.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_types.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class FileExtensionHelper {
  //
  //
  /// this will take file path, url, name and returns the file ext
  String getFileExtension(String path) {
    final index = path.lastIndexOf('.');
    if (index < 0 || index + 1 >= path.length) return path;
    return path.substring(index + 1).toLowerCase();
  }

  //
  //
  /// this will take file path, url, name or extension and return a FileTypes enum if
  ///  file type not found in declared FileTypes this return a FileTypes.none
  FileTypes getFileType(String path) {
    final fileExt = getFileExtension(path);
    final type =
        FileTypes.values.firstWhereOrNull((item) => item.name == fileExt);

    if (type == null) {
      return FileTypes.none;
    }
    return type;
  }

  //
  //
  /// this take a FileTypes enum in param, and return a path of png icon from assets
  /// base on the FileTypes param if FileType not found in declared FileTypes this will
  /// return the FilesTypes.none
  String getFileIcon(FileTypes fileType) {
    switch (fileType) {
      case FileTypes.doc:
        return Assets.chatIcons.doc.path;
      case FileTypes.docx:
        return Assets.chatIcons.docx.path;
      case FileTypes.ppt:
        return Assets.chatIcons.ppt.path;
      case FileTypes.pptx:
        return Assets.chatIcons.pptx.path;
      case FileTypes.xls:
        return Assets.chatIcons.xls.path;
      case FileTypes.csv:
        return Assets.chatIcons.csv.path;
      case FileTypes.xlsx:
        return Assets.chatIcons.xlsx.path;
      case FileTypes.pdf:
        return Assets.chatIcons.pdf.path;
      case FileTypes.txt:
        return Assets.chatIcons.txt.path;
      case FileTypes.odt:
        return Assets.chatIcons.odt.path;
      case FileTypes.html:
        return Assets.chatIcons.html.path;
      case FileTypes.zip:
        return Assets.chatIcons.zip.path;
      case FileTypes.mp3:
        return Assets.chatIcons.audio.path;
      case FileTypes.wav:
        return Assets.chatIcons.audio.path;
      case FileTypes.m4a:
        return Assets.chatIcons.audio.path;
      case FileTypes.audio:
        return Assets.chatIcons.audio.path;
      case FileTypes.mp4:
        return Assets.chatIcons.video.path;
      case FileTypes.webm:
        return Assets.chatIcons.video.path;
      case FileTypes.mpeg:
        return Assets.chatIcons.video.path;
      case FileTypes.png:
        return Assets.chatIcons.image.path;
      case FileTypes.jpg:
        return Assets.chatIcons.image.path;
      case FileTypes.jpeg:
        return Assets.chatIcons.image.path;
      default:
        return Assets.chatIcons.none.path;
    }
  }

  //
  //
  /// this will take file path, url, name and returns the file's name
  /// if withExtension is set to True this will return file name with extension
  /// example: my_image.png, if withExtension is set to False this will return only
  /// file name example: my_image, By Default withExtension is false.
  /// if path is empty this will return "unkown" and if file name is "unkown" then their will
  /// be no extension with file name in this case you can pass defaultExtension like : .png .mp4 etc and
  /// deafult extension will be used with unkown file name like: unknown+defaultExtension
  /// if forceExtensionOveride is set to true this will overide the name ext with defaultExtension if default defaultExtension is not null or empty
  String getFileName(
    String path, {
    bool withExtension = false,
    String defaultExtension = "",
    bool forceExtensionOveride = false,
  }) {
    String fileName = "unkown";

    if (path.isEmpty) {
      return withExtension ? "$fileName$defaultExtension" : fileName;
    }

    final index = path.lastIndexOf('/');

    if (index < 0 || index + 1 >= path.length) {
      fileName = path;
    } else {
      fileName = path.substring(index + 1);
    }

    if (withExtension) {
      return forceExtensionOveride
          ? _overideFileNameExtension(fileName, defaultExtension)
          : fileName;
    }
    return removeFileNameExtension(fileName);
  }

//
//
  /// this will remove file name old ext and replace with new provided extension only
  /// if extension is not empty, if provided extension is empty the this will return
  /// orignal file name
  String _overideFileNameExtension(String fileName, String extension) {
    if (extension.isEmpty) {
      return fileName;
    }
    final withoutExt = removeFileNameExtension(fileName);
    return "$withoutExt$extension";
  }

  //
  //
  /// this will take the file name and remove the extension from the file name
  ///  example:  before -> my_image.png  || after -> my_image
  /// if fileName is empty this will return "unknown"
  String removeFileNameExtension(String fileName) {
    var names = fileName.split(".");

    if (names.isNotEmpty) {
      if (names.length == 1) {
        return names.first;
      }
      String name = "";
      for (var i = 0; i < names.length; i++) {
        if ((i + 1) != names.length) {
          name += names[i];
        }
      }
      return name;
    }

    return "unkown";
  }

  //
  //
  /// pass mimeType in params, this check for image mimetype and returns bool
  bool isImageFile(String mimeType) {
    return (mimeType == 'image/png' ||
        mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/gif');
  }

  //
  //
  /// pass mimeType in params, this check for video mimetype and returns bool
  bool isVideoFile(String mimeType) {
    return (mimeType == 'video/mp4' ||
        mimeType == 'video/mpeg' ||
        mimeType == 'video/quicktime' ||
        mimeType == 'video/webm');
  }
}
