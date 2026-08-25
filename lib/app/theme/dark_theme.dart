// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ts_driver/app/core/gen/fonts.gen.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Dark theme — mirrors [LightTheme]'s structure with [AppColorsDark] values.
/// The brand red is kept for primary/status-bar chrome (the app's red header
/// reads well in both modes). `useMaterial3` is left unset to match light.
abstract final class DarkTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: kMainColor,
          onPrimary: Colors.white,
          secondary: kMainColor,
          onSecondary: Colors.white,
          error: kMainColor,
          onError: Colors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        secondaryHeaderColor: AppColors.darkTextPrimary,
        primaryColor: kMainColor,
        primaryColorDark: kMainColorDark,
        primaryColorLight: kMainColorLight,
        disabledColor: kDisabledColor,
        fontFamily: FontFamily.poppins,
        textTheme: AppTypography.textTheme,
        cardColor: AppColors.darkCard,
        cardTheme: const CardThemeData(
          color: AppColors.darkCard,
          surfaceTintColor: Colors.transparent,
        ),
        hintColor: AppColors.darkHint,
        indicatorColor: kMainColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 13,
            color: AppColors.darkHint,
          ),
          labelStyle: TextStyle(
            fontFamily: FontFamily.poppins,
            fontSize: 13,
            color: AppColors.darkHint,
          ),
          alignLabelWithHint: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kMainColor,
            ),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.darkDivider,
            ),
          ),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(color: kMainColor),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
        ),
        appBarTheme: const AppBarTheme(
          actionsIconTheme: IconThemeData(color: Colors.green),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: kMainColor,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      );
}
