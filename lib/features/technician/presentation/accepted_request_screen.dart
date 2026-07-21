import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_empty_state.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';

final _acceptedRequestsProvider = StreamProvider.autoDispose<
    List<TechnicianRequest>>((ref) {
  final repository = ref.watch(technicianRepositoryProvider);

  return repository.requestsStream.map(
    (requests) => requests
        .where((request) =>
            request.status.isActive && request.status != JobStatus.pending)
        .toList(),
  );
});

/// Screen displaying accepted service requests for technicians.
class AcceptedRequestsScreen extends ConsumerWidget {
  const AcceptedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(_acceptedRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accepted Requests')),
      body: requestsAsync.when(
        data: (acceptedRequests) {
          if (acceptedRequests.isEmpty) {
            return const AppEmptyState(
              icon: Icons.work_outline,
              title: 'No Active Jobs',
              message: 'Accept a request to start working.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: acceptedRequests.length,
            itemBuilder: (context, index) {
              final request = acceptedRequests[index];
              return _AcceptedRequestCard(request: request);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _AcceptedRequestCard extends StatelessWidget {
  const _AcceptedRequestCard({required this.request});

  final TechnicianRequest request;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () {
          context.push(AppRoutes.liveStatus, extra: request.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.serviceType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Customer info
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  request.customerName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Vehicle info
            Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${request.vehicleName} - ${request.vehiclePlate}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Distance
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${request.distanceKm} km away',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Action button
            AppButton(
              onPressed: () {
                context.push(AppRoutes.liveStatus, extra: request.id);
              },
              text: 'View Job',
              variant: AppButtonVariant.filled,
            ),
          ],
        ),
      ),
    );
  }
}
