import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/helpers/file_helpers/file_types.dart';

import '../controllers/media_picker_previewer_controller.dart';

class MediaPickerPreviewerView extends GetView<MediaPickerPreviewerController> {
  const MediaPickerPreviewerView({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Container(
        color: theme.primaryColor,
        child: SafeArea(
          child: Stack(
            children: [
              //
              //
              // main view
              Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  scrolledUnderElevation: 0,
                  //
                  //
                  // close  icon
                  leading: IconButton(
                    onPressed: () async {
                      Get.back(
                          result: await controller.getResults(cancel: true));
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  //
                  //
                  // action button
                  actions: [
                    //
                    // hd/sd  icon
                    Obx(
                      () => Visibility(
                        visible: controller.canCompress,
                        child: IconButton(
                          onPressed: () {
                            if (controller.canCompress) {
                              controller.shouldCompress.toggle();
                            }
                          },
                          icon: Icon(
                            controller.shouldCompress.value
                                ? Icons.hd_outlined
                                : Icons.hd_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).marginSymmetric(horizontal: 5),

                    //
                    // edit  icon
                    Obx(
                      () => Visibility(
                        visible: (controller.currentIndex.value > -1) &&
                            (controller
                                    .mediaFiles[controller.currentIndex.value]
                                    .type ==
                                MediaType.image) &&
                            controller.params.enableEditing,
                        child: IconButton(
                          onPressed: () {
                            controller.showImageEditor();
                          },
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).marginSymmetric(horizontal: 5),

                    //
                    // done  icon
                    IconButton(
                      onPressed: () async {
                        Get.back(result: await controller.getResults());
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                        ),
                        child: const Icon(
                          Icons.done_rounded,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                //
                //
                // body

                body: Column(
                  children: [
                    //
                    //
                    // PageView to swipe through images
                    Expanded(
                      child: Obx(
                        () => PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.changeIndex,
                          itemCount: controller.mediaFiles.length,
                          itemBuilder: (context, index) {
                            final mediaFile =
                                controller.mediaFiles.elementAt(index);

                            return mediaFile.type == MediaType.image
                                ? Obx(() => mediaFile.editedFile.value != null
                                    ? Image.memory(
                                        controller.mediaFiles[index].editedFile
                                            .value!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      )
                                    : Image.file(
                                        controller
                                            .mediaFiles[index].orignalFile,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      ))
                                : Container(
                                    color: Colors.white10,
                                    child: Center(
                                      child: Image.asset(
                                        controller.compressedImagesManager
                                            .getFileIcon(FileTypes.mp4),
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),

                    // Thumbnail preview list at the bottom
                    SizedBox(
                      height: 70,
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.mediaFiles.length,
                          itemBuilder: (context, index) {
                            final mediaFile =
                                controller.mediaFiles.elementAt(index);
                            return _SmallPreviewItemView(
                              mediaFile: mediaFile,
                              index: index,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Obx(
                () => controller.isCompressing.value
                    ? Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColorsLight.mainColor,
                            strokeWidth: 5,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallPreviewItemView extends GetView<MediaPickerPreviewerController> {
  final MediaPickerFile mediaFile;
  final int index;
  const _SmallPreviewItemView({
    required this.mediaFile,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Obx(
        () => Stack(
          children: [
            //
            //
            // item view
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.currentIndex.value == index
                      ? Colors.white
                      : Colors.transparent, // White border if selected
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: mediaFile.type == MediaType.image
                    ? Image.file(
                        mediaFile.orignalFile,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        cacheWidth: 135,
                      )
                    : Center(
                        child: Image.asset(
                          controller.compressedImagesManager
                              .getFileIcon(FileTypes.mp4),
                          width: 45,
                          height: 45,
                        ),
                      ),
              ),
            ),

            //
            //
            // delete icon
            if (controller.currentIndex.value == index)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    controller.currentIndex.value =
                        (controller.mediaFiles.length) - 2;

                    controller.mediaFiles.removeAt(index);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
