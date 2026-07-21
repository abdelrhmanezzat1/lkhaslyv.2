import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_empty_state.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

final _completedJobsProvider = StreamProvider.autoDispose<
    List<TechnicianRequest>>((ref) {
  final repository = ref.watch(technicianRepositoryProvider);
  return repository.requestsStream.map(
    (requests) => requests
        .where((request) => request.status == JobStatus.completed)
        .toList(),
  );
});

/// Screen displaying completed jobs history.
class CompletedJobsScreen extends ConsumerWidget {
  const CompletedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedJobsAsync = ref.watch(_completedJobsProvider);

    return completedJobsAsync.when(
      data: (completedJobs) {
        if (completedJobs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Completed Jobs')),
            body: const AppEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No Completed Jobs',
              message: 'Your finished jobs will appear here.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Completed Jobs')),
          body: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: completedJobs.length,
            itemBuilder: (context, index) {
              final job = completedJobs[index];
              return _CompletedJobCard(job: job);
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Completed Jobs')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _CompletedJobCard extends StatelessWidget {
  const _CompletedJobCard({required this.job});

  final TechnicianRequest job;

  @override
  Widget build(BuildContext context) {
    final repository = ProviderScope.containerOf(context).read(technicianRepositoryProvider);
    final progress = repository.getProgress(job.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(job.requestTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Customer and service
            Text(
              job.customerName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Service type
            Text(
              job.serviceType,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Vehicle
            Text(
              '${job.vehicleName} - ${job.vehiclePlate}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.md),

            // Price and notes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '${progress.totalAmount?.toStringAsFixed(2) ?? '0.00'} EGP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            if (progress.notes != null && progress.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Notes: ${progress.notes}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
