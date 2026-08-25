import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Content-shaped skeleton shown while a settlement's details load — a summary
/// card placeholder followed by section-card placeholders, mirroring the real
/// layout so content feels like it's materializing. Shared by the driver and
/// partner details views.
class SettlementLoadingView extends StatelessWidget {
  const SettlementLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummaryCardSkeleton(),
            SizedBox(height: 16.h),
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: const _SectionCardSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: double.infinity, height: 28.h, radius: 6.r),
          SizedBox(height: 16.h),
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  _Bar(width: 120.w, height: 14.h),
                  const Spacer(),
                  _Bar(width: 70.w, height: 14.h),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerRight,
            child: _Bar(width: 120.w, height: 30.h, radius: 6.r),
          ),
        ],
      ),
    );
  }
}

class _SectionCardSkeleton extends StatelessWidget {
  const _SectionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Bar(width: 4.w, height: 18.h, radius: 2.r),
              SizedBox(width: 10.w),
              _Bar(width: 120.w, height: 16.h),
              const Spacer(),
              _Bar(width: 80.w, height: 16.h),
            ],
          ),
          SizedBox(height: 14.h),
          const _Bar(width: double.infinity, height: 1.4),
          SizedBox(height: 14.h),
          ...List.generate(
            2,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  _Bar(width: 90.w, height: 16.h),
                  const Spacer(),
                  _Bar(width: 70.w, height: 16.h),
                  SizedBox(width: 10.w),
                  _Bar(width: 20.r, height: 20.r, radius: 6.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.cardShadow,
      ),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Shimmer.fromColors(
        baseColor: context.shimmerBaseColor,
        highlightColor: context.shimmerHighlightColor,
        child: child,
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
