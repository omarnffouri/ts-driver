import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../theme/theme_extensions.dart';

class SignedFormsSkeleton extends StatelessWidget {
  const SignedFormsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBaseColor,
      highlightColor: context.shimmerHighlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: skeletonBar(height: 48.h, radius: 12)),
                SizedBox(width: 10.w),
                skeletonBar(height: 48.h, width: 48.w, radius: 12),
              ],
            ),
            SizedBox(height: 22.h),
            skeletonBar(height: 14.h, width: 96.w, radius: 6),
            SizedBox(height: 16.h),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.72,
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (_) => const _CardSkeleton()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opaque white because the parent [Shimmer] masks the fill with its sweep.
Widget skeletonBar({required double height, double? width, double radius = 8}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius.r),
    ),
  );
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: skeletonBar(
              height: double.infinity, width: double.infinity, radius: 12),
        ),
        SizedBox(height: 8.h),
        skeletonBar(height: 10.h, width: double.infinity, radius: 4),
        SizedBox(height: 5.h),
        skeletonBar(height: 10.h, width: 48.w, radius: 4),
        SizedBox(height: 7.h),
        skeletonBar(height: 8.h, width: 32.w, radius: 4),
      ],
    );
  }
}
