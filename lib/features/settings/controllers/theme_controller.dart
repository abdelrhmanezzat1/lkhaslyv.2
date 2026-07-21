import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final isDarkMode = StorageService.getBool(StorageKeys.isDarkMode) ?? true;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode themeMode) {
    StorageService.setBool(StorageKeys.isDarkMode, themeMode == ThemeMode.dark);
    state = themeMode;
  }
}
