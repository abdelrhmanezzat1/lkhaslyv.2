import 'app_radius.dart';
import 'app_spacing.dart';

/// A legacy compatibility class that holds constant values for spacing,
/// radius, and other layout properties.
///
/// New code should prefer [AppSpacing] and [AppRadius] directly. This class
/// exists to keep existing references compiling during the design-system
/// migration.
class AppDimensions {
  AppDimensions._();

  // ── Spacing (aliases to AppSpacing) ────────────────────────────────────────
  static const double spaceXXS = AppSpacing.xxs;
  static const double spaceXS = AppSpacing.xs;
  static const double spaceS = AppSpacing.sm;
  static const double spaceM = AppSpacing.md;
  static const double spaceL = AppSpacing.xl;
  static const double spaceXL = AppSpacing.xxl;
  static const double spaceXXL = AppSpacing.huge;

  // ── Radius (aliases to AppRadius) ──────────────────────────────────────────
  static const double radiusS = AppRadius.xs;
  static const double radiusM = AppRadius.md;
  static const double radiusL = AppRadius.xl;
  static const double radiusXL = AppRadius.xxl;
  static const double radiusFull = AppRadius.pill;

  // ── Component Sizes ────────────────────────────────────────────────────────
  static const double buttonHeight = 52;
  static const double buttonHeightSm = 44;
  static const double touchTarget = 48;
  static const double appBarHeight = 56;
  static const double bottomBarHeight = 64;
  static const double fabSize = 56;
  static const double fabSizeExtended = 60;
  static const double avatarSizeSm = 32;
  static const double avatarSizeMd = 40;
  static const double avatarSizeLg = 56;
  static const double iconSizeSm = 18;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
}
