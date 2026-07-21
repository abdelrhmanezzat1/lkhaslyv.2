import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

final _liveRequestProvider = StreamProvider.family<
    TechnicianRequest?, String>((ref, requestId) {
  final repository = ref.watch(technicianRepositoryProvider);
  return repository.requestsStream.map(
    (requests) {
      try {
        return requests.firstWhere((request) => request.id == requestId);
      } catch (_) {
        return null;
      }
    },
  );
});

/// Screen displaying live status progress of an accepted job.
class LiveStatusScreen extends ConsumerWidget {
  final String requestId;

  const LiveStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(_liveRequestProvider(requestId));

    return requestAsync.when(
      data: (request) {
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job Not Found')),
            body: const Center(child: Text('Job not found')),
          );
        }

        final repository = ref.watch(technicianRepositoryProvider);
        final progress = repository.getProgress(request.id);

        return Scaffold(
          appBar: AppBar(title: const Text('Live Status')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info
                _InfoSection(
                  title: 'Customer',
                  children: [
                    _InfoRow(icon: Icons.person, label: request.customerName),
                    _InfoRow(icon: Icons.phone, label: request.customerPhone),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Vehicle Info
                _InfoSection(
                  title: 'Vehicle',
                  children: [
                    _InfoRow(
                      icon: Icons.directions_car,
                      label: request.vehicleName,
                    ),
                    _InfoRow(
                      icon: Icons.confirmation_number,
                      label: request.vehiclePlate,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Problem Description
                _InfoSection(
                  title: 'Problem',
                  children: [
                    Text(
                      request.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Progress Timeline
                Text(
                  'Progress',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.md),

                _ProgressTimeline(
                  currentStatus: request.status,
                  progress: progress,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Navigation Button
                AppButton(
                  onPressed: () {
                    context.push(
                      AppRoutes.map,
                      extra: {
                        'navigateCustomer': true,
                        'latitude': request.latitude,
                        'longitude': request.longitude,
                        'customerName': request.customerName,
                      },
                    );
                  },
                  text: 'Navigate',
                  variant: AppButtonVariant.outlined,
                  icon: const Icon(Icons.navigation, size: 18),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Start Service / Finish Job Button
                if (request.status == JobStatus.accepted)
                  AppButton(
                    onPressed: () {
                      repository.updateRequestStatus(request.id, JobStatus.driving);
                      AppSnackbar.showSuccess(
                        context,
                        message: 'Status updated to Driving',
                      );
                    },
                    text: 'Start Driving',
                    variant: AppButtonVariant.filled,
                    icon: const Icon(Icons.directions_car, size: 18),
                  )
                else if (request.status == JobStatus.driving)
                  AppButton(
                    onPressed: () {
                      repository.updateRequestStatus(request.id, JobStatus.arrived);
                      AppSnackbar.showSuccess(
                        context,
                        message: 'Status updated to Arrived',
                      );
                    },
                    text: 'Mark Arrived',
                    variant: AppButtonVariant.filled,
                    icon: const Icon(Icons.location_on, size: 18),
                  )
                else if (request.status == JobStatus.arrived)
                  AppButton(
                    onPressed: () {
                      repository.updateRequestStatus(request.id, JobStatus.working);
                      AppSnackbar.showSuccess(
                        context,
                        message: 'Status updated to Working',
                      );
                    },
                    text: 'Start Working',
                    variant: AppButtonVariant.filled,
                    icon: const Icon(Icons.build, size: 18),
                  )
                else if (request.status == JobStatus.working)
                  AppButton(
                    onPressed: () {
                      context.push(AppRoutes.finishJob, extra: request.id);
                    },
                    text: 'Finish Job',
                    variant: AppButtonVariant.filled,
                    icon: const Icon(Icons.check, size: 18),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Live Status')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(child: Column(children: children)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondaryText),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({
    required this.currentStatus,
    required this.progress,
  });

  final JobStatus currentStatus;
  final ServiceProgress progress;

  List<JobStatus> get _statusSteps => [
    JobStatus.accepted,
    JobStatus.driving,
    JobStatus.arrived,
    JobStatus.working,
    JobStatus.finished,
    JobStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < _statusSteps.length; i++) ...[
            _TimelineStep(
              status: _statusSteps[i],
              isActive: _statusStepIsActive(_statusSteps[i]),
              isCompleted: _statusStepIsCompleted(_statusSteps[i]),
              isFirst: i == 0,
              isLast: i == _statusSteps.length - 1,
            ),
            if (i < _statusSteps.length - 1)
              _TimelineConnector(
                isActive: _statusStepIsCompleted(_statusSteps[i]),
              ),
          ],
        ],
      ),
    );
  }

  bool _statusStepIsActive(JobStatus step) {
    return step.order < currentStatus.order;
  }

  bool _statusStepIsCompleted(JobStatus step) {
    return step.order < currentStatus.order || step == currentStatus;
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.isActive,
    required this.isCompleted,
    required this.isFirst,
    required this.isLast,
  });

  final JobStatus status;
  final bool isActive;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color color = isCompleted
        ? AppColors.success
        : AppColors.secondaryText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle indicator
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? (isActive ? AppColors.success : AppColors.primary)
                : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        // Label
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : AppSpacing.xs,
              bottom: isLast ? 0 : AppSpacing.xs,
            ),
            child: Text(
              status.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 11,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Container(
        width: 2,
        height: 24,
        color: isActive ? AppColors.success : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }
}
