import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable loading indicator widget that adapts to the application design system.
///
/// Supports both full-screen overlay and inline loading states
/// with an optional message.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 32.0,
    this.strokeWidth = 3.0,
    this.color,
    this.message,
    this.isOverlay = false,
  });

  /// The diameter of the circular indicator.
  final double size;

  /// The width of the circular indicator's line.
  final double strokeWidth;

  /// The color of the progress indicator.
  final Color? color;

  /// Optional text displayed below the loader.
  final String? message;

  /// Whether to show as a full-screen overlay.
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color indicatorColor = color ?? AppColors.primary;

    final Widget loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (!isOverlay) {
      return Center(child: loader);
    }

    return Container(
      color: isDark
          ? AppColors.background.withValues(alpha: 0.85)
          : AppColors.lightBackground.withValues(alpha: 0.85),
      child: Center(child: loader),
    );
  }
}
