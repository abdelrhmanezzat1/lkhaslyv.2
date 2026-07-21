import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable search bar widget that adapts to the application design system.
///
/// Supports text input, clear button, filter/sort actions, and
/// configurable hint text with a search icon.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.hintText = 'Search...',
    this.isReadOnly = false,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.padding,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Called when the user taps the clear button.
  final VoidCallback? onClear;

  /// Called when the user taps the filter button.
  final VoidCallback? onFilterTap;

  /// Text that suggests what sort of input the field accepts.
  final String hintText;

  /// Whether the search field is read-only (delegates to onTap).
  final bool isReadOnly;

  /// Called when the field is tapped, useful for read-only mode.
  final VoidCallback? onTap;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Whether this text field should focus itself if nothing else is
  /// already focused.
  final bool autofocus;

  /// External padding for the search bar.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final Color textColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;
    final Color iconColor = textColor.withValues(alpha: 0.6);
    final bool hasText = controller != null && controller!.text.isNotEmpty;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Icon(Icons.search, color: iconColor, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onTap: onTap,
                readOnly: isReadOnly,
                focusNode: focusNode,
                autofocus: autofocus,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  isDense: true,
                ),
              ),
            ),
            if (hasText)
              GestureDetector(
                onTap: () {
                  controller?.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.close, color: iconColor, size: 18),
                ),
              ),
            if (onFilterTap != null)
              GestureDetector(
                onTap: onFilterTap,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.md,
                    left: AppSpacing.xs,
                  ),
                  child: Icon(Icons.tune, color: iconColor, size: 20),
                ),
              )
            else
              const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
