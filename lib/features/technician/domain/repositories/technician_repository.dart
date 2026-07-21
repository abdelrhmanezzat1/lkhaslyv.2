import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';

final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  return sl<TechnicianRepository>();
});

/// Abstract repository for the technician module.
/// Provides local-only data with no backend dependency.
abstract class TechnicianRepository {
  Technician getTechnicianProfile();
  void toggleOnline();

  List<TechnicianRequest> getPendingRequests();
  List<TechnicianRequest> getAcceptedRequests();
  List<TechnicianRequest> getActiveRequests();
  List<TechnicianRequest> getCompletedRequests();
  Stream<List<TechnicianRequest>> get requestsStream;

  Future<void> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId);

  void updateRequestStatus(String requestId, JobStatus newStatus);
  ServiceProgress getProgress(String requestId);

  void finishJob(String requestId, String notes, double amount);

  int get pendingCount;
  int get acceptedCount;
  int get completedCount;
}
