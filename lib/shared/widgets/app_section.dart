import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable section widget that adapts to the application design system.
///
/// Provides a consistent layout for grouped content with
/// an optional header, action, and configurable padding.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    this.title,
    this.action,
    this.padding,
    this.spacing = AppSpacing.md,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  /// The optional section title.
  final String? title;

  /// An optional action widget displayed opposite the title (e.g., "See All").
  final Widget? action;

  /// Internal padding for the section.
  final EdgeInsetsGeometry? padding;

  /// The vertical spacing between children.
  final double spacing;

  /// The cross-axis alignment of the children.
  final CrossAxisAlignment crossAxisAlignment;

  /// The widgets displayed in this section.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;

    return Padding(
      padding: padding ?? AppSpacing.paddingAllMd,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || action != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ?action,
              ],
            ),
          if (title != null || action != null) SizedBox(height: spacing),
          ..._spacedChildren(),
        ],
      ),
    );
  }

  List<Widget> _spacedChildren() {
    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }
    return spaced;
  }
}
