import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../theme/theme_extensions.dart';

/// Loading placeholder mirroring the player layout — a dark video stage, then
/// the progress card and metadata tiles rendered as real card shapes with
/// shimmering content inside.
class PlayerSkeleton extends StatelessWidget {
  const PlayerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    AppText(
                      text: 'Loading lesson',
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _progressCard(context),
                SizedBox(height: 20.h),
                const _Bar(width: 200, height: 18),
                SizedBox(height: 8.h),
                const _Bar(width: 70, height: 22, radius: 8),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _tile(context)),
                    SizedBox(width: 10.w),
                    Expanded(child: _tile(context)),
                    SizedBox(width: 10.w),
                    Expanded(child: _tile(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(context, 16),
      child: Row(
        children: [
          _Bar(width: 72.w, height: 72.w, circle: true),
          SizedBox(width: 16.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Bar(width: 130, height: 16),
                SizedBox(height: 8),
                _Bar(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: _cardDecoration(context, 12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 42, height: 10),
          SizedBox(height: 8),
          _Bar(width: 60, height: 14),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context, double radius) {
    return BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(color: context.dividerColor),
      boxShadow: context.cardShadow,
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    this.width,
    required this.height,
    this.radius = 6,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBaseColor,
      highlightColor: context.shimmerHighlightColor,
      child: Container(
        width: width?.w,
        height: circle ? height : height.h,
        decoration: BoxDecoration(
          color: context.shimmerBaseColor,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius.r),
        ),
      ),
    );
  }
}
