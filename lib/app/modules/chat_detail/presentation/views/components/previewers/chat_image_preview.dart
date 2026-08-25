import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/chat_images_manager.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_opener.dart';
import 'package:ts_driver/app/core/widgets/app_header_row.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';

// ignore: must_be_immutable
class ChatImagePreview extends StatelessWidget {
  ChatImagePreview({
    super.key,
    required this.title,
    required this.previewImages,
    this.initialIndex = 0,
  });

  final String title;
  final List<PreviewImage> previewImages;
  final int initialIndex;
  final RxInt currentIndex = 0.obs;
  final isDownloading = false.obs;
  final downloadProgress = (0.0).obs;
  final ChatImagesManager chatImagesManager = Get.put(ChatImagesManager());

  @override
  Widget build(BuildContext context) {
    final previewlist = previewImages
        .where((e) => ((e.file != null) || (e.url?.isNotEmpty ?? false)))
        .toList()
        .obs;

    final images = previewlist.map((element) {
      if (element.file != null) {
        return Image.file(element.file!).image;
      } else {
        return CachedNetworkImageProvider(element.url!);
      }
    }).toList();

    final pageController = PageController(
        initialPage: initialIndex > (images.length - 1) ? 0 : initialIndex);
    if (initialIndex <= (images.length - 1)) {
      currentIndex.value = initialIndex;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 24,
              color: Colors.white,
            )),
        actions: [
          Obx(
            () => Visibility(
                visible:
                    (previewImages[currentIndex.value].url ?? "").isNotEmpty ||
                        previewImages[currentIndex.value].file != null,
                child: Obx(
                  () => isDownloading.value
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(downloadProgress.value * 100).toStringAsFixed(2)} %",
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ).marginOnly(right: 5),
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                value: downloadProgress.value,
                                color: Colors.white,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 4,
                              ),
                            ),
                          ],
                        ).marginOnly(right: 15)
                      : IconButton(
                          onPressed: () {
                            downloadImage();
                          },
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                )),
          ),
        ],
        title: AppHeader(
          title: title,
          subTitle: null,
          leading: null,
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: images[index],
            initialScale: PhotoViewComputedScale.contained * 0.8,
            // heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
          );
        },
        itemCount: images.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : (event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 0)),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: pageController,
        onPageChanged: (pageIndex) {
          currentIndex.value = pageIndex;
        },
      ),
    );
  }

  downloadImage() async {
    try {
      final image = previewImages[currentIndex.value];
      //
      // if image from a file then open file image
      if (image.file != null) {
        await FileOpener.openFile(image.file!.path);
        return;
      }

      //
      //
      // if url empty or null then return
      if ((image.url ?? "").isEmpty) {
        return;
      }

      //
      //
      // check if image already exist in system then open from
      // systems instead of downloading new one
      final file = await chatImagesManager.getFile(
        chatImagesManager.getFileName(
          image.url!,
          withExtension: true,
        ),
      );

      if (file != null) {
        image.file = file;
        await FileOpener.openFile(file.path);
        return;
      }

      //
      // setting downloading true
      isDownloading.value = true;

      //
      //
      // downloading file and updating download progress from callback
      final filePath = await chatImagesManager.downloadFile(
        image.url ?? "",
        onReceiveProgress: (received, total) {
          downloadProgress.value = (received / total);
        },
        onFailure: (message) {
          CommonWidgets.showSnackBar(
            title: "Error",
            message: "Something went wrong while downloading",
          );
        },
      );

      //
      //
      // resetting download progress and states etc
      isDownloading.value = false;
      downloadProgress.value = 0.0;

      //
      // if file exist then open that file
      if (filePath != null) {
        if ((await chatImagesManager.fileExist(chatImagesManager.getFileName(
          filePath,
          withExtension: true,
        )))) {
          image.file = File(filePath);
          await FileOpener.openFile(filePath);
        }
      }
    } catch (_) {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }
}

class PreviewImage {
  String? url;
  File? file;

  PreviewImage({required this.url, required this.file});

  @override
  operator ==(Object other) =>
      (other is PreviewImage && other.url == url && other.file == file);

  @override
  int get hashCode => Object.hash(url, file);
}
