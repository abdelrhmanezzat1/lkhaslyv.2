import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_motion.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// An order card inspired by Airbnb's listing cards.
class AppOrderCard extends StatelessWidget {
  const AppOrderCard({
    super.key,
    required this.orderId,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.statusLabel,
    this.onTap,
    this.trailing,
    this.imageUrl,
  });

  final String orderId;
  final String title;
  final String subtitle;
  final String price;
  final String statusLabel;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: AnimatedScale(
          scale: onTap != null ? 0.99 : 1.0,
          duration: AppMotion.quick,
          curve: AppMotion.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.subtleFor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                    child: Image.network(
                      imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 140,
                        color: AppColors.surfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.textTheme.titleSmall?.copyWith(
                                color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: AppRadius.buttonRadius,
                            ),
                            child: Text(
                              statusLabel,
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.onLightSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Text(
                            price,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          ?trailing,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}"" 
