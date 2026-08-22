import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/settings/controllers/locale_controller.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/shared/widgets/app_brand_logo.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocale = ref.watch(localeControllerProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language switcher at top
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: PopupMenuButton<Locale>(
                      icon: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (locale) {
                        ref.read(localeControllerProvider.notifier).setLocale(locale);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: const Locale('en'),
                          child: Row(
                            children: [
                              Icon(
                                !isArabic ? Icons.check : Icons.translate_rounded,
                                size: 18,
                                color: !isArabic ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('English'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('ar'),
                          child: Row(
                            children: [
                              Icon(
                                isArabic ? Icons.check : Icons.translate_rounded,
                                size: 18,
                                color: isArabic ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('العربية'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Brand logo
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const AppBrandLogoBadge(
                    size: 120,
                    borderRadius: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Welcome Text
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.welcomeToApp,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Description
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.onboardingDescription,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // CTA Button
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AppButton(
                      onPressed: () {
                        StorageService.setBool(
                          StorageKeys.hasSeenOnboarding,
                          true,
                        );
                        context.go(AppRoutes.login);
                      },
                      text: AppLocalizations.of(context)!.getStarted,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
