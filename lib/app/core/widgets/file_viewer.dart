import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_extension_helper.dart';
import 'package:ts_driver/app/core/utils/functions.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

import 'app_text.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_extensions.dart';

class FileViewer extends StatefulWidget {
  const FileViewer({
    super.key,
    required this.title,
    required this.path,
    this.file,
    required this.fileLoaded,
    required this.folderName,
  });
  final String title;
  final String path;
  final File? file;

  final String folderName;
  final Function() fileLoaded;

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late Future<bool> isConnected;
  late String extension;
  late bool isPdf;
  late bool isImage;

  final RxBool isSharing = false.obs;

  @override
  void initState() {
    super.initState();
    isConnected = checkInternetConnectivity();
    extension = widget.path.split('.').last;
    isPdf = extension.contains('pdf');
    isImage = extension.contains('jpg') ||
        extension.contains('jpeg') ||
        extension.contains('png');
  }

  Future<bool> checkInternetConnectivity() async {
    InternetConnectionStatus connectivityResult =
        await InternetConnectionChecker().connectionStatus;
    return connectivityResult != InternetConnectionStatus.disconnected;
  }

  @override
  Widget build(BuildContext context) {
    log('PdfViewer ${widget.path}');

    return Container(
      decoration: BoxDecoration(
        gradient: context.headerGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          //
          //
          // app bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: kWhiteColor,
            elevation: 0,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: context.headerGradient),
            ),
            toolbarHeight: 70.h,
            title: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 30,
                      color: kWhiteColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppText(
                      text: widget.title,
                      weight: FontWeight.bold,
                      color: kWhiteColor,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.download_for_offline_rounded,
                  color: kWhiteColor,
                ),
                iconSize: 40,
                onPressed: () async {
                  await saveFile(
                    url: widget.path,
                    fileName: widget.title,
                    extension: extension,
                  );
                },
              )
            ],
          ),

          //
          //
          // fab button
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _shareFile();
            },
            child: Obx(
              () => isSharing.value
                  ? const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 4,
                      ),
                    )
                  : const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
            ),
          ),

          //
          //
          // body
          body: FutureBuilder<bool>(
            future: isConnected,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                bool connected = snapshot.data ?? false;
                return connected ? buildOnlineContent() : buildOfflineContent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildOnlineContent() {
    return isPdf
        ? widget.file != null
            ? SfPdfViewer.file(
                widget.file!,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                maxZoomLevel: 5,
                onDocumentLoaded: (details) {
                  widget.fileLoaded();
                },
              )
            : SfPdfViewer.network(
                widget.path,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                maxZoomLevel: 5,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  widget.fileLoaded();
                },
              )
        : isImage
            ? Image.network(
                widget.path,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    widget.fileLoaded();
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: kMainColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder:
                    (BuildContext context, Object exception, StackTrace? _) {
                  return const Icon(Icons.error);
                },
              )
            : const SizedBox();
  }

  Widget buildOfflineContent() {
    return FutureBuilder<dynamic>(
      future: retrieveFile("truck_docs", widget.title, widget.path),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kMainColor),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error: Document not found'));
        } else {
          return isPdf
              ? snapshot.hasData
                  ? SfPdfViewer.file(
                      snapshot.data,
                      pageLayoutMode: PdfPageLayoutMode.continuous,
                      maxZoomLevel: 5,
                    )
                  : const SizedBox()
              : isImage
                  ? snapshot.hasData
                      ? Image.file(snapshot.data)
                      : const SizedBox()
                  : const SizedBox();
        }
      },
    );
  }

  void _shareFile() async {
    isSharing.value = true;
    try {
      //
      //
      // if not valid url return
      if (widget.path.isEmpty) {
        CommonWidgets.showSnackBar(
          title: "Error",
          message: "Unable to download, invalid url.",
        );
        return;
      }

      //
      // file details
      final fileName = FileExtensionHelper().getFileName(
        widget.path,
        withExtension: true,
      );
      Directory directory = await getTemporaryDirectory();
      final path = "${directory.path}/$fileName";

      //
      //
      // downloading file
      await Dio().download(
        widget.path,
        path,
      );

      //
      // check if file exist then share it
      final downloadedFile = File(path);

      if ((await downloadedFile.exists())) {
        //
        //
        // share file
        await SharePlus.instance.share(
          ShareParams(
            subject: fileName,
            files: [
              XFile(
                path,
                mimeType: lookupMimeType(path),
                name: fileName,
              )
            ],
          ),
        );

        //
        //
        // delete file from temp dir after sharing
        await downloadedFile.delete();
      } else {
        CommonWidgets.showSnackBar(
          title: "Error",
          message: "Unable to download file for sharing.",
        );
      }
    } catch (_) {
      CommonWidgets.showSnackBar(
        title: "Error",
        message: "Something went wrong while sharing file.",
      );
    }
    isSharing.value = false;
  }
}
