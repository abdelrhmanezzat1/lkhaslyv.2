import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable button widget that adapts to the application design system.
///
/// Supports filled, outlined, and text variants, optional icons,
/// loading state, and configurable sizing.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = true,
    this.minimumHeight = 48.0,
    this.padding,
    this.borderRadius,
  });

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// The text displayed on the button.
  final String text;

  /// An optional icon displayed alongside the [text].
  final Widget? icon;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// When true, shows a small loader and disables interaction.
  final bool isLoading;

  /// When true, the button stretches to fill its parent width.
  final bool isExpanded;

  /// The minimum height of the button.
  final double minimumHeight;

  /// Optional override for the inner padding.
  final EdgeInsetsGeometry? padding;

  /// Optional override for the border radius.
  final BorderRadiusGeometry? borderRadius;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Widget child = _buildChild(context, isDark);

    switch (variant) {
      case AppButtonVariant.filled:
        return _FilledButton(
          onPressed: _isDisabled ? null : onPressed,
          isExpanded: isExpanded,
          minimumHeight: minimumHeight,
          padding: padding,
          borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
          child: child,
        );
      case AppButtonVariant.outlined:
        return _OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          isExpanded: isExpanded,
          minimumHeight: minimumHeight,
          padding: padding,
          borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
          child: child,
        );
      case AppButtonVariant.text:
        return _TextButton(
          onPressed: _isDisabled ? null : onPressed,
          isExpanded: isExpanded,
          minimumHeight: minimumHeight,
          padding: padding,
          borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
          child: child,
        );
    }
  }

  Widget _buildChild(BuildContext context, bool isDark) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.filled
                ? (isDark ? AppColors.onPrimary : Colors.white)
                : AppColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: Text(text, style: AppTypography.buttonTextStyle)),
        ],
      );
    }

    return Text(text, style: AppTypography.buttonTextStyle);
  }
}

/// Visual variants for [AppButton].
enum AppButtonVariant {
  /// Solid background filled with primary color.
  filled,

  /// Transparent background with a primary border.
  outlined,

  /// No background or border, just text.
  text,
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.onPressed,
    required this.isExpanded,
    required this.minimumHeight,
    required this.padding,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback? onPressed;
  final bool isExpanded;
  final double minimumHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: AnimatedScale(
        scale: onPressed == null ? 1.0 : 0.97,
        duration: const Duration(milliseconds: 120),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: isDark ? AppColors.onPrimary : Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            disabledForegroundColor:
                (isDark ? AppColors.onPrimary : Colors.white).withValues(
                  alpha: 0.6,
                ),
            minimumSize: Size(isExpanded ? double.infinity : 0, minimumHeight),
            padding: padding ?? AppSpacing.paddingHorizontalMd,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
            textStyle: AppTypography.buttonTextStyle,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.onPressed,
    required this.isExpanded,
    required this.minimumHeight,
    required this.padding,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback? onPressed;
  final bool isExpanded;
  final double minimumHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
          minimumSize: Size(isExpanded ? double.infinity : 0, minimumHeight),
          padding: padding ?? AppSpacing.paddingHorizontalMd,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: AppTypography.buttonTextStyle,
        ),
        child: child,
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.onPressed,
    required this.isExpanded,
    required this.minimumHeight,
    required this.padding,
    required this.borderRadius,
    required this.child,
  });

  final VoidCallback? onPressed;
  final bool isExpanded;
  final double minimumHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(isExpanded ? double.infinity : 0, minimumHeight),
          padding: padding ?? AppSpacing.paddingHorizontalMd,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: AppTypography.buttonTextStyle,
        ),
        child: child,
      ),
    );
  }
}
