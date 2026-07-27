import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_motion.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';
import 'app_avatar.dart';

/// A technician card showing avatar, name, rating, and specialty.
class AppTechnicianCard extends StatefulWidget {
  const AppTechnicianCard({
    super.key,
    required this.name,
    required this.specialty,
    this.rating,
    this.imageUrl,
    this.onTap,
    this.trailing,
    this.isOnline = false,
  });

  final String name;
  final String specialty;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isOnline;

  @override
  State<AppTechnicianCard> createState() => _AppTechnicianCardState();
}

class _AppTechnicianCardState extends State<AppTechnicianCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactive = widget.onTap != null;

    return GestureDetector(
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppMotion.quick,
        curve: AppMotion.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: AppRadius.cardRadius,
                boxShadow: AppShadows.subtleFor(context),
              ),
              child: Row(
                children: [
                  AppAvatar(
                    imageUrl: widget.imageUrl,
                    initials: widget.name.isNotEmpty
                        ? widget.name.split(' ').map((e) => e[0]).take(2).join()
                        : null,
                    radius: 28,
                    showOnlineBadge: true,
                    isOnline: widget.isOnline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.name,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          widget.specialty,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.onSurfaceVariant : AppColors.onLightSurfaceVariant,
                          ),
                        ),
                        if (widget.rating != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(
                                widget.rating!.toStringAsFixed(1),
                                style: AppTypography.textTheme.labelMedium?.copyWith(
                                  color: isDark ? AppColors.onSurface : AppColors.onLightSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
