import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

/// Shimmer placeholder for a loading conversation list (group + one-to-one).
class ConversationListSkeleton extends StatelessWidget {
  const ConversationListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: context.shimmerBaseColor,
            highlightColor: context.shimmerHighlightColor,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              margin: EdgeInsets.only(top: index == 0 ? 8.h : 0),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: context.shimmerBaseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: context.shimmerBaseColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 200.w,
                          height: 11.h,
                          decoration: BoxDecoration(
                            color: context.shimmerBaseColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
