import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'requests_controller.g.dart';

/// Controller for managing incoming and active requests.
@riverpod
class RequestsController extends _$RequestsController {
  @override
  FutureOr<List<TechnicianRequest>> build() {
    return _getRequests();
  }

  Future<List<TechnicianRequest>> _getRequests() async {
    final repository = sl<TechnicianRepository>();
    return repository.getPendingRequests();
  }

  /// Accepts a request by ID.
  Future<void> acceptRequest(String requestId) async {
    final repository = sl<TechnicianRepository>();
    await Future(() => repository.acceptRequest(requestId));
    state = const AsyncLoading();
    state = AsyncData(repository.getPendingRequests());
  }

  /// Rejects a request by ID.
  Future<void> rejectRequest(String requestId) async {
    final repository = sl<TechnicianRepository>();
    repository.rejectRequest(requestId);
    state = const AsyncLoading(); // Trigger loading state
    state = AsyncData(await _getRequests()); // Refresh the list
  }

  /// Refreshes the requests list.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _getRequests());
  }
}
