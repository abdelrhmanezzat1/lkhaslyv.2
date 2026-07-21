import 'package:flutter/material.dart';

/// Defines consistent spacing values for the application.
///
/// These values help maintain a harmonious layout and visual hierarchy.
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Convenience methods for common padding/margin
  static const EdgeInsetsGeometry paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsetsGeometry paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsetsGeometry paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsetsGeometry paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  // Add more as needed
}
