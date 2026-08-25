import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../values/constants.dart';
import '../../theme/app_colors.dart';

/// Single source of truth for the app's theme mode.
///
/// Persists the user's choice (`light` | `dark`) to GetStorage and applies it
/// via [Get.changeThemeMode]. Registered as a permanent service and initialized
/// in `main()` so the app opens in the persisted mode.
class ThemeService extends GetxService {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  ThemeMode get mode => themeMode.value;

  /// Reads the persisted choice. Call once at startup before `runApp`.
  Future<ThemeService> init() async {
    themeMode.value = _read();
    _applyStatusBar();
    return this;
  }

  /// Sets and persists an explicit mode, applying it live.
  void setMode(ThemeMode value) {
    themeMode.value = value;
    CommonVariables.settings.write(THEME_MODE, value.name);
    Get.changeThemeMode(value);
    _applyStatusBar();
  }

  /// Flips between light and dark.
  void toggle() =>
      setMode(mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  ThemeMode _read() {
    final saved = CommonVariables.settings.read(THEME_MODE);
    if (saved == ThemeMode.dark.name) return ThemeMode.dark;
    if (saved == ThemeMode.light.name) return ThemeMode.light;
    // Migrate the legacy boolean DARK_MODE flag, if present.
    final legacy = CommonVariables.settings.read(DARK_MODE);
    if (legacy is bool) return legacy ? ThemeMode.dark : ThemeMode.light;
    return ThemeMode.light;
  }

  void _applyStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kMainColor,
      statusBarIconBrightness: Brightness.light,
    ));
  }
}
