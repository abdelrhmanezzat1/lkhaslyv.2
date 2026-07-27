import 'package:flutter/material.dart';

/// Defines consistent spacing values for the application.
///
/// Strictly follows an 8pt grid with the only allowed values:
/// 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.
class AppSpacing {
  AppSpacing._();

  // ── 8pt Grid Tokens ───────────────────────────────────────────────────────
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // ── Semantic Aliases ──────────────────────────────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // ── Page / Layout Padding ──────────────────────────────────────────────────
  static const double pageHorizontal = 20;
  static const double pageVertical = 16;

  static const EdgeInsetsGeometry pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  // ── Convenience Paddings ────────────────────────────────────────────────────
  static const EdgeInsetsGeometry paddingAllXxs = EdgeInsets.all(xxs);
  static const EdgeInsetsGeometry paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsetsGeometry paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsetsGeometry paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsetsGeometry paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsetsGeometry paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsetsGeometry paddingAllXxl = EdgeInsets.all(xxl);

  static const EdgeInsetsGeometry paddingHorizontalXs = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsetsGeometry paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsetsGeometry paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsetsGeometry paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsetsGeometry paddingHorizontalXl = EdgeInsets.symmetric(
    horizontal: xl,
  );

  static const EdgeInsetsGeometry paddingVerticalXs = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsetsGeometry paddingVerticalSm = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsetsGeometry paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsetsGeometry paddingVerticalLg = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsetsGeometry paddingVerticalXl = EdgeInsets.symmetric(
    vertical: xl,
  );

  static const double iconGap = 8;
  static const double tileGap = 8;
  static const double sectionGap = 24;
}
