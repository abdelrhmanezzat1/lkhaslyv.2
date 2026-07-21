import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [TechnicianRepository].
class TechnicianRepositoryImpl implements TechnicianRepository {
  final SupabaseClient _supabaseClient;
  final Technician _technician;
  final List<TechnicianRequest> _requests = [];
  final Map<String, ServiceProgress> _progressMap = {};
  final StreamController<List<TechnicianRequest>> _ordersController =
      StreamController.broadcast();
  // ignore: unused_field
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;
  StreamSubscription<Position>? _positionSubscription;
  List<TechnicianRequest>? _lastEmittedRequests;

  TechnicianRepositoryImpl()
      : _supabaseClient = Supabase.instance.client,
        _technician = Technician(
          id: Supabase.instance.client.auth.currentUser?.id ?? '',
          name: Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] as String? ?? 'Technician',
          email: Supabase.instance.client.auth.currentUser?.email ?? '',
          phone: Supabase.instance.client.auth.currentUser?.userMetadata?['phone'] as String? ?? '',
          rating: 4.5,
          completedJobs: 0,
          isOnline: true,
        ) {
    _subscribeToOrders();
  }

  String get _technicianId => Supabase.instance.client.auth.currentUser?.id ?? '';

  void _subscribeToOrders() {
    try {
      _ordersSubscription = _supabaseClient
          .from('orders')
          .stream(primaryKey: ['id'])
          .listen((_) {
        _refreshOrders();
      });
    } catch (_) {
      // If realtime subscription fails, continue with manual refreshing.
    }
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select('*, car_info:cars(*)')
          .or('technician_id.is.null,technician_id.eq.$_technicianId')
          .order('created_at', ascending: false);

      if (response is! List) {
        _emitOrders();
        return;
      }

      final parsedRequests = <TechnicianRequest>[];
      for (final raw in response) {
        if (raw is! Map<String, dynamic>) continue;
        final parsed = _parseOrder(raw);
        if (parsed != null) parsedRequests.add(parsed);
      }

      _requests
        ..clear()
        ..addAll(parsedRequests);
      _emitOrders();
    } catch (e, stackTrace) {
      print('[TECH_REPO] _refreshOrders failed: $e');
      print('[TECH_REPO] $stackTrace');
      _emitOrders();
    }
  }

  void _emitOrders() {
    if (!_ordersController.isClosed) {
      final list = List<TechnicianRequest>.of(_requests);
      _lastEmittedRequests = list;
      _ordersController.add(list);
      print("STREAM EMIT");
      print(_requests.length);
      for (final r in _requests) {
        print("${r.id} ${r.status}");
      }
    }
  }

  TechnicianRequest? _parseOrder(Map<String, dynamic> order) {
    try {
      final carInfo = order['car_info'];
      String vehicleName = '';
      String vehiclePlate = '';

      if (carInfo is Map) {
        final map = Map<String, dynamic>.from(carInfo as Map);
        final carType = (map['car_type'] as Object?)?.toString() ?? '';
        final carModel = (map['car_model'] as Object?)?.toString() ?? '';
        vehicleName = [carType, carModel].where((part) => part.isNotEmpty).join(' ').trim();
        vehiclePlate = (map['plate_number'] as Object?)?.toString() ?? '';
      }

      return TechnicianRequest(
        id: (order['id'] as Object?)?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: (order['customer_name'] as Object?)?.toString() ?? '',
        customerPhone: (order['customer_phone'] as Object?)?.toString() ?? '',
        serviceType: (order['service_type'] as Object?)?.toString() ?? '',
        vehicleName: vehicleName,
        vehiclePlate: vehiclePlate,
        description: (order['description'] as Object?)?.toString() ?? '',
        distanceKm: (order['distance'] as num?)?.toDouble() ?? 0,
        requestTime: DateTime.tryParse((order['created_at'] as Object?)?.toString() ?? '') ?? DateTime.now(),
        latitude: (order['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (order['longitude'] as num?)?.toDouble() ?? 0,
        status: JobStatusExtension.fromString((order['status'] as Object?)?.toString() ?? 'pending'),
      );
    } catch (e, stackTrace) {
      print('[TECH_REPO] _parseOrder failed: $e');
      print(stackTrace);
      return null;
    }
  }

  @override
  Technician getTechnicianProfile() => _technician;

  @override
  void toggleOnline() {
    _technician.isOnline = !_technician.isOnline;
    if (!_technician.isOnline) {
      _stopLocationUpdates();
    }
    _updateTechnicianProfileInDb();
  }

  void _stopLocationUpdates() {
    // Only stop if no other jobs in accepted/driving status exist (these need tracking)
    final hasOtherTrackedJobs = _requests.any((r) => 
      r.status == JobStatus.accepted || r.status == JobStatus.driving
    );
    if (!hasOtherTrackedJobs) {
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }
  }

  Future<void> _startLocationUpdates() async {
    // Note: Caller must check _positionSubscription == null before invoking
    // to prevent duplicate subscriptions.

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 15,
      ),
    ).listen((position) {
      // Update technician current location in profiles for realtime tracking
      unawaited(_supabaseClient.from('profiles').update({
        'current_lat': position.latitude,
        'current_lng': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _technicianId));
    });
  }

  Future<void> _updateTechnicianProfileInDb() async {
    await _supabaseClient.from('profiles').update({
      'is_online': _technician.isOnline,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', _technicianId);

    if (_technician.isOnline && _positionSubscription == null) {
      _startLocationUpdates();
    }
  }

  @override
  List<TechnicianRequest> getPendingRequests() {
    return _requests.where((r) => r.status == JobStatus.pending).toList()
      ..sort((a, b) => b.requestTime.compareTo(a.requestTime));
  }

  @override
  Stream<List<TechnicianRequest>> get requestsStream {
    return Stream<List<TechnicianRequest>>.multi((controller) {
      if (_lastEmittedRequests != null) {
        controller.add(_lastEmittedRequests!);
      }
      final subscription = _ordersController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = () => subscription.cancel();
    });
  }

  /// Provides a realtime stream of pending orders for technicians.
  Stream<List<TechnicianRequest>> get pendingOrdersStream => requestsStream;

  @override
  List<TechnicianRequest> getAcceptedRequests() {
    return _requests
        .where((r) => r.status.isActive && r.status != JobStatus.pending)
        .toList()
      ..sort((a, b) => b.requestTime.compareTo(a.requestTime));
  }

  @override
  List<TechnicianRequest> getActiveRequests() {
    return _requests.where((r) => r.status.isActive).toList()
      ..sort((a, b) => b.requestTime.compareTo(a.requestTime));
  }

  @override
  List<TechnicianRequest> getCompletedRequests() {
    return _requests.where((r) => r.status == JobStatus.completed).toList()
      ..sort((a, b) => b.requestTime.compareTo(a.requestTime));
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final request = _find(requestId);
    if (request != null && request.status == JobStatus.pending) {
      print('[DEBUG acceptRequest] BEFORE UPDATE: requestId=$requestId technicianId=$_technicianId');
      // Select row BEFORE UPDATE
      try {
        final before = await _supabaseClient
            .from('orders')
            .select('id,status,technician_id,accepted_at')
            .eq('id', requestId)
            .maybeSingle();
        print('[DEBUG acceptRequest] BEFORE UPDATE row: $before');
      } catch (e) {
        print('[DEBUG acceptRequest] BEFORE UPDATE error: $e');
      }
      request.status = JobStatus.accepted;
      _progressMap[requestId] = ServiceProgress(
        requestId: requestId,
        acceptedAt: DateTime.now(),
      );
      _emitOrders();
      final payload = {
        'status': 'accepted',
        'technician_id': _technicianId,
        'technician_name': _technician.name,
        'accepted_at': DateTime.now().toIso8601String(),
      };
      print('[DEBUG acceptRequest] UPDATE payload: $payload');
      try {
        final response = await _supabaseClient
            .from('orders')
            .update(payload)
            .eq('id', requestId);
        print('[DEBUG acceptRequest] UPDATE response: $response');
      } catch (e) {
        print('[DEBUG acceptRequest] UPDATE error: $e');
      }
      // Select row AFTER UPDATE
      try {
        final after = await _supabaseClient
            .from('orders')
            .select('id,status,technician_id,accepted_at')
            .eq('id', requestId)
            .maybeSingle();
        print('[DEBUG acceptRequest] AFTER UPDATE row: $after');
      } catch (e) {
        print('[DEBUG acceptRequest] AFTER UPDATE error: $e');
      }
      // Start location updates for technician tracking if not already running
      if (_positionSubscription == null) {
        unawaited(_startLocationUpdates());
      }
    }
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    final request = _find(requestId);
    if (request != null && request.status == JobStatus.pending) {
      request.status = JobStatus.rejected;
      _emitOrders();
      unawaited(_supabaseClient.from('orders').update({
        'status': 'cancelled',
      }).eq('id', requestId).catchError((e) {
        print('[TECH_REPO] rejectRequest Supabase update failed: $e');
      }));
    }
  }

  @override
  void updateRequestStatus(String requestId, JobStatus newStatus) {
    final request = _find(requestId);
    if (request == null || !request.status.isActive) return;

    request.status = newStatus;
    final progress = _progressMap.putIfAbsent(
      requestId,
      () => ServiceProgress(requestId: requestId, acceptedAt: DateTime.now()),
    );
    final now = DateTime.now();

    switch (newStatus) {
        case JobStatus.driving:
          progress.drivingAt = now;
          _emitOrders();
          if (_positionSubscription == null) {
            unawaited(_startLocationUpdates());
          }
          unawaited(_supabaseClient.from('orders').update({
            'status': JobStatus.driving.dbValue,
            'driving_at': now.toIso8601String(),
          }).eq('id', requestId).catchError((e) {
            print('[TECH_REPO] updateRequestStatus(driving) Supabase update failed: $e');
          }));
          break;
        case JobStatus.arrived:
          progress.arrivedAt = now;
          _emitOrders();
          _stopLocationUpdates();
          unawaited(_supabaseClient.from('orders').update({
            'status': JobStatus.arrived.dbValue,
            'arrived_at': now.toIso8601String(),
          }).eq('id', requestId).catchError((e) {
            print('[TECH_REPO] updateRequestStatus(arrived) Supabase update failed: $e');
          }));
          break;
        case JobStatus.working:
          progress.workingAt = now;
          _emitOrders();
          unawaited(_supabaseClient.from('orders').update({
            'status': JobStatus.working.dbValue,
            'working_at': now.toIso8601String(),
          }).eq('id', requestId).catchError((e) {
            print('[TECH_REPO] updateRequestStatus(working) Supabase update failed: $e');
          }));
          break;
        case JobStatus.finished:
          progress.finishedAt = now;
          _emitOrders();
          _stopLocationUpdates();
          unawaited(_supabaseClient.from('orders').update({
            'status': JobStatus.finished.dbValue,
            'finished_at': now.toIso8601String(),
          }).eq('id', requestId).catchError((e) {
            print('[TECH_REPO] updateRequestStatus(finished) Supabase update failed: $e');
          }));
          break;
        case JobStatus.completed:
          progress.completedAt = now;
          _technician.completedJobs++;
          _emitOrders();
          _stopLocationUpdates();
          unawaited(_supabaseClient.from('orders').update({
            'status': JobStatus.completed.dbValue,
            'completed_at': now.toIso8601String(),
          }).eq('id', requestId).catchError((e) {
            print('[TECH_REPO] updateRequestStatus(completed) Supabase update failed: $e');
          }));
          break;
      default:
        break;
    }
  }

  @override
  ServiceProgress getProgress(String requestId) {
    return _progressMap[requestId] ??
        ServiceProgress(requestId: requestId, acceptedAt: DateTime.now());
  }

  @override
  void finishJob(String requestId, String notes, double amount) {
    final request = _find(requestId);
    if (request == null) return;

    request.status = JobStatus.finished;
    final progress = _progressMap.putIfAbsent(
      requestId,
      () => ServiceProgress(requestId: requestId, acceptedAt: DateTime.now()),
    );
    progress.notes = notes;
    progress.totalAmount = amount;
    progress.finishedAt = DateTime.now();

    unawaited(_supabaseClient.from('orders').update({
      'status': JobStatus.finished.dbValue,
      'notes': notes,
      'total_amount': amount,
      'finished_at': progress.finishedAt!.toIso8601String(),
    }).eq('id', requestId));
  }

  @override
  int get pendingCount =>
      _requests.where((r) => r.status == JobStatus.pending).length;

  @override
  int get acceptedCount => _requests
      .where((r) => r.status.isActive && r.status != JobStatus.pending)
      .length;

  @override
  int get completedCount =>
      _requests.where((r) => r.status == JobStatus.completed).length;

  TechnicianRequest? _find(String requestId) {
    try {
      return _requests.firstWhere((r) => r.id == requestId);
    } catch (_) {
      return null;
    }
  }
}