import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable bottom sheet widget that adapts to the application design system.
///
/// Supports configurable header with drag handle, title, action,
/// and scrollable content.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.action,
    this.showDragHandle = true,
    this.scrollable = false,
    this.padding,
    required this.children,
  });

  /// An optional title displayed at the top of the sheet.
  final String? title;

  /// An optional action widget displayed next to the title.
  final Widget? action;

  /// Whether to show a drag handle at the top.
  final bool showDragHandle;

  /// Whether the content should be scrollable.
  final bool scrollable;

  /// Internal padding for the sheet content.
  final EdgeInsetsGeometry? padding;

  /// The content of the bottom sheet.
  final List<Widget> children;

  /// Convenience method to show this bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? action,
    bool showDragHandle = true,
    bool scrollable = false,
    EdgeInsetsGeometry? padding,
    required List<Widget> children,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AppBottomSheet(
            title: title,
            action: action,
            showDragHandle: showDragHandle,
            scrollable: scrollable,
            padding: padding,
            children: children,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final Color textColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;

    final Widget content = Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            if (title != null || action != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
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
                    if (action != null) action!,
                  ],
                ),
              ),
            if (scrollable)
              Flexible(child: SingleChildScrollView(child: content))
            else
              content,
          ],
        ),
      ),
    );
  }
}
