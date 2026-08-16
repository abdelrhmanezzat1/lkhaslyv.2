import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';

// Phase 3.3: the Provider that used to live here has been moved to
// `lib/core/di/service_locator_provider.dart` (see
// `technicianRepositoryProvider`). Feature code imports it from there so
// there is exactly one source of truth for DI.

/// Abstract repository for the technician module.
/// Provides local-only data with no backend dependency.
abstract class TechnicianRepository {
  Technician getTechnicianProfile();
  Future<void> loadTechnicianProfile(String userId);
  void setTechnicianProfile(Technician technician);
  Future<void> toggleOnline();

  /// Fetches pending (unassigned) orders from Supabase and populates the
  /// local pending-requests list. Returns the fetched list.
  Future<List<TechnicianRequest>> fetchPendingRequests();

  /// Fetches accepted orders assigned to the current technician from Supabase
  /// and populates the local accepted/active lists. Returns the fetched list.
  Future<List<TechnicianRequest>> fetchAcceptedRequests();

  List<TechnicianRequest> getPendingRequests();
  List<TechnicianRequest> getAcceptedRequests();
  List<TechnicianRequest> getActiveRequests();
  List<TechnicianRequest> getCompletedRequests();
  Stream<List<TechnicianRequest>> get requestsStream;

  /// Looks up a request by [id] from the in-memory cached lists
  /// (accepted, active, pending, completed). Returns null if not found.
  TechnicianRequest? getRequestById(String id);

  Future<void> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId);

  Future<void> updateRequestStatus(String requestId, JobStatus newStatus);
  ServiceProgress getProgress(String requestId);

  Future<void> finishJob(String requestId, String notes, double amount);

  Future<void> completeOrderAfterPayment(String requestId);

  Future<Map<String, dynamic>?> getOrderById(String orderId);

  int get pendingCount;
  int get acceptedCount;
  int get completedCount;
}
