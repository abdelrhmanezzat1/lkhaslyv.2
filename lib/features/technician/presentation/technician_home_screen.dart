import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/technician/controllers/technician_controller.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_badge.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

/// Technician home screen displaying online/offline status and statistics.
class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technician = ref.watch(technicianControllerProvider);
    final controller = ref.read(technicianControllerProvider.notifier);
    final authControllerState = ref.watch(authControllerProvider);
    final isLoggingOut = authControllerState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician'),
        automaticallyImplyLeading: false,
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online/Offline Switch
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              technician.isOnline ? 'Online' : 'Offline',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: technician.isOnline
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: technician.isOnline,
                        onChanged: (_) {
                          controller.toggleOnline();
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Today's Statistics
            Text(
              "Today's Statistics",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    count: controller.pendingCount,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Accepted',
                    count: controller.acceptedCount,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Completed',
                    count: controller.completedCount,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Rating',
                    count: technician.rating.toInt(),
                    isRating: true,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),

            AppCard(
              onTap: () {
                context.push(AppRoutes.incomingRequests);
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inbox, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incoming Requests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'New service requests from customers',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (controller.pendingCount > 0)
                    AppBadge(
                      label: '${controller.pendingCount}',
                      backgroundColor: AppColors.primary,
                      size: AppBadgeSize.medium,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              onTap: () {
                context.push(AppRoutes.acceptedRequests);
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: technician.isOnline
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work,
                      color: technician.isOnline
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accepted Requests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Your active service jobs',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (controller.acceptedCount > 0)
                    AppBadge(
                      label: '${controller.acceptedCount}',
                      backgroundColor: AppColors.primary,
                      size: AppBadgeSize.medium,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AppCard(
              onTap: () {
                context.push(AppRoutes.completedJobs);
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed Jobs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'History of finished services',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    this.isRating = false,
  });

  final String label;
  final int count;
  final bool isRating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isRating ? '$count ★' : '$count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}