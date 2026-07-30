import 'dart:async';

import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianRepositoryImpl implements TechnicianRepository {

  TechnicianRepositoryImpl();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Local state for technician data
  Technician? _technician;
  bool _isOnline = true;
  final List<TechnicianRequest> _pendingRequests = [];
  final List<TechnicianRequest> _acceptedRequests = [];
  final List<TechnicianRequest> _activeRequests = [];
  final List<TechnicianRequest> _completedRequests = [];
  final Map<String, ServiceProgress> _progressMap = {};
  final _requestsController =
      StreamController<List<TechnicianRequest>>.broadcast();

  @override
  Technician getTechnicianProfile() {
    if (_technician == null) {
      throw Exception('Technician profile not loaded.');
    }
    return _technician!;
  }

  @override
  void setTechnicianProfile(Technician technician) {
    _technician = technician;
  }

  @override
  Future<void> loadTechnicianProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        _technician = Technician(
          id: response['id']?.toString() ?? '',
          name: response['name']?.toString() ?? '',
          email: response['email']?.toString() ?? '',
          phone: response['phone']?.toString() ?? '',
          rating: (response['rating'] as num?)?.toDouble() ?? 4.5,
          completedJobs: (response['completed_jobs'] as int?) ?? 0,
          isOnline: response['is_online'] as bool? ?? true,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void toggleOnline() {
    _isOnline = !_isOnline;
  }

  @override
  List<TechnicianRequest> getPendingRequests() {
    return List.unmodifiable(_pendingRequests);
  }

  @override
  List<TechnicianRequest> getAcceptedRequests() {
    return List.unmodifiable(_acceptedRequests);
  }

  @override
  List<TechnicianRequest> getActiveRequests() {
    return List.unmodifiable(_activeRequests);
  }

  @override
  List<TechnicianRequest> getCompletedRequests() {
    return List.unmodifiable(_completedRequests);
  }

  @override
  Stream<List<TechnicianRequest>> get requestsStream =>
      _requestsController.stream;

  @override
  Future<void> acceptRequest(String requestId) async {
    final order = await _getOrderById(requestId);
    if (order == null) {
      throw Exception('Order $requestId not found.');
    }

    final request = _mapOrderToRequest(order);
    _pendingRequests.removeWhere((r) => r.id == requestId);
    _acceptedRequests.add(request);
    _progressMap[requestId] = ServiceProgress(
      requestId: requestId,
      acceptedAt: DateTime.now(),
    );

    await _updateOrderStatus(requestId, 'accepted');
    _notifyStream();
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    _pendingRequests.removeWhere((r) => r.id == requestId);
    await _updateOrderStatus(requestId, 'rejected');
    _notifyStream();
  }

  @override
  Future<void> updateRequestStatus(
    String requestId,
    JobStatus newStatus,
  ) async {
    final progress = _progressMap[requestId];
    if (progress == null) {
      throw Exception('Progress not found for request $requestId');
    }

    final now = DateTime.now();
    final dbStatus = newStatus.dbValue;

    switch (newStatus) {
      case JobStatus.driving:
        progress.drivingAt = now;
        break;
      case JobStatus.arrived:
        progress.arrivedAt = now;
        break;
      case JobStatus.working:
        progress.workingAt = now;
        break;
      case JobStatus.finished:
      case JobStatus.completed:
        progress.finishedAt = now;
        break;
      default:
        break;
    }

    await _updateOrderStatus(requestId, dbStatus);

    // Move between lists
    _acceptedRequests.removeWhere((r) => r.id == requestId);
    _activeRequests.removeWhere((r) => r.id == requestId);
    _completedRequests.removeWhere((r) => r.id == requestId);

    if (newStatus == JobStatus.completed || newStatus == JobStatus.rejected) {
      _completedRequests.add(
        _progressMap[requestId]!.requestId == requestId
            ? _acceptedRequests.firstWhere(
                (r) => r.id == requestId,
                orElse: () => _pendingRequests.firstWhere(
                  (r) => r.id == requestId,
                  orElse: () => throw Exception('Request not found'),
                ),
              )
            : _activeRequests.firstWhere(
                (r) => r.id == requestId,
                orElse: () => _pendingRequests.firstWhere(
                  (r) => r.id == requestId,
                  orElse: () => throw Exception('Request not found'),
                ),
              ),
      );
      _completedRequests.last.status = newStatus;
    } else {
      _activeRequests.add(
        _acceptedRequests.firstWhere(
          (r) => r.id == requestId,
          orElse: () => _activeRequests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => _pendingRequests.firstWhere(
              (r) => r.id == requestId,
              orElse: () => throw Exception('Request not found'),
            ),
          ),
        ),
      );
      _activeRequests.last.status = newStatus;
    }

    _notifyStream();
  }

  @override
  ServiceProgress getProgress(String requestId) {
    final progress = _progressMap[requestId];
    if (progress == null) {
      throw Exception('Progress not found for request $requestId');
    }
    return progress;
  }

  @override
  Future<void> finishJob(String requestId, String notes, double amount) async {
    final progress = _progressMap[requestId];
    if (progress != null) {
      progress.notes = notes;
      progress.totalAmount = amount;
    }
    await updateRequestStatus(requestId, JobStatus.finished);
  }

  @override
  Future<void> completeOrderAfterPayment(String requestId) async {
    final request = _activeRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => _acceptedRequests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => throw Exception('Request $requestId not found'),
      ),
    );

    _activeRequests.removeWhere((r) => r.id == requestId);
    _acceptedRequests.removeWhere((r) => r.id == requestId);
    _completedRequests.add(request..status = JobStatus.completed);

    await _updateOrderStatus(requestId, 'completed');
    _notifyStream();
  }

  @override
  int get pendingCount => _pendingRequests.length;

  @override
  int get acceptedCount => _acceptedRequests.length;

  @override
  int get completedCount => _completedRequests.length;

  @override
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    return _getOrderById(orderId);
  }

  Future<Map<String, dynamic>?> _getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, car_info:cars(*)')
          .eq('id', orderId)
          .maybeSingle();
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    final payload = <String, dynamic>{'status': status};

    switch (status) {
      case 'on_the_way':
        payload['driving_at'] = DateTime.now().toIso8601String();
        break;
      case 'arrived':
        payload['arrived_at'] = DateTime.now().toIso8601String();
        break;
      case 'working':
        payload['working_at'] = DateTime.now().toIso8601String();
        break;
      case 'finished':
      case 'completed':
        payload['finished_at'] = DateTime.now().toIso8601String();
        break;
      default:
        break;
    }

    await _supabase.from('orders').update(payload).eq('id', orderId);
  }

  TechnicianRequest _mapOrderToRequest(Map<String, dynamic> order) {
    final carInfo = order['car_info'] as Map<String, dynamic>?;
    final carType = carInfo?['car_type']?.toString() ?? '';
    final carModel = carInfo?['car_model']?.toString() ?? '';
    final plateNumber = carInfo?['plate_number']?.toString() ?? '';
    final vehicleName = '$carType $carModel'.trim();
    final latitude = (order['latitude'] as num?)?.toDouble() ?? 0.0;
    final longitude = (order['longitude'] as num?)?.toDouble() ?? 0.0;

    return TechnicianRequest(
      id: order['id']?.toString() ?? '',
      customerName: order['customer_name']?.toString() ?? 'Unknown',
      customerPhone: order['customer_phone']?.toString() ?? '',
      serviceType: order['service_type']?.toString() ?? 'Unknown',
      vehicleName: vehicleName.isEmpty ? 'N/A' : vehicleName,
      vehiclePlate: plateNumber,
      description: order['description']?.toString() ?? '',
      distanceKm: 0,
      requestTime:
          DateTime.tryParse(order['created_at']?.toString() ?? '') ??
          DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      status: JobStatusExtension.fromString(
        order['status']?.toString() ?? 'pending',
      ),
    );
  }

  void _notifyStream() {
    final all = <TechnicianRequest>[
      ..._pendingRequests,
      ..._acceptedRequests,
      ..._activeRequests,
      ..._completedRequests,
    ];
    _requestsController.add(List.unmodifiable(all));
  }
}
