import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';

/// A premium dark metallic AppBar used across the application.
///
/// Provides a consistent metallic gradient surface with optional leading
/// widget, title, and action buttons.
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.centerTitle,
    this.titleSpacing,
  });

  /// A widget to display before the title (typically a back button or avatar).
  final Widget? leading;

  /// The primary content displayed in the app bar.
  final Widget? title;

  /// A list of widgets to display after the title.
  final List<Widget>? actions;

  /// Whether the title should be centered.
  final bool? centerTitle;

  /// The spacing around the title.
  final double? titleSpacing;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
              : const [Color(0xFFF2F2F7), Color(0xFFE5E5EA)],
        ),
        boxShadow: AppShadows.elevated,
      ),
      child: AppBar(
        leading: leading,
        title: title,
        actions: actions,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
