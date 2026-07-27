import 'package:flutter/material.dart';

/// Defines consistent border radius values for the application.
///
/// Per the design system specification:
/// - Cards:       24
/// - Buttons:     18
/// - Inputs:      18
/// - Bottom Sheet: 28
/// - Dialogs:     28
class AppRadius {
  AppRadius._();

  // ── Radius Tokens ─────────────────────────────────────────────────────────
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  // ── Semantic Aliases ──────────────────────────────────────────────────────
  /// Cards: 24
  static const double card = 24;

  /// Buttons: 18
  static const double button = 18;

  /// Inputs: 18
  static const double input = 18;

  /// Bottom sheet: 28
  static const double bottomSheet = 28;

  /// Dialogs: 28
  static const double dialog = 28;

  // ── BorderRadiusGeometry Constants ─────────────────────────────────────────
  static const BorderRadiusGeometry borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadiusGeometry borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadiusGeometry borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadiusGeometry borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadiusGeometry borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadiusGeometry borderRadiusXxl = BorderRadius.all(
    Radius.circular(xxl),
  );
  static const BorderRadiusGeometry borderRadiusPill = BorderRadius.all(
    Radius.circular(pill),
  );

  // ── Semantic BorderRadius Constants ───────────────────────────────────────
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(dialog),
  );

  /// Top-only radius for bottom sheets.
  static const BorderRadiusGeometry bottomSheetTopRadius = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
}
