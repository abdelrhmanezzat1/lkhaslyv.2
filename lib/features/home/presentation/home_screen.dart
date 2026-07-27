import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/home/presentation/widgets/home_greeting_bar.dart';
import 'package:flutter_application_1/shared/widgets/app_app_bar.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/fade_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateChangesProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        AppSnackbar.showError(
          context,
          message: 'Logout failed: ${state.error}',
        );
      }
    });

    final authControllerState = ref.watch(authControllerProvider);
    final isLoggingOut = authControllerState is AsyncLoading;

    final serviceCategories = [
      _ServiceCategory(
        title: 'Mechanical',
        icon: Icons.build_rounded,
        color: const Color(0xFFFF7043),
        serviceType: 'Mechanical',
      ),
      _ServiceCategory(
        title: 'Electrical',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFFCA28),
        serviceType: 'Electrical',
      ),
      _ServiceCategory(
        title: 'Diagnostics',
        icon: Icons.bug_report_rounded,
        color: const Color(0xFF42A5F5),
        serviceType: 'Diagnostics',
      ),
      _ServiceCategory(
        title: 'Spare Parts',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF66BB6A),
        serviceType: 'Spare Parts',
      ),
    ];

    return Scaffold(
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.person_rounded),
          onPressed: () {
            context.push(AppRoutes.profile);
          },
          tooltip: 'Profile',
        ),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () {
              context.push(AppRoutes.orders);
            },
            tooltip: 'My Orders',
          ),
          if (isLoggingOut)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: AppLoader(size: 20),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in.'));
          }

          final fullName = user.userMetadata?['full_name'] as String? ?? 'User';
          final email = user.email ?? 'No email';

          return FadeIn(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: HomeGreetingBar(
                      userName: fullName,
                      onAvatarTap: () {
                        context.push(AppRoutes.profile);
                      },
                      hasUnreadNotifications: true,
                      onNotificationTap: () {
                        AppSnackbar.showSuccess(
                          context,
                          message: 'Notifications coming soon.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'What service do you need?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Service Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: 1.15,
                          ),
                      itemCount: serviceCategories.length,
                      itemBuilder: (context, index) {
                        final category = serviceCategories[index];
                        return AnimatedScale(
                          scale: 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AppCard(
                            onTap: () {
                              context.push(
                                AppRoutes.serviceRequest,
                                extra: category.serviceType,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  category.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Welcome Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.waving_hand_rounded,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Welcome, $fullName!',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ServiceCategory {

  _ServiceCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.serviceType,
  });
  final String title;
  final IconData icon;
  final Color color;
  final String serviceType;
}
