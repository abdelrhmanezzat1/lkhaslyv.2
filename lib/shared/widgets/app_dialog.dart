import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable dialog widget that adapts to the application design system.
///
/// Supports confirmation dialogs, alert dialogs, and custom content
/// with configurable title, message, and actions.
class AppDialog {
  AppDialog._();

  /// Shows a confirmation dialog with accept and cancel buttons.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String acceptLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(
            title,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
            ),
          ),
          content: Text(
            message,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelLabel,
                style: AppTypography.buttonTextStyle.copyWith(
                  color: isDark
                      ? AppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onLightSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                acceptLabel,
                style: AppTypography.buttonTextStyle.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows an alert dialog with a single dismiss button.
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String dismissLabel = 'OK',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
          title: Text(
            title,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
            ),
          ),
          content: Text(
            message,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                dismissLabel,
                style: AppTypography.buttonTextStyle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a custom dialog with fully customizable content.
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
}
