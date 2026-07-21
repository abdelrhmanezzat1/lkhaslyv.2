import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A utility class for showing consistent snackbars throughout the application.
///
/// Provides static methods for showing error, success, info, and
/// custom snackbars with configurable duration and action buttons.
class AppSnackBar {
  AppSnackBar._();

  /// Shows an error snackbar.
  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      textColor: AppColors.onPrimary,
      icon: Icons.error_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Shows a success snackbar.
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      textColor: AppColors.onSecondary,
      icon: Icons.check_circle_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Shows an informational snackbar.
  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _show(
      context,
      message: message,
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      textColor: isDark ? AppColors.onSurface : AppColors.onLightSurface,
      icon: Icons.info_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Shows a custom snackbar.
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _show(
      context,
      message: message,
      backgroundColor:
          backgroundColor ??
          (isDark ? AppColors.surface : AppColors.lightSurface),
      textColor:
          textColor ??
          (isDark ? AppColors.onSurface : AppColors.onLightSurface),
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: textColor,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}

/// Legacy alias for backward compatibility with existing feature code.
typedef AppSnackbar = AppSnackBar;
