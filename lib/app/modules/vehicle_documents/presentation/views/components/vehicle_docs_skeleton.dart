import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/widget_utils.dart';
import '../../../../../theme/theme_extensions.dart';

class VehicleDocsSkeleton extends StatelessWidget {
  const VehicleDocsSkeleton({super.key});

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

    // Mirrors VehicleDocCard exactly: real card shell (so the bg/border/shadow
    // match the loaded list), shimmer only the inner icon + title placeholders.
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: 6,
      separatorBuilder: (_, __) => addVerticalSpace(12.h),
      itemBuilder: (_, __) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.cardShadow,
        ),
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: context.shimmerHighlightColor,
          child: Row(
            children: [
              box(width: 44.w, height: 44.w, radius: 12),
              addHorizontalSpace(12.w),
              box(width: 160.w, height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}
