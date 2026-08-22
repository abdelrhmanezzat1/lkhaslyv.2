import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Defines consistent, extremely soft shadow styles for the application.
///
/// Modern, premium elevation — no heavy shadows. Shadows use low opacity
/// and generous blur radii to create a subtle, expensive feel.
class AppShadows {
  AppShadows._();

  // ── Light Theme Shadows ───────────────────────────────────────────────────

  /// Level 0 — no elevation. Used for flat surfaces.
  static const List<BoxShadow> none = [];

  /// Level 1 — subtle elevation for cards resting on the background.
  static List<BoxShadow> subtleLight = [
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.03),
      offset: const Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Level 2 — for elevated cards, dialogs, and popovers.
  static List<BoxShadow> elevatedLight = [
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.05),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -1,
    ),
  ];

  /// Level 3 — for floating elements (FAB, bottom sheets, app bars).
  static List<BoxShadow> floatingLight = [
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: AppColors.onLightSurface.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // ── Dark Theme Shadows ────────────────────────────────────────────────────

  /// Level 1 — subtle elevation for cards resting on the background.
  static List<BoxShadow> subtleDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.20),
      offset: const Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Level 2 — for elevated cards, dialogs, and popovers.
  static List<BoxShadow> elevatedDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.40),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -1,
    ),
  ];

  /// Level 3 — for floating elements (FAB, bottom sheets, app bars).
  static List<BoxShadow> floatingDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.50),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // ── Theme-aware Helpers ───────────────────────────────────────────────────

  /// Returns the subtle shadow appropriate for the current theme.
  static List<BoxShadow> subtleFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? subtleDark
        : subtleLight;
  }

  /// Returns the elevated shadow appropriate for the current theme.
  static List<BoxShadow> elevatedFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? elevatedDark
        : elevatedLight;
  }

  /// Returns the floating shadow appropriate for the current theme.
  static List<BoxShadow> floatingFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? floatingDark
        : floatingLight;
  }

  // ── Legacy Aliases (backward compatibility) ──────────────────────────────
  static List<BoxShadow> get subtle => subtleLight;
  static List<BoxShadow> get elevated => elevatedLight;
}
