import 'package:ts_driver/app/core/gen/assets.gen.dart';

class MessageFileHelper {
  static String getFileType(String fileExt) {
    if (MessageFileType.types.contains(fileExt.toLowerCase())) {
      return fileExt.toLowerCase();
    } else {
      return MessageFileType.none;
    }
  }

  static String getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case MessageFileType.doc:
        return Assets.chatIcons.doc.path;
      case MessageFileType.docx:
        return Assets.chatIcons.docx.path;
      case MessageFileType.ppt:
        return Assets.chatIcons.ppt.path;
      case MessageFileType.pptx:
        return Assets.chatIcons.pptx.path;
      case MessageFileType.xls:
        return Assets.chatIcons.xls.path;
      case MessageFileType.xlsx:
        return Assets.chatIcons.xlsx.path;
      case MessageFileType.pdf:
        return Assets.chatIcons.pdf.path;
      case MessageFileType.txt:
        return Assets.chatIcons.txt.path;
      case MessageFileType.odt:
        return Assets.chatIcons.odt.path;
      case MessageFileType.html:
        return Assets.chatIcons.html.path;
      case MessageFileType.zip:
        return Assets.chatIcons.zip.path;
      case MessageFileType.mp3:
        return Assets.chatIcons.audio.path;
      case MessageFileType.wav:
        return Assets.chatIcons.audio.path;
      case MessageFileType.m4a:
        return Assets.chatIcons.audio.path;
      case MessageFileType.audio:
        return Assets.chatIcons.audio.path;
      case MessageFileType.mp4:
        return Assets.chatIcons.video.path;
      case MessageFileType.webm:
        return Assets.chatIcons.video.path;
      case MessageFileType.mpeg:
        return Assets.chatIcons.video.path;
      case MessageFileType.png:
        return Assets.chatIcons.image.path;
      case MessageFileType.jpg:
        return Assets.chatIcons.image.path;
      case MessageFileType.jpeg:
        return Assets.chatIcons.image.path;
      default:
        return Assets.chatIcons.none.path;
    }
  }

  static String getFileNameWithExtenshion(String filePath) {
    var paths = filePath.split("/");
    if (paths.isNotEmpty) {
      return paths.last;
    } else {
      return "Unkown";
    }
  }

  static String getFileNameNoExtenshion(String filePath) {
    var paths = filePath.split("/");
    if (paths.isNotEmpty) {
      return removeFileExtenshion(paths.last);
    } else {
      return "Unkown";
    }
  }

  static String removeFileExtenshion(String fileName) {
    var names = fileName.split(".");
    if (names.isNotEmpty) {
      String name = "";
      for (var i = 0; i < names.length; i++) {
        if ((i + 1) != names.length) {
          name += names[i];
        }
      }
      return name;
    } else {
      return "Unkown";
    }
  }

  static bool isImageFile(String mimeType) {
    return (mimeType == 'image/png' ||
        mimeType == 'image/jpg' ||
        mimeType == 'image/jpeg' ||
        mimeType == 'image/gif');
  }

  static bool isVideoFile(String mimeType) {
    return (mimeType == 'video/mp4' ||
        mimeType == 'video/mpeg' ||
        mimeType == 'video/quicktime' ||
        mimeType == 'video/webm');
  }

  static String getFileExtension(String fileName) {
    var names = fileName.split(".");
    if (names.isNotEmpty) {
      return names.last;
    } else {
      return "none";
    }
  }
}

class MessageFileType {
  static List<String> types = [
    doc,
    docx,
    ppt,
    pptx,
    xls,
    xlsx,
    odt,
    txt,
    html,
    zip,
    pdf,
    audio,
    voice,
    png,
    jpg,
    jpeg,
    mp4,
    mp3,
    m4a,
    wav,
    mpeg,
    webm
  ];
  static const doc = "doc";
  static const docx = "docx";
  static const ppt = "ppt";
  static const pptx = "pptx";
  static const xls = "xls";
  static const xlsx = "xlsx";
  static const odt = "odt";
  static const txt = "txt";
  static const html = "html";
  static const zip = "zip";
  static const pdf = "pdf";
  static const audio = "audio";
  static const voice = "voice";
  static const png = "png";
  static const jpg = "jpg";
  static const jpeg = "jpeg";
  static const mp4 = "mp4";
  static const m4a = "m4a";
  static const wav = "wav";
  static const mp3 = "mp3";
  static const mpeg = "mpeg";
  static const webm = "webm";
  static const none = "none";
}
