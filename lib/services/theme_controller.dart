import 'package:flutter/material.dart';

class PlangoThemeController {
  PlangoThemeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => themeMode.value == ThemeMode.dark;

  static void setDarkMode(bool enabled) {
    themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggle() {
    setDarkMode(!isDark);
  }
}
