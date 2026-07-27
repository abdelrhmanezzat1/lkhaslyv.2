import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_motion.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A floating ETA / info card used over maps.
class AppMapCard extends StatelessWidget {
  const AppMapCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.subtitle,
    this.onTap,
    this.accentColor,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = accentColor ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.cardRadius,
            boxShadow: AppShadows.floatingFor(context),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.buttonRadius,
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.onLightSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: accent),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
