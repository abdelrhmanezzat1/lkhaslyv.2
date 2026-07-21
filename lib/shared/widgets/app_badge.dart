import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable badge widget that adapts to the application design system.
///
/// Supports configurable color, text, and positioning variants
/// for use as status indicators, notifications, or labels.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.size = AppBadgeSize.medium,
    this.variant = AppBadgeVariant.filled,
  });

  /// The text displayed inside the badge.
  final String label;

  /// Background color of the badge.
  final Color? backgroundColor;

  /// Text color of the badge.
  final Color? textColor;

  /// The size variant of the badge.
  final AppBadgeSize size;

  /// The visual variant of the badge.
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        backgroundColor ?? (isDark ? AppColors.primary : AppColors.primary);
    final Color fgColor =
        textColor ?? (isDark ? AppColors.onPrimary : Colors.white);

    final EdgeInsetsGeometry padding = _paddingForSize(size);
    final TextStyle textStyle = _textStyleForSize(size, fgColor);

    if (variant == AppBadgeVariant.outlined) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderRadiusSm,
          border: Border.all(color: bgColor, width: 1),
        ),
        child: Text(label, style: textStyle.copyWith(color: bgColor)),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(label, style: textStyle),
    );
  }

  EdgeInsetsGeometry _paddingForSize(AppBadgeSize size) {
    switch (size) {
      case AppBadgeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        );
      case AppBadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case AppBadgeSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
    }
  }

  TextStyle _textStyleForSize(AppBadgeSize size, Color fgColor) {
    switch (size) {
      case AppBadgeSize.small:
        return AppTypography.textTheme.labelSmall?.copyWith(color: fgColor) ??
            TextStyle(color: fgColor);
      case AppBadgeSize.medium:
        return AppTypography.textTheme.labelMedium?.copyWith(color: fgColor) ??
            TextStyle(color: fgColor);
      case AppBadgeSize.large:
        return AppTypography.textTheme.labelLarge?.copyWith(color: fgColor) ??
            TextStyle(color: fgColor);
    }
  }
}

/// Size variants for [AppBadge].
enum AppBadgeSize { small, medium, large }

/// Visual variants for [AppBadge].
enum AppBadgeVariant { filled, outlined }
