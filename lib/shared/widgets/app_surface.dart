import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';

/// A surface is the most basic elevated container in the design system.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.border,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        backgroundColor ?? (isDark ? AppColors.surface : AppColors.lightSurface);

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        boxShadow: shadows ?? AppShadows.subtleFor(context),
        border: border,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

/// A generic container with theme-aware background and rounded corners.
class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = color ??
        (isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant);

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
        border: border,
      ),
      child: child,
    );
  }
}
