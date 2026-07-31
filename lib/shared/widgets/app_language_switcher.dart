import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/settings/controllers/locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A compact language switcher widget that opens a bottom sheet with
/// English / العربية options.
///
/// Uses the shared [localeControllerProvider] so changing language in any
/// location immediately updates the entire app.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({
    super.key,
    this.compact = false,
    this.iconSize = 20,
  });

  /// When true, renders as a small icon button (for app bars).
  /// When false, renders as a labeled tile (for profile/settings screens).
  final bool compact;

  /// Icon size for the compact variant.
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;

    if (compact) {
      return IconButton(
        icon: Icon(
          Icons.translate_rounded,
          size: iconSize,
          color: colorScheme.onSurface,
        ),
        tooltip: isArabic ? 'English' : 'العربية',
        onPressed: () => _showLanguageSheet(context, ref, currentLocale),
      );
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.translate_rounded,
          color: colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        isArabic ? 'English' : 'العربية',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        isArabic ? 'Switch to English' : 'التبديل إلى العربية',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isArabic ? 'English' : 'العربية',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      onTap: () => _showLanguageSheet(context, ref, currentLocale),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    final isArabic = currentLocale.languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Language',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                _LanguageOption(
                  label: 'English',
                  isSelected: !isArabic,
                  onTap: () {
                    ref.read(localeControllerProvider.notifier).setLocale(
                      const Locale('en'),
                    );
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: 8),
                _LanguageOption(
                  label: 'العربية',
                  isSelected: isArabic,
                  onTap: () {
                    ref.read(localeControllerProvider.notifier).setLocale(
                      const Locale('ar'),
                    );
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}