import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable AppBar widget that adapts to the application design system.
///
/// Provides a consistent look with optional leading widget, title,
/// action buttons, and a gradient background.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.titleSpacing,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showGradient = true,
    this.bottom,
  });

  /// The primary content displayed in the app bar, typically a [Text] widget.
  final Widget? title;

  /// A widget to display before the title.
  final Widget? leading;

  /// A list of widgets to display after the title.
  final List<Widget>? actions;

  /// Whether the title should be centered.
  final bool? centerTitle;

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

  /// Whether to apply a gradient background.
  final bool showGradient;

  /// A widget to display at the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fgColor =
        foregroundColor ??
        (isDark ? AppColors.onSurface : AppColors.onLightSurface);

    Widget appBar = AppBar(
      leading: leading,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      foregroundColor: fgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      iconTheme: IconThemeData(color: fgColor),
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        color: fgColor,
        fontWeight: FontWeight.w600,
      ),
    );

    if (!showGradient) {
      return Container(color: backgroundColor, child: appBar);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
              : const [Color(0xFFF2F2F7), Color(0xFFE5E5EA)],
        ),
        boxShadow: elevation > 0 ? AppShadows.elevated : null,
        color: backgroundColor,
      ),
      child: appBar,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
