import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';

/// A reusable card widget that adapts to the application design system.
///
/// Supports optional tap handler, configurable padding, margin,
/// background color, border radius, and shadows.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
  });

  /// The content inside the card.
  final Widget? child;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Internal padding of the card.
  final EdgeInsetsGeometry? padding;

  /// External margin of the card.
  final EdgeInsetsGeometry? margin;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Border radius of the card.
  final BorderRadiusGeometry? borderRadius;

  /// Box shadows applied to the card.
  final List<BoxShadow>? shadows;

  /// Optional fixed width.
  final double? width;

  /// Optional fixed height.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        backgroundColor ??
        (isDark ? AppColors.surface : AppColors.lightSurface);

    final BoxDecoration decoration = BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? AppRadius.borderRadiusLg,
      boxShadow: shadows ?? AppShadows.subtle,
    );

    if (onTap == null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        margin: margin,
        decoration: decoration,
        child: Padding(
          padding: padding ?? AppSpacing.paddingAllMd,
          child: child,
        ),
      );
    }

    return AnimatedScale(
      scale: 0.98,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? AppRadius.borderRadiusLg,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding ?? AppSpacing.paddingAllMd,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
