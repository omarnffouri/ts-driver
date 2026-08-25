import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../theme/theme_extensions.dart';

class DocumentsSkeleton extends StatelessWidget {
  const DocumentsSkeleton({super.key});

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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      box(width: 130.w, height: 16.h),
                      box(width: 36.w, height: 14.h),
                    ],
                  ),
                  addVerticalSpace(12.h),
                  box(height: 6.h, radius: 999),
                ],
              ),
            ),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(width: 26.w, height: 26.w, radius: 999),
                        addHorizontalSpace(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(width: 60.w, height: 10.h),
                              addVerticalSpace(8.h),
                              box(width: 170.w, height: 14.h),
                              addVerticalSpace(8.h),
                              box(width: 54.w, height: 18.h, radius: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpace(12.h),
                    box(height: 78.h, radius: 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
