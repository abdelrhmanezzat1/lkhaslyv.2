import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/technician/controllers/technician_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_badge.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Technician home screen displaying online/offline status and statistics.
class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technician = ref.watch(technicianControllerProvider);
    final controller = ref.read(technicianControllerProvider.notifier);
    final authControllerState = ref.watch(authControllerProvider);
    final isLoggingOut = authControllerState is AsyncLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: Text(
          'Technician',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (isLoggingOut)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.logout_rounded, color: colorScheme.onSurface),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight + 8),
              // Premium Status Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _PremiumStatusCard(
                  isOnline: technician.isOnline,
                  onToggle: controller.toggleOnline,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Today's Statistics Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Today's Statistics",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Statistics Grid
              _AnimatedStatsGrid(
                pendingCount: controller.pendingCount,
                acceptedCount: controller.acceptedCount,
                completedCount: controller.completedCount,
                rating: technician.rating,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              Row(
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Action Cards
              _AnimatedActionCard(
                index: 0,
                icon: Icons.inbox_rounded,
                iconColor: colorScheme.primary,
                title: 'Incoming Requests',
                subtitle: 'New service requests from customers',
                badgeCount: controller.pendingCount,
                badgeColor: colorScheme.primary,
                onTap: () => context.push(AppRoutes.incomingRequests),
              ),
              const SizedBox(height: AppSpacing.sm),

              _AnimatedActionCard(
                index: 1,
                icon: Icons.work_rounded,
                iconColor: technician.isOnline
                    ? colorScheme.primary
                    : colorScheme.outline,
                title: 'Accepted Requests',
                subtitle: 'Your active service jobs',
                badgeCount: controller.acceptedCount,
                badgeColor: colorScheme.primary,
                isEnabled: technician.isOnline,
                onTap: () => context.push(AppRoutes.acceptedRequests),
              ),
              const SizedBox(height: AppSpacing.sm),

              _AnimatedActionCard(
                index: 2,
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.success,
                title: 'Completed Jobs',
                subtitle: 'History of finished services',
                badgeCount: controller.completedCount,
                badgeColor: AppColors.success,
                onTap: () => context.push(AppRoutes.completedJobs),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  const _PremiumStatusCard({required this.isOnline, required this.onToggle});

  final bool isOnline;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isOnline ? AppColors.success : AppColors.error;

    return AppCard(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withValues(alpha: 0.12),
              statusColor.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Status Indicator
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.3),
                    statusColor.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 32,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 20),
            // Status Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOnline
                        ? 'Receiving new service requests'
                        : 'Tap to go online and receive requests',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle Switch
            Transform.scale(
              scale: 1.2,
              child: Switch.adaptive(
                value: isOnline,
                onChanged: (_) async {
                  try {
                    await onToggle();
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackbar.showError(context, message: e.toString());
                    }
                  }
                },
                activeTrackColor: statusColor.withValues(alpha: 0.5),
                activeThumbColor: statusColor,
                inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.3),
                inactiveThumbColor: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatsGrid extends StatelessWidget {
  const _AnimatedStatsGrid({
    required this.pendingCount,
    required this.acceptedCount,
    required this.completedCount,
    required this.rating,
  });

  final int pendingCount;
  final int acceptedCount;
  final int completedCount;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final stats = [
      _StatData(
        label: 'Pending',
        count: pendingCount,
        color: const Color(0xFFFFA726),
        icon: Icons.access_time_rounded,
        index: 0,
      ),
      _StatData(
        label: 'Accepted',
        count: acceptedCount,
        color: colorScheme.primary,
        icon: Icons.check_circle_rounded,
        index: 1,
      ),
      _StatData(
        label: 'Completed',
        count: completedCount,
        color: AppColors.success,
        icon: Icons.verified_rounded,
        index: 2,
      ),
      _StatData(
        label: 'Rating',
        count: rating.toInt(),
        color: Colors.amber,
        icon: Icons.star_rounded,
        isRating: true,
        index: 3,
      ),
    ];

    return Column(
      children: [
        Row(
          children: stats.take(2).map((stat) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: stat.index == 0 ? AppSpacing.md : 0,
                  left: stat.index == 1 ? AppSpacing.md : 0,
                ),
                child: _PremiumStatCard(stat: stat),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: stats.skip(2).map((stat) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: stat.index == 2 ? AppSpacing.md : 0,
                  left: stat.index == 3 ? AppSpacing.md : 0,
                ),
                child: _PremiumStatCard(stat: stat),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.index,
    this.isRating = false,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final int index;
  final bool isRating;
}

class _PremiumStatCard extends StatelessWidget {
  const _PremiumStatCard({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (stat.index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: AppCard(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat.icon, size: 20, color: stat.color),
                ),
                const Spacer(),
                if (stat.isRating)
                  Icon(Icons.star_rounded, size: 18, color: stat.color),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stat.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  stat.isRating ? '${stat.count} ★' : '${stat.count}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: stat.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedActionCard extends StatelessWidget {
  const _AnimatedActionCard({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
    this.isEnabled = true,
  });

  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;
  final Color? badgeColor;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBadgeColor = badgeColor ?? colorScheme.primary;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: AppCard(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isEnabled ? null : colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.2),
                      iconColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? iconColor : colorScheme.outline,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0)
                AppBadge(
                  label: badgeCount > 99 ? '99+' : '$badgeCount',
                  backgroundColor: effectiveBadgeColor,
                  size: AppBadgeSize.medium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
