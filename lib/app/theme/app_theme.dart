import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

// Barrel: importing app_theme.dart gives access to the whole theme system.
export 'app_colors.dart';
export 'app_typography.dart';
export 'theme_extensions.dart';
export 'light_theme.dart';
export 'dark_theme.dart';

/// Facade for the app's light/dark [ThemeData].
abstract final class AppTheme {
  static ThemeData? _light;
  static ThemeData? _dark;

  /// Built once lazily (after ScreenUtil init) and reused across rebuilds.
  static ThemeData light() => _light ??= LightTheme.theme;
  static ThemeData dark() => _dark ??= DarkTheme.theme;
}

/// Backward-compatible alias for the previous top-level `appTheme`.
ThemeData get appTheme => AppTheme.light();
