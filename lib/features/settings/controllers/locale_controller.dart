import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that manages the app's active locale.
///
/// On first launch, defaults to the device's system locale if it's 'ar'
/// (Arabic) or 'en' (English), falling back to English otherwise.
/// The user's manual override is persisted via [StorageService] so it
/// survives app restarts.
final localeControllerProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(_initialLocale());

  static Locale _initialLocale() {
    // Check for a persisted user override first.
    final saved = StorageService.getString(StorageKeys.locale);
    if (saved != null && saved.isNotEmpty) {
      return Locale(saved);
    }

    // Fall back to the device system locale.
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (deviceLocale.languageCode == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  /// Switches the app locale to [locale] and persists the choice.
  void setLocale(Locale locale) {
    StorageService.setString(StorageKeys.locale, locale.languageCode);
    state = locale;
  }
}