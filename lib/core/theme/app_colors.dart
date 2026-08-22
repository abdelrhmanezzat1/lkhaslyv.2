import 'package:flutter/material.dart';

/// A class that holds the monochrome/metallic silver color palette for the application.
///
/// Conforms to the premium design system specification:
/// - Background:      #141414
/// - Surface:         #282828
/// - Border:          #646464
/// - Silver medium:   #A0A0A0
/// - Silver light:    #C8C8C8
/// - Near-white:      #F0F0F0
/// - No accent colors (monochrome palette)
class AppColors {
  AppColors._();

  // ── Dark Mode Palette ────────────────────────────────────────────────────────
  static const Color background = Color(0xFF141414);
  static const Color surface = Color(0xFF282828);
  static const Color surfaceVariant = Color(0xFF3A3A3A);
  static const Color border = Color(0xFF646464);
  static const Color silverMedium = Color(0xFFA0A0A0);
  static const Color silverLight = Color(0xFFC8C8C8);
  static const Color nearWhite = Color(0xFFF0F0F0);

  // ── Light Mode Palette ───────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE8E8E8);
  static const Color lightBorder = Color(0xFFC8C8C8);
  static const Color lightPrimary = Color(0xFF3A3A3A);
  static const Color lightOnPrimary = Color(0xFFF5F5F5);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF6E6E6E);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightPrimaryContainer = Color(0xFFD0D0D0);
  static const Color lightOnPrimaryContainer = Color(0xFF1A1A1A);
  static const Color lightSecondary = Color(0xFF6E6E6E);
  static const Color lightSecondaryContainer = Color(0xFFD0D0D0);
  static const Color lightOnSecondary = Color(0xFFF5F5F5);
  static const Color lightOnSecondaryContainer = Color(0xFF1A1A1A);
  static const Color lightOutline = Color(0xFFC8C8C8);
  static const Color lightErrorContainer = Color(0xFFFCE4E4);
  static const Color lightSuccessContainer = Color(0xFFE4F5E4);

  // ── Semantic Color Aliases (dark mode) ───────────────────────────────────────
  static const Color primary = silverMedium;
  static const Color primaryContainer = silverLight;
  static const Color onPrimary = background;
  static const Color onPrimaryContainer = background;

  static const Color secondary = silverMedium;
  static const Color secondaryContainer = silverLight;
  static const Color onSecondary = background;
  static const Color onSecondaryContainer = background;

  // ── Surface & Background (dark) ──────────────────────────────────────────────
  static const Color onSurface = nearWhite;
  static const Color onSurfaceVariant = silverMedium;
  static const Color onBackground = nearWhite;

  // ── Status Colors ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color onSuccess = Color(0xFF141414);
  static const Color successContainer = Color(0xFF1A3A2A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFF141414);
  static const Color warningContainer = Color(0xFF3A2E1A);

  static const Color danger = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = nearWhite;
  static const Color errorContainer = Color(0xFF3A1A1A);

  // ── Divider / Outline (dark) ─────────────────────────────────────────────────
  static const Color divider = border;
  static const Color dividerDark = border;
  static const Color outline = border;

  // ── Glass / Overlay ──────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x33141414);
  static const Color scrim = Color(0x99000000);

  // ── Legacy aliases (used by shared widgets) ──────────────────────────────────
  static const Color secondaryText = onSurfaceVariant;
  static const Color lightSecondaryText = lightOnSurfaceVariant;
  static const Color onLightSurface = lightOnSurface;
  static const Color onLightSurfaceVariant = lightOnSurfaceVariant;
  static const Color onLightBackground = lightOnBackground;
}
