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

  // ── Monochrome / Metallic Silver Palette ─────────────────────────────────────
  static const Color background = Color(0xFF141414);
  static const Color surface = Color(0xFF282828);
  static const Color surfaceVariant = Color(0xFF3A3A3A);
  static const Color border = Color(0xFF646464);
  static const Color silverMedium = Color(0xFFA0A0A0);
  static const Color silverLight = Color(0xFFC8C8C8);
  static const Color nearWhite = Color(0xFFF0F0F0);

  // ── Semantic Color Aliases (mapped to monochrome palette) ────────────────────
  static const Color primary = silverMedium;
  static const Color primaryContainer = silverLight;
  static const Color onPrimary = background;
  static const Color onPrimaryContainer = background;

  static const Color secondary = silverMedium;
  static const Color secondaryContainer = silverLight;
  static const Color onSecondary = background;
  static const Color onSecondaryContainer = background;

  // ── Surface & Background ─────────────────────────────────────────────────────
  static const Color onSurface = nearWhite;
  static const Color onSurfaceVariant = silverMedium;
  static const Color onBackground = nearWhite;

  // ── Status Colors (kept for semantic meaning, mapped to monochrome where appropriate) ─────
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

  // ── Divider / Outline ────────────────────────────────────────────────────────
  static const Color divider = border;
  static const Color dividerDark = border;
  static const Color outline = border;

  // ── Glass / Overlay ──────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x33141414);
  static const Color scrim = Color(0x99000000);

  // ── Legacy aliases for backward compatibility ────────────────────────────────
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightSurfaceVariant = surfaceVariant;
  static const Color onLightSurface = onSurface;
  static const Color onLightSurfaceVariant = onSurfaceVariant;
  static const Color onLightBackground = onBackground;
  static const Color secondaryText = onSurfaceVariant;
  static const Color lightSecondaryText = onSurfaceVariant;
}
