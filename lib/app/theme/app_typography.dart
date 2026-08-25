import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Poppins-based text theme, sized responsively via flutter_screenutil (`.sp`).
///
/// Built lazily (getter, never top-level `const`) because `.sp` requires
/// ScreenUtil, which is initialized in `main()` before `GetMaterialApp` reads
/// the theme.
///
/// Text **colors are intentionally left unset** so `ThemeData` fills them from
/// the active brightness (dark text on light, light text on dark). The font
/// family (`Poppins`) is applied globally by `ThemeData.fontFamily`.
abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(
            fontSize: 96.sp, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: TextStyle(
            fontSize: 60.sp, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(
            fontSize: 34.sp, fontWeight: FontWeight.w700, letterSpacing: 0.25),
        headlineSmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(
            fontSize: 20.sp, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleMedium: TextStyle(
            fontSize: 18.sp, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16.sp, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14.sp, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12.sp, letterSpacing: 0.4),
        labelLarge: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        labelMedium: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w500, letterSpacing: 1.5),
        labelSmall: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.w500, letterSpacing: 1.5),
      );
}
