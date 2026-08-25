// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ts_driver/app/core/gen/fonts.gen.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Light theme — kept byte-for-byte equivalent to the app's original
/// `appTheme`, with only the responsive [AppTypography] text theme added.
/// `useMaterial3` is intentionally left unset to preserve the current look.
abstract final class LightTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColorsLight.mainColor,
          onPrimary: Colors.white,
          secondary: AppColorsLight.mainColor,
          onSecondary: Colors.white,
          error: AppColorsLight.mainColor,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: kScaffoldBackroundColor,
        secondaryHeaderColor: kMainTextColor,
        primaryColor: kMainColor,
        primaryColorDark: kMainColorDark,
        primaryColorLight: kMainColorLight,
        disabledColor: kDisabledColor,
        fontFamily: FontFamily.poppins,
        textTheme: AppTypography.textTheme,
        cardColor: AppColors.lightCard,
        // Under M3 `Card` ignores the scalar `cardColor` and paints
        // `colorScheme.surface` + an elevation tint; pin it to our token (with
        // the tint off) so real Cards match `context.cardColor`.
        cardTheme: const CardThemeData(
          color: AppColors.lightCard,
          surfaceTintColor: Colors.transparent,
        ),
        hintColor: kLightTextColor,
        indicatorColor: kMainColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 13,
            color: Color(0xffa0a0a0),
          ),
          labelStyle: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 13,
            color: Color(0xffa0a0a0),
          ),
          alignLabelWithHint: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kMainColor,
            ),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffa0a0a0),
            ),
          ),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(color: kMainColor),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE9EBF0),
        ),
        appBarTheme: const AppBarTheme(
          actionsIconTheme: IconThemeData(color: Colors.green),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColorsLight.mainColor,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      );
}
