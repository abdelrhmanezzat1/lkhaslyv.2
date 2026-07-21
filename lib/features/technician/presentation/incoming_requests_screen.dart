
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/technician/controllers/requests_controller.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_empty_state.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Screen displaying incoming service requests for technicians.
class IncomingRequestsScreen extends ConsumerWidget {
  const IncomingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Requests')),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No Incoming Requests',
              message: 'New service requests will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(
                request: request,
                onAccept: () => _acceptRequest(context, ref, request.id),
                onReject: () => _rejectRequest(context, ref, request.id),
              );
            },
          );
        },
        loading: () => const AppLoader(message: 'Loading requests...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _acceptRequest(
      BuildContext context, WidgetRef ref, String requestId) async {
    try {
      await ref.read(requestsControllerProvider.notifier).acceptRequest(requestId);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, message: 'Request accepted');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, message: 'Failed to accept: $e');
      }
    }
  }

  Future<void> _rejectRequest(
      BuildContext context, WidgetRef ref, String requestId) async {
    await ref.read(requestsControllerProvider.notifier).rejectRequest(requestId);
    if (context.mounted) {
      AppSnackbar.showInfo(context, message: 'Request rejected');
    }
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final TechnicianRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  String _formatRequestTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service type and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.serviceType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatRequestTime(request.requestTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Customer name
            Text(
              request.customerName,
              style: Theme.of(context).textTheme.bodyLarge,
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
                Expanded(
                  child: Text(
                    '${request.vehicleName} - ${request.vehiclePlate}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                Expanded(
                  child: Text(
                    '${request.distanceKm} km away',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Description
            if (request.description.isNotEmpty)
              Text(
                request.description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: onReject,
                    text: 'Reject',
                    variant: AppButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    onPressed: onAccept,
                    text: 'Accept',
                    variant: AppButtonVariant.filled,
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
