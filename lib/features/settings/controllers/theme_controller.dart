import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that manages the app's theme mode (light / dark / system).
///
/// Defaults to [ThemeMode.system] on first launch (respecting the device
/// setting). The user's manual override is persisted via [StorageService]
/// so it survives app restarts.
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(_initialTheme());

  static ThemeMode _initialTheme() {
    final saved = StorageService.getString(StorageKeys.appTheme);
    if (saved != null && saved.isNotEmpty) {
      switch (saved) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
      }
    }
    // Default to system (respect device setting).
    return ThemeMode.system;
  }

  /// Sets the theme mode and persists the choice.
  void setTheme(ThemeMode themeMode) {
    String value;
    switch (themeMode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    StorageService.setString(StorageKeys.appTheme, value);
    state = themeMode;
  }
}
