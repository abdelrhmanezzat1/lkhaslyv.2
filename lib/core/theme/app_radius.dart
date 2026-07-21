import 'package:flutter/material.dart';

/// Defines consistent border radius values for the application.
///
/// Contributes to the "Rounded Cards" and overall premium aesthetic.
class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;

  static const BorderRadiusGeometry borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadiusGeometry borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadiusGeometry borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
}
