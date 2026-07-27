import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_motion.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable list tile with leading, title, subtitle, trailing, and tap animation.
class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.isDense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color titleColor = isDark ? AppColors.onSurface : AppColors.onLightSurface;
    final Color subtitleColor = isDark ? AppColors.onSurfaceVariant : AppColors.onLightSurfaceVariant;
    final BorderRadius br =
        (borderRadius ?? AppRadius.borderRadiusMd).resolve(Directionality.of(context));

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: br,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        child: AnimatedScale(
          scale: onTap != null ? 0.99 : 1.0,
          duration: AppMotion.quick,
          curve: AppMotion.easeOutCubic,
          child: Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: isDense ? AppSpacing.xs : AppSpacing.sm,
                ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppTypography.textTheme.titleSmall?.copyWith(color: titleColor)),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(subtitle!, style: AppTypography.textTheme.bodySmall?.copyWith(color: subtitleColor)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
