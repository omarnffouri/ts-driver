import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

class AppRedHeader extends StatelessWidget {
  const AppRedHeader(
      {Key? key,
      this.height,
      this.padding,
      this.child,
      this.radius,
      this.width,
      this.gradient})
      : super(key: key);

  final double? height, radius, width;

  final EdgeInsetsGeometry? padding;
  final Widget? child;

  /// Overrides the default theme-aware header gradient (brand red / dark).
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? context.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius ?? 32),
          bottomRight: Radius.circular(radius ?? 32),
        ),
      ),
      child: child,
    );
  }
}
