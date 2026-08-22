import 'dart:async';

import 'package:flutter/material.dart';
// Phase 3.3: repository providers now live in the central DI bridge.
import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/technician/technician.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that first checks the repository's in-memory cache for the
/// request, then continues listening to the broadcast stream for live updates.
///
/// This avoids the infinite-spinner problem caused by `StreamController.broadcast()`
/// which has no replay — if the stream already emitted before this provider
/// started listening, the old `StreamProvider.family` would hang forever.
///
/// Approach: create a single-subscription `StreamController` that:
///   1. Immediately emits the cached value (if found in memory).
///   2. Subscribes to the broadcast stream and forwards all future events.
///   3. The `StreamProvider` watches this controller's stream.
final _liveRequestProvider = StreamProvider.family<TechnicianRequest?, String>((
  ref,
  requestId,
) {
  appLogger.d('LiveStatusScreen._liveRequestProvider — CREATED for requestId=$requestId');
  final repository = ref.watch(technicianRepositoryProvider);

  // Create a controller whose stream the provider will expose.
  // The [onCancel] callback disposes the broadcast subscription when the
  // provider is disposed (e.g. screen pops).
  StreamController<TechnicianRequest?>? controller;
  StreamSubscription<List<TechnicianRequest>>? broadcastSub;

  controller = StreamController<TechnicianRequest?>(
    onCancel: () {
      appLogger.d('LiveStatusScreen._liveRequestProvider — onCancel for $requestId');
      broadcastSub?.cancel();
      controller?.close();
    },
  );

  // 1. Emit the cached value immediately (if available) so the screen
  //    never hangs on a loading spinner.
  final cached = repository.getRequestById(requestId);
  if (cached != null) {
    appLogger.d('LiveStatusScreen._liveRequestProvider — emitting cached: id=${cached.id} status=${cached.status}');
    controller.add(cached);
  } else {
    appLogger.d('LiveStatusScreen._liveRequestProvider — not in cache, will emit from stream');
  }

  // 2. Subscribe to the broadcast stream for live updates.
  broadcastSub = repository.requestsStream.listen((requests) {
    appLogger.d('LiveStatusScreen._liveRequestProvider — stream emitted ${requests.length} requests');
    try {
      final found = requests.firstWhere((request) => request.id == requestId);
      appLogger.d('LiveStatusScreen._liveRequestProvider — found in stream: id=${found.id} status=${found.status}');
      if (!controller!.isClosed) controller.add(found);
    } catch (_) {
      appLogger.w('LiveStatusScreen._liveRequestProvider — request $requestId NOT FOUND in stream data');
      // Fall back to cache in case the stream doesn't include it yet.
      final fallback = repository.getRequestById(requestId);
      if (fallback != null && !controller!.isClosed) {
        controller.add(fallback);
      }
    }
  });

  return controller.stream;
});

/// Screen displaying live status progress of an accepted job.
///
/// While a job is active, the technician's live location is written to
/// `profiles.current_lat/current_lng` every few seconds so the client's
/// tracking map can show a moving marker.
class LiveStatusScreen extends ConsumerStatefulWidget {
  const LiveStatusScreen({super.key, required this.requestId});
  final String requestId;

  @override
  ConsumerState<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends ConsumerState<LiveStatusScreen> {
  String get requestId => widget.requestId;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationSharing();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  /// Shares the technician's live position while a job is in progress.
  void _startLocationSharing() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final repository = ref.read(technicianRepositoryProvider);
        final request = repository.getRequestById(requestId);
        if (request == null) return;
        if (request.status == JobStatus.finished ||
            request.status == JobStatus.completed ||
            request.status == JobStatus.rejected) {
          return;
        }
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (!mounted) return;
        await ref
            .read(technicianLocationRepositoryProvider)
            .updateLocation(
              technicianId: user.id,
              latitude: position.latitude,
              longitude: position.longitude,
            );
      } catch (e) {
        // Location disabled or permission denied — non-fatal.
        appLogger.w('Failed to share live location: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appLogger.d('LiveStatusScreen.build() — requestId=$requestId, watching provider...');
    final requestAsync = ref.watch(_liveRequestProvider(requestId));
    appLogger.d('LiveStatusScreen.build() — provider state: ${requestAsync.isLoading ? "loading" : requestAsync.hasError ? "error: ${requestAsync.error}" : "data"}');

    return requestAsync.when(
      data: (request) {
        appLogger.d('LiveStatusScreen.build() — DATA branch, request=${request?.id} status=${request?.status}');
        if (request == null) {
          appLogger.w('LiveStatusScreen.build() — request is null (not found in stream)');
          return const Scaffold(
            appBar: CustomAppBar(title: Text('Job Not Found')),
            body: Center(child: Text('Job not found')),
          );
        }

        final repository = ref.watch(technicianRepositoryProvider);
        ServiceProgress progress;
        try {
          progress = repository.getProgress(request.id);
          appLogger.d('LiveStatusScreen.build() — progress found for ${request.id}');
        } catch (e) {
          appLogger.w('LiveStatusScreen.build() — getProgress failed: $e');
          progress = ServiceProgress(requestId: request.id, acceptedAt: DateTime.now());
        }

        return Scaffold(
          appBar: const CustomAppBar(title: Text('Live Status')),
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
                    appLogger.d('LiveStatusScreen — Navigate button pressed, pushing to map with lat=${request.latitude} lng=${request.longitude}');
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
                      appLogger.d('LiveStatusScreen — Start Driving pressed for ${request.id}');
                      repository.updateRequestStatus(
                        request.id,
                        JobStatus.driving,
                      );
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
                      appLogger.d('LiveStatusScreen — Mark Arrived pressed for ${request.id}');
                      repository.updateRequestStatus(
                        request.id,
                        JobStatus.arrived,
                      );
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
                      appLogger.d('LiveStatusScreen — Start Working pressed for ${request.id}');
                      repository.updateRequestStatus(
                        request.id,
                        JobStatus.working,
                      );
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
                      appLogger.d('LiveStatusScreen — Finish Job pressed for ${request.id}');
                      context.push(AppRoutes.finishJob, extra: FinishJobExtra(request.id));
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
      loading: () {
        appLogger.d('LiveStatusScreen.build() — LOADING branch (spinner shown)');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (error, stack) {
        appLogger.e('LiveStatusScreen.build() — ERROR branch: $error');
        return Scaffold(
          appBar: const CustomAppBar(title: Text('Live Status')),
          body: Center(child: Text('Error: $error')),
        );
      },
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
        color: isActive
            ? AppColors.success
            : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }
}
