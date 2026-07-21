import 'package:flutter/material.dart';

/// A class that holds the color palette for the application.
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Neutral Palette (Dark Theme)
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;

  // Status Colors
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF66BB6A);

  // Light Theme Overrides
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color onLightBackground = Colors.black;
  static const Color onLightSurface = Colors.black;

  // Legacy / Lakhsly aliases
  static const Color accent = primary;
  static const Color text = onSurface;
  static const Color secondaryText = Color(0xFFB0B0B0);
}
