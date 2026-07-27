import 'package:flutter/animation.dart';

/// The animation / motion system for the application.
///
/// Premium micro-interactions only. Durations are kept short (150–250ms)
/// and never exceed 300ms (except splash which may use [elasticOut]).
///
/// Curves:
/// - [easeOutCubic]    — incoming elements (fade/slide in)
/// - [easeInOutCubic] — symmetric transitions (shared axis)
/// - [fastOutSlowIn]  — standard Material motion
/// - [elasticOut]     — splash / hero entrance ONLY
class AppMotion {
  AppMotion._();

  // ── Durations ──────────────────────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration emphasized = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration splash = Duration(milliseconds: 600);

  // ── Curves ────────────────────────────────────────────────────────────────
  /// Incoming elements — decelerating motion.
  static const Curve easeOutCubic = Cubic(0.33, 1, 0.68, 1);

  /// Symmetric transitions — accelerate then decelerate.
  static const Curve easeInOutCubic = Cubic(0.65, 0, 0.35, 1);

  /// Standard Material emphasized motion.
  static const Curve fastOutSlowIn = Cubic(0.4, 0, 0.2, 1);

  /// Linear motion — use sparingly (e.g. progress).
  static const Curve linear = Curves.linear;

  /// Elastic entrance — splash / hero ONLY.
  static const Curve elasticOut = Cubic(0.34, 1.56, 0.64, 1);

  // ── Shared Axis Transitions ────────────────────────────────────────────────
  /// Shared axis X — horizontal navigation (forward/back).
  static const Curve sharedAxisX = easeInOutCubic;

  /// Shared axis Y — vertical navigation (up/down).
  static const Curve sharedAxisY = easeInOutCubic;

  /// Shared axis Z — scale navigation (in/out).
  static const Curve sharedAxisZ = easeInOutCubic;

  // ── Offsets (for slide transitions) ────────────────────────────────────────
  static const Offset offsetRightIn = Offset(0.08, 0);
  static const Offset offsetLeftIn = Offset(-0.08, 0);
  static const Offset offsetBottomIn = Offset(0, 0.08);
  static const Offset offsetTopIn = Offset(0, -0.08);
}
