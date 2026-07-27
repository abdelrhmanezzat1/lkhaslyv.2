import 'package:flutter/material.dart';

/// A class that holds the color palette for the application.
///
/// Conforms to the premium design system specification:
/// - Primary:   #2563EB
/// - Accent:    #14B8A6
/// - Success:   #22C55E
/// - Warning:   #F59E0B
/// - Danger:    #EF4444
/// - Background:#F8FAFC (light) / #020617 (dark)
/// - Surface:   #FFFFFF (light) / #0F172A (dark)
class AppColors {
  AppColors._();

  // ── Brand / Primary Palette ───────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryVariant = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // ── Accent / Secondary Palette ────────────────────────────────────────────
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryVariant = Color(0xFF0F766E);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF134E4A);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color danger = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFEE2E2);

  // ── Neutral Palette (Light Theme) ─────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color onLightBackground = Color(0xFF0F172A);
  static const Color onLightSurface = Color(0xFF0F172A);
  static const Color onLightSurfaceVariant = Color(0xFF475569);

  // ── Neutral Palette (Dark Theme) ──────────────────────────────────────────
  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFF1E293B);
  static const Color onBackground = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  // ── Outline / Divider ─────────────────────────────────────────────────────
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineDark = Color(0xFF334155);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF1E293B);

  // ── Glass / Overlay ────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x66FFFFFF);
  static const Color glassDark = Color(0x660F172A);
  static const Color scrim = Color(0x99000000);

  // ── Legacy / Backward-compatible aliases ───────────────────────────────────
  static const Color accent = primary;
  static const Color text = onSurface;
  static const Color secondaryText = onSurfaceVariant;
  static const Color lightSecondaryText = onLightSurfaceVariant;
}
