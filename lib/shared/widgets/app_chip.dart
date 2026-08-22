import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable chip widget that adapts to the application design system.
///
/// Supports optional leading avatar/icon, delete button, tap handler,
/// and configurable color variants.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.avatar,
    this.icon,
    this.onTap,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.variant = AppChipVariant.filled,
    this.isSelected = false,
  });

  /// The text displayed on the chip.
  final String label;

  /// An optional circular avatar displayed before the label.
  final Widget? avatar;

  /// An optional icon displayed before the label.
  final IconData? icon;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Called when the chip's delete button is pressed. When provided, a delete
  /// icon is shown.
  final VoidCallback? onDeleted;

  /// Background color of the chip.
  final Color? backgroundColor;

  /// Text color of the chip.
  final Color? textColor;

  /// The visual variant.
  final AppChipVariant variant;

  /// Whether the chip is in a selected state.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        backgroundColor ??
        (isSelected
            ? AppColors.primary
            : (isDark ? AppColors.surface : AppColors.lightSurface));
    final Color fgColor =
        textColor ??
        (isSelected
            ? (isDark ? AppColors.onPrimary : Colors.white)
            : (isDark ? AppColors.onSurface : AppColors.onLightSurface));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: variant == AppChipVariant.outlined
              ? Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.onSurface.withValues(alpha: 0.3)
                            : AppColors.onLightSurface.withValues(alpha: 0.3)),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              avatar!,
              const SizedBox(width: AppSpacing.xs),
            ],
            if (icon != null) ...[
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: fgColor,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close, size: 16, color: fgColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Visual variants for [AppChip].
enum AppChipVariant { filled, outlined }
