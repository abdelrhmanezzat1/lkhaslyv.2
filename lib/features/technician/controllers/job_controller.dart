import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_controller.g.dart';

/// Controller for managing active job status.
@riverpod
class JobController extends _$JobController {
  @override
  FutureOr<TechnicianRequest?> build(String requestId) async {
    return _getJob(requestId);
  }

  Future<TechnicianRequest?> _getJob(String requestId) async {
    final repository = ref.read(technicianRepositoryProvider);
    try {
      return repository.getAcceptedRequests().firstWhere(
        (r) => r.id == requestId,
      );
    } catch (_) {
      try {
        return repository.getActiveRequests().firstWhere(
          (r) => r.id == requestId,
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Updates the job status.
  Future<void> updateStatus(String requestId, JobStatus newStatus) async {
    final repository = ref.read(technicianRepositoryProvider);
    repository.updateRequestStatus(requestId, newStatus);
    state = const AsyncLoading();
    state = AsyncData(await _getJob(requestId));
  }

  /// Finishes the job with notes and amount.
  Future<void> finishJob(String requestId, String notes, double amount) async {
    final repository = ref.read(technicianRepositoryProvider);
    repository.finishJob(requestId, notes, amount);
    state = const AsyncLoading();
    state = const AsyncData(null);
  }
}

/// Provider for getting the service progress of a job.
final progressProvider = Provider.family<ServiceProgress, String>((
  ref,
  requestId,
) {
  final repository = ref.watch(technicianRepositoryProvider);
  return repository.getProgress(requestId);
});
