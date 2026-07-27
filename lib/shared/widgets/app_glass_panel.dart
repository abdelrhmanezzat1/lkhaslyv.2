import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';

/// A frosted-glass panel with backdrop blur, used for floating map overlays.
class AppGlassPanel extends StatelessWidget {
  const AppGlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 12,
    this.opacity = 0.6,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDark ? AppColors.glassDark : AppColors.glassLight;

    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.buttonRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          padding: padding ?? AppSpacing.paddingAllMd,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: opacity),
            borderRadius: borderRadius ?? AppRadius.buttonRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
