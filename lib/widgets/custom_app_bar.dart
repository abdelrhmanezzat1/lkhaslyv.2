import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A custom AppBar widget that displays the app logo and supports
/// optional title and actions for each screen.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.titleSpacing,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.logoHeight = 36,
  });

  /// The primary content displayed in the app bar, typically a [Text] widget.
  final Widget? title;

  /// A widget to display before the title (e.g., back button).
  final Widget? leading;

  /// A list of widgets to display after the title (e.g., action buttons).
  final List<Widget>? actions;

  /// Whether the title should be centered.
  final bool centerTitle;

  /// The spacing around the title content.
  final double? titleSpacing;

  /// Controls whether we should try to imply the leading widget if null.
  final bool automaticallyImplyLeading;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The foreground color of the app bar (icons, text).
  final Color? foregroundColor;

  /// The elevation of the app bar.
  final double elevation;

  /// The height of the logo in logical pixels.
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fgColor =
        foregroundColor ?? (isDark ? AppColors.onSurface : AppColors.onLightSurface);

    // Build the logo widget
    final Widget logo = Image.asset(
      'assets/logo.png',
      height: logoHeight,
      fit: BoxFit.contain,
      color: fgColor,
    );

    // Determine what goes in the leading slot
    Widget? leadingWidget = leading;
    if (leadingWidget == null && automaticallyImplyLeading) {
      // If no leading provided and we should imply one, use the logo
      leadingWidget = logo;
    } else if (leadingWidget == null && !automaticallyImplyLeading) {
      // No leading, no logo in leading
      leadingWidget = null;
    }

    // If we have a leading widget that's not the logo, and we want to show logo,
    // put logo in title position
    final Widget? titleWidget = title;
    final bool showLogoInTitle = leadingWidget != null && leadingWidget != logo;

    return AppBar(
      leading: leadingWidget,
      title: showLogoInTitle ? logo : titleWidget,
      actions: actions,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: false, // We handle this manually
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: fgColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: fgColor),
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        color: fgColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}