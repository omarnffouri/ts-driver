import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';
import 'package:ts_driver/app/core/widgets/app_text.dart';

/// Skeleton placeholder shown while a shipments tab loads.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6.w, bottom: 8.h),
              child: Shimmer.fromColors(
                baseColor: context.shimmerBaseColor,
                highlightColor: context.shimmerHighlightColor,
                child: AppText(
                  text: title,
                  size: 14,
                  weight: FontWeight.w700,
                  color: context.secondaryTextColor,
                ),
              ),
            ),
            ...List.generate(
              6,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: const _SkeletonCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      padding: EdgeInsets.fromLTRB(15.w, 12.h, 12.w, 12.h),
      child: Shimmer.fromColors(
        baseColor: context.shimmerBaseColor,
        highlightColor: context.shimmerHighlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Bar(width: 26.r, height: 26.r, radius: 8.r),
                SizedBox(width: 8.w),
                _Bar(width: 90.w, height: 14.h),
                const Spacer(),
                _Bar(width: 64.w, height: 18.h),
              ],
            ),
            SizedBox(height: 12.h),
            _Bar(width: 200.w, height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, this.radius});
  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.shimmerBaseColor,
        borderRadius: BorderRadius.circular(radius ?? 4.r),
      ),
    );
  }
}
