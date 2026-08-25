import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/utils/widget_utils.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Loading placeholder that mirrors the real layout — strip, hero, lesson cards.
class TrainingSkeleton extends StatelessWidget {
  const TrainingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.shimmerBaseColor;

    Widget box({double? width, required double height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: context.shimmerHighlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress strip
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      box(width: 110.w, height: 12.h),
                      box(width: 36.w, height: 12.h),
                    ],
                  ),
                  addVerticalSpace(10.h),
                  box(height: 6.h, radius: 999),
                ],
              ),
            ),
            // Hero
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 130.w, height: 10.h),
                  addVerticalSpace(10.h),
                  box(height: 168.h, radius: 20),
                  addVerticalSpace(12.h),
                  box(width: 200.w, height: 14.h),
                  addVerticalSpace(8.h),
                  box(width: 120.w, height: 12.h),
                  addVerticalSpace(10.h),
                  box(height: 4.h, radius: 999),
                ],
              ),
            ),
            // Up next label
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
              child: box(width: 90.w, height: 14.h),
            ),
            // Lesson cards
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    box(width: 96.w, height: 64.h, radius: 12),
                    addHorizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          box(width: 70.w, height: 10.h),
                          addVerticalSpace(8.h),
                          box(height: 13.h),
                          addVerticalSpace(6.h),
                          box(width: 140.w, height: 13.h),
                          addVerticalSpace(10.h),
                          box(width: 60.w, height: 16.h, radius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
