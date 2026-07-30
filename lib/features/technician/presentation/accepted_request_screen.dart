import 'package:flutter/material.dart';
// Phase 3.3: repository providers now live in the central DI bridge.
import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/technician/technician.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _acceptedRequestsProvider =
    StreamProvider.autoDispose<List<TechnicianRequest>>((ref) {
      final repository = ref.watch(technicianRepositoryProvider);

      return repository.requestsStream.map(
        (requests) => requests
            .where(
              (request) =>
                  request.status.isActive &&
                  request.status != JobStatus.pending,
            )
            .toList(),
      );
    });

/// Screen displaying accepted service requests for technicians.
class AcceptedRequestsScreen extends ConsumerWidget {
  const AcceptedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(_acceptedRequestsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Accepted Requests',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: requestsAsync.when(
        data: (acceptedRequests) {
          if (acceptedRequests.isEmpty) {
            return _PremiumEmptyState(
              icon: Icons.work_outline_rounded,
              title: 'No Active Jobs',
              message: 'Accept a request to start working on a service job.',
              actionLabel: 'View Incoming',
              onAction: () => context.push(AppRoutes.incomingRequests),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_acceptedRequestsProvider),
            color: colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: acceptedRequests.length,
              itemBuilder: (context, index) {
                final request = acceptedRequests[index];
                return _PremiumAcceptedRequestCard(request: request);
              },
            ),
          );
        },
        loading: () =>
            const Center(child: AppLoader(message: 'Loading jobs...')),
        error: (error, stack) => _PremiumErrorState(
          message: 'Failed to load jobs: $error',
          onRetry: () => ref.invalidate(_acceptedRequestsProvider),
        ),
      ),
    );
  }
}

class _PremiumAcceptedRequestCard extends StatelessWidget {
  const _PremiumAcceptedRequestCard({required this.request});

  final TechnicianRequest request;

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'Mechanical':
        return const Color(0xFFFF7043);
      case 'Electrical':
        return const Color(0xFFFFCA28);
      case 'Diagnostics':
        return const Color(0xFF42A5F5);
      case 'Spare Parts':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'Mechanical':
        return Icons.build_rounded;
      case 'Electrical':
        return Icons.bolt_rounded;
      case 'Diagnostics':
        return Icons.bug_report_rounded;
      case 'Spare Parts':
        return Icons.inventory_2_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return const Color(0xFF42A5F5);
      case JobStatus.driving:
        return const Color(0xFF42A5F5);
      case JobStatus.arrived:
        return const Color(0xFFAB47BC);
      case JobStatus.working:
        return const Color(0xFF5C6BC0);
      case JobStatus.finished:
        return const Color(0xFF26A69A);
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case JobStatus.driving:
        return Icons.directions_car_rounded;
      case JobStatus.arrived:
        return Icons.location_on_rounded;
      case JobStatus.working:
        return Icons.build_rounded;
      case JobStatus.finished:
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final serviceColor = _getServiceColor(request.serviceType);
    final serviceIcon = _getServiceIcon(request.serviceType);
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (request.id.hashCode % 5) * 50),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppCard(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push(AppRoutes.liveStatus, extra: LiveStatusExtra(request.id));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with service type badge and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          serviceColor.withValues(alpha: 0.2),
                          serviceColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: serviceColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(serviceIcon, size: 16, color: serviceColor),
                        const SizedBox(width: 6),
                        Text(
                          request.serviceType,
                          style: TextStyle(
                            color: serviceColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.2),
                          statusColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          request.status.label,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Customer info with avatar
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: serviceColor.withValues(alpha: 0.15),
                    child: Text(
                      request.customerName.isNotEmpty
                          ? request.customerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: serviceColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.customerName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Active Job',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Details Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Vehicle info
                    _DetailRow(
                      icon: Icons.directions_car_rounded,
                      label: 'Vehicle',
                      value: '${request.vehicleName} - ${request.vehiclePlate}',
                      iconColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    // Distance
                    _DetailRow(
                      icon: Icons.straighten_rounded,
                      label: 'Distance',
                      value: '${request.distanceKm} km away',
                      iconColor: Colors.blue,
                    ),
                    if (request.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Description
                      _DetailRow(
                        icon: Icons.description_rounded,
                        label: 'Details',
                        value: request.description,
                        iconColor: Colors.purple,
                        isMultiline: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.liveStatus, extra: LiveStatusExtra(request.id));
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('View Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: serviceColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: serviceColor.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isMultiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: isMultiline ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumEmptyState extends StatelessWidget {
  const _PremiumEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.surfaceContainerHighest,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.work_outline_rounded, size: 20),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumErrorState extends StatelessWidget {
  const _PremiumErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
