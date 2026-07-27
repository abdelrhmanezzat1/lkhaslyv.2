import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A dropdown field that matches the design system input style.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.isEnabled = true,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fillColor = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;
    final Color textColor = isDark ? AppColors.onSurface : AppColors.onLightSurface;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      style: AppTypography.textTheme.bodyLarge?.copyWith(color: textColor),
      dropdownColor: isDark ? AppColors.surface : AppColors.lightSurface,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: const OutlineInputBorder(borderRadius: AppRadius.inputRadius, borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(borderRadius: AppRadius.inputRadius, borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(borderRadius: AppRadius.inputRadius, borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        disabledBorder: const OutlineInputBorder(borderRadius: AppRadius.inputRadius, borderSide: BorderSide.none),
      ),
    );
  }
}
