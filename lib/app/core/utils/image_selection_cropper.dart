import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/core/helpers/extensions.dart';
import 'package:ts_driver/app/core/utils/rounded_fill_button.dart';
import 'package:ts_driver/app/core/widgets/common_widget.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

class ImageSelectionCropper extends StatefulWidget {
  final String title;
  final ImageProvider image;
  final Size size;
  final String noteDescription;
  final void Function(Uint8List?) onSuccess;
  const ImageSelectionCropper({
    super.key,
    required this.title,
    required this.image,
    required this.size,
    this.noteDescription = "",
    required this.onSuccess,
  });

  @override
  State<ImageSelectionCropper> createState() => _ImageSelectionCropperState();
}

class _ImageSelectionCropperState extends State<ImageSelectionCropper> {
  final GlobalKey<SimpleImageCropperState> cropKey = GlobalKey();
  final RxBool regionChanged = false.obs;
  final RxBool showAnimation = true.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //
            // Header row
            Row(
              children: [
                // Heading
                Expanded(
                  child: Text(
                    widget.title,
                    style: textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Close icon
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: Get.isDarkMode ? Colors.white : theme.primaryColor,
                  ),
                ).marginOnly(left: 15),
              ],
            ).marginOnly(left: 14, right: 14, top: 14),

            //
            //
            // note heading and description
            if (widget.noteDescription.isNotEmpty)
              Text(
                widget.noteDescription,
                style: textTheme.labelMedium,
              ).marginOnly(left: 14, right: 14, top: 10),

            //
            //
            // Body
            Stack(
              alignment: Alignment.center,
              children: [
                //
                // edit view
                SizedBox(
                  height: widget.size.height,
                  width: widget.size.width,
                  child: SimpleImageCropper(
                    key: cropKey,
                    height: widget.size.height,
                    width: widget.size.width,
                    image: widget.image,
                    onRegionSelected: (Region region) {
                      regionChanged.value = true;
                    },
                    tlCornerBgColor: AppColorsLight.mainColor,
                    tlCornerFontColor: Colors.white,
                    brCornerBgColor: AppColorsLight.mainColor,
                    brCornerFontColor: Colors.white,
                  ),
                ),

                //
                //
                // animation view
                Obx(
                  () => Visibility(
                    visible: showAnimation.value,
                    child: GestureDetector(
                      onTap: () {
                        showAnimation.value = false;
                      },
                      onPanDown: (details) {
                        showAnimation.value = false;
                      },
                      child: Container(
                        width: double.infinity,
                        height: widget.size.height,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.black.applyOpacity(0.5),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: Center(
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: Lottie.asset(
                                Assets.json.bolCropAnimation,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).marginOnly(top: 10),

            //
            //
            // crop done button
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => BounceInUp(
                  animate: regionChanged.value,
                  child: RoundedFillButton(
                    label: "Done",
                    onPressed: () async {
                      try {
                        Uint8List? image =
                            await cropKey.currentState?.cropImageUint8List();
                        if (image != null) {
                          widget.onSuccess(image);
                        } else {
                          CommonWidgets.showSnackBar(
                            title: "Error",
                            message:
                                "Something went wrong while croping image.",
                          );
                        }
                      } catch (_) {
                        CommonWidgets.showSnackBar(
                          title: "Error",
                          message: "Something went wrong while croping image.",
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
