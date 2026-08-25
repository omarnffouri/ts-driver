import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import 'app_red_header.dart';

/// Canonical screen shell: the [AppRedHeader] gradient backs the status-bar
/// inset, while the screen background fills the bottom gesture inset so the red
/// never bleeds under the content. Content keeps the same top+bottom safe-area
/// padding it would get from a plain `SafeArea`.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.radius,
  });

  final Widget child;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return AppRedHeader(
      radius: radius,
      child: SafeArea(
        bottom: false,
        child: ColoredBox(
          color: context.backgroundColor,
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}
