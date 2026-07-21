import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/premium_app_bar.dart';
import 'package:flutter_application_1/shared/widgets/fade_in.dart';
import 'package:flutter_application_1/features/home/presentation/widgets/home_greeting_bar.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';

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
        icon: Icons.build,
        color: const Color(0xFFFF7043),
        serviceType: 'Mechanical',
      ),
      _ServiceCategory(
        title: 'Electrical',
        icon: Icons.bolt,
        color: const Color(0xFFFFCA28),
        serviceType: 'Electrical',
      ),
      _ServiceCategory(
        title: 'Diagnostics',
        icon: Icons.bug_report,
        color: const Color(0xFF42A5F5),
        serviceType: 'Diagnostics',
      ),
      _ServiceCategory(
        title: 'Spare Parts',
        icon: Icons.inventory_2,
        color: const Color(0xFF66BB6A),
        serviceType: 'Spare Parts',
      ),
    ];

    return Scaffold(
      appBar: PremiumAppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.push(AppRoutes.profile);
          },
          tooltip: 'Profile',
        ),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
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
              icon: const Icon(Icons.logout),
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
                children: [
                  HomeGreetingBar(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'What service do you need?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                            childAspectRatio: 1.1,
                          ),
                      itemCount: serviceCategories.length,
                      itemBuilder: (context, index) {
                        final category = serviceCategories[index];
                        return AppCard(
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
                                  color: category.color.withValues(alpha: 0.15),
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Welcome, $fullName!',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      email,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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
  final String title;
  final IconData icon;
  final Color color;
  final String serviceType;

  _ServiceCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.serviceType,
  });
}
