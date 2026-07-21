import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable text field widget that adapts to the application design system.
///
/// Supports optional prefix/suffix icons, password visibility toggle,
/// validation, and custom keyboard type.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.isEnabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Text that suggests what sort of input the field accepts.
  final String? hintText;

  /// Optional label displayed above the field.
  final String? labelText;

  /// An optional validator function.
  final FormFieldValidator<String>? validator;

  /// Whether to hide the text being edited.
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// An optional icon to display before the text.
  final Widget? prefixIcon;

  /// An optional icon to display after the text.
  final Widget? suffixIcon;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// Whether the field is enabled.
  final bool isEnabled;

  /// The maximum number of lines to show.
  final int? maxLines;

  /// The minimum number of lines to show.
  final int? minLines;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fillColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final Color textColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: isEnabled,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      onChanged: onChanged,
      style: AppTypography.textTheme.bodyLarge?.copyWith(color: textColor),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
