import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class AnnouncementsLoadingView extends StatelessWidget {
  const AnnouncementsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final blockColor = context.shimmerBaseColor;
    return Shimmer.fromColors(
      baseColor: blockColor,
      highlightColor: context.shimmerHighlightColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(blockColor, width: double.infinity, height: Get.height * 0.20),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _block(blockColor, width: 100, height: 15),
              _block(blockColor, width: 70, height: 25),
            ],
          ),
          _block(blockColor, width: 150, height: 15).marginOnly(top: 10),
          _block(blockColor, width: 200, height: 15).marginOnly(top: 5),
          _block(blockColor, width: 150, height: 15).marginOnly(top: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _block(blockColor, width: 8, height: 8).marginOnly(right: 5),
              _block(blockColor, width: 8, height: 8).marginOnly(right: 5),
              _block(blockColor, width: 8, height: 8),
            ],
          ).marginOnly(top: 15),
        ],
      ).marginSymmetric(horizontal: 10, vertical: 5),
    );
  }

  Widget _block(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
    );
  }
}
