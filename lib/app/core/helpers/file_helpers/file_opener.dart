import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/core/widgets/file_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:get/get.dart';

class FileOpener {
  static Future<void> openFile(String filePath, {bool showError = true}) async {
    try {
      final file = File(filePath);

      // 🔍 Check file type
      final isPdf = filePath.toLowerCase().endsWith(".pdf");

      if (isPdf) {
        Get.to(() => FileViewer(
              folderName: "Pdf_viewer",
              title: file.path.split('/').last,
              path: file.path,
              file: file,
              fileLoaded: () {},
            ));
        return;
      }
      final uri = Uri.file(file.path);
      final success = await launchUrl(uri);

      if (!success && showError) {
        CommonWidgets.showSnackBar(
          title: "Error",
          message: "Unable to open file.",
          isError: true,
        );
      }
    } catch (e) {
      if (showError) {
        CommonWidgets.showSnackBar(
          title: "Error",
          message: "Something went wrong while opening file.",
          isError: true,
        );
      }
    }
  }
}
