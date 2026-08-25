import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:ts_driver/app/theme/app_colors.dart';
import 'package:ts_driver/app/modules/annoucments/presentation/controllers/annoucments_controller.dart';
import 'package:ts_driver/app/modules/chat_detail/presentation/views/components/previewers/chat_image_preview.dart';
import 'package:ts_driver/app/core/widgets/profile_image.dart';
import 'package:ts_driver/app/core/gen/assets.gen.dart';

// unused view till now
class AnnoucmentsView extends GetView<AnnoucmentsController> {
  const AnnoucmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme using the MediaQuery or Theme widget
    ThemeData theme = Theme.of(context);

    // Retrieve specific theme colors
    Color primaryColor = theme.primaryColor;

    return Container(
      width: double.infinity,
      color: Get.isDarkMode ? primaryColor : Colors.white,
      child: Obx(() => controller.isLoadingAnnoucements
              ? _buildLoadingView()
              : controller.annoucements.isEmpty
                  ? Column(
                      children: [
                        Lottie.asset(
                          Assets.json.noDataAnimation,
                          height: Get.height * 0.30,
                        ),
                        const Text(
                          "No announcement at this moment.",
                          style: TextStyle(
                            color: AppColorsLight.mainColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        //
                        // dot indicator
                        SmoothPageIndicator(
                          controller: controller.annoucementsPageController,
                          count: controller.annoucements.length,
                          effect: const SwapEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColorsLight.mainColor,
                            type: SwapType.yRotation,
                          ),
                        ).marginOnly(top: 10),

                        //
                        // page builder
                        ExpandablePageView.builder(
                          controller: controller.annoucementsPageController,
                          itemCount: controller.annoucements.length,
                          itemBuilder: (context, index) {
                            final annoucenment = controller.annoucements[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.updateAnnoucementsReadStatus(
                                        annoucenment, index);
                                    Get.to(
                                      ChatImagePreview(
                                          title: "Announcement",
                                          previewImages: [
                                            PreviewImage(
                                                url: annoucenment.image,
                                                file: null)
                                          ],
                                          initialIndex: 0),
                                    );
                                  },
                                  child: ProfileImage.network(
                                    url: annoucenment.image ??
                                        "https://images.pexels.com/photos/312839/pexels-photo-312839.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                                    radius: 10,
                                    width: double.infinity,
                                    height: Get.height * 0.20,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  annoucenment.title ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  annoucenment.message ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ).marginSymmetric(horizontal: 10, vertical: 20);
                          },
                        ),
                      ],
                    )

          // CarouselSlider.builder(
          //     itemCount: controller.annoucements.length,
          //     options: CarouselOptions(
          //       height: Get.height * 0.40,
          //       viewportFraction: 1,
          //       initialPage: 0,
          //       enableInfiniteScroll: true,
          //       reverse: false,
          //       autoPlay: true,
          //       autoPlayInterval: const Duration(seconds: 5),
          //       autoPlayAnimationDuration:
          //           const Duration(milliseconds: 800),
          //       autoPlayCurve: Curves.fastOutSlowIn,
          //       enlargeCenterPage: true,
          //       enlargeFactor: 0.3,
          //       onPageChanged: (index, reason) {
          //         //
          //       },
          //       scrollDirection: Axis.horizontal,
          //     ),
          //     itemBuilder: (BuildContext context, int itemIndex,
          //         int pageViewIndex) {
          //       final annoucenment = controller.annoucements[itemIndex];
          //       return SingleChildScrollView(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             GestureDetector(
          //               onTap: () {
          //                 Get.to(
          //                   ChatImagePreview(
          //                       title: "Announcement",
          //                       previewImages: [
          //                         PreviewImage(
          //                             url: annoucenment.image, file: null)
          //                       ],
          //                       initialIndex: 0),
          //                 );
          //               },
          //               child: ProfileImage.network(
          //                 url: annoucenment.image ??
          //                     "https://images.pexels.com/photos/312839/pexels-photo-312839.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
          //                 radius: 10,
          //                 width: double.infinity,
          //                 height: Get.height * 0.20,
          //               ),
          //             ),
          //             const SizedBox(
          //               height: 10,
          //             ),
          //             Text(
          //               annoucenment.title ?? "",
          //               style: const TextStyle(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             Text(
          //               annoucenment.message ?? "",
          //               style: const TextStyle(
          //                 fontSize: 14,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ).marginSymmetric(vertical: 20, horizontal: 10);
          //     },
          //   ),
          ),
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColorsLight.shimmerBaseColor,
          highlightColor: Colors.grey.shade300,
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              top: index == 0 ? 15 : 5,
              bottom: 5,
            ),
            width: Get.width * 1,
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode ? Colors.white12 : Colors.grey.shade200,
            ),
            constraints: const BoxConstraints(minHeight: 70),
          ),
        );
      },
    );
  }
}
