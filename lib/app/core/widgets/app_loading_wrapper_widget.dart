import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts_driver/app/theme/theme_extensions.dart';

class LoadingWrapperWidget extends StatelessWidget {
  const LoadingWrapperWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });
  final Widget child;
  final bool isLoading;

  /// Override shimmer tones (e.g. white-based on a colored surface).
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: baseColor ?? context.shimmerBaseColor,
            highlightColor: highlightColor ?? context.shimmerHighlightColor,
            child: child,
          )
        : child;
  }
}
