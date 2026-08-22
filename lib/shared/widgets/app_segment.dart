import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_motion.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A segmented control with animated selection.
class AppSegment<T> extends StatelessWidget {
  const AppSegment({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<AppSegmentItem<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color trackColor = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: AppRadius.buttonRadius,
      ),
      child: Row(
        children: segments.map((seg) {
          final isSelected = seg.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(seg.value),
              child: AnimatedContainer(
                duration: AppMotion.standard,
                curve: AppMotion.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.buttonRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  seg.label,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : (isDark ? AppColors.onSurfaceVariant : AppColors.onLightSurfaceVariant),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppSegmentItem<T> {
  const AppSegmentItem({required this.value, required this.label});
  final T value;
  final String label;
}
