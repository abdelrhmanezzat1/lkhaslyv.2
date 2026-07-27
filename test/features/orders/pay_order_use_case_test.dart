// Phase 3.4 — PayOrderUseCase tests.
//
// These tests pin down the orchestration contract:
//   * orders.payOrder is ALWAYS called first; technician mirror second.
//   * if payOrder throws, the technician mirror is NEVER called.
//   * if the technician mirror throws, the use-case still succeeds (the
//     order is paid, mirror is best-effort UI state).

import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/pay_order_use_case.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/features/technician/models/service_progress.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake OrdersRepository capturing call ordering.
class _FakeOrdersRepository implements OrdersRepository {
  int payCalls = 0;
  Exception? throwOnPay;

  @override
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    payCalls += 1;
    final t = throwOnPay;
    if (t != null) throw t;
  }

  @override
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> confirmOrderCompletion({required String orderId}) async =>
      throw UnimplementedError();

  @override
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<Order>> getClientOrders({required String clientId}) async =>
      throw UnimplementedError();

  @override
  Future<List<Order>> getPendingOrders() async =>
      throw UnimplementedError();

  @override
  Future<bool> hasAcceptedOrders({required String technicianId}) async =>
      throw UnimplementedError();
}

/// Fake TechnicianRepository used to track call ordering.
///
/// Only `completeOrderAfterPayment` is exercised. Everything else throws.
class _FakeTechnicianRepository implements TechnicianRepository {
  int completeCalls = 0;
  String? lastOrderId;
  Exception? throwOnComplete;

  // ── method used by this use-case ─────────────────────────────────────────
  @override
  Future<void> completeOrderAfterPayment(String requestId) async {
    completeCalls += 1;
    lastOrderId = requestId;
    final t = throwOnComplete;
    if (t != null) throw t;
  }

  // ── unused members ───────────────────────────────────────────────────────
  @override
  Technician getTechnicianProfile() => throw UnimplementedError();

  @override
  Future<void> loadTechnicianProfile(String userId) async =>
      throw UnimplementedError();

  @override
  void setTechnicianProfile(Technician technician) =>
      throw UnimplementedError();

  @override
  void toggleOnline() => throw UnimplementedError();

  @override
  List<TechnicianRequest> getPendingRequests() => throw UnimplementedError();

  @override
  List<TechnicianRequest> getAcceptedRequests() => throw UnimplementedError();

  @override
  List<TechnicianRequest> getActiveRequests() => throw UnimplementedError();

  @override
  List<TechnicianRequest> getCompletedRequests() => throw UnimplementedError();

  @override
  Stream<List<TechnicianRequest>> get requestsStream => const Stream.empty();

  @override
  Future<void> acceptRequest(String requestId) async =>
      throw UnimplementedError();

  @override
  Future<void> rejectRequest(String requestId) async =>
      throw UnimplementedError();

  @override
  Future<void> updateRequestStatus(
    String requestId,
    JobStatus newStatus,
  ) async =>
      throw UnimplementedError();

  @override
  ServiceProgress getProgress(String requestId) => throw UnimplementedError();

  @override
  Future<void> finishJob(
    String requestId,
    String notes,
    double amount,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> getOrderById(String orderId) async =>
      throw UnimplementedError();

  @override
  int get pendingCount => 0;

  @override
  int get acceptedCount => 0;

  @override
  int get completedCount => 0;
}

void main() {
  group('PayOrderUseCase', () {
    late _FakeOrdersRepository orders;
    late _FakeTechnicianRepository technicians;
    late PayOrderUseCase sut;

    setUp(() {
      orders = _FakeOrdersRepository();
      technicians = _FakeTechnicianRepository();
      sut = PayOrderUseCase(orders, technicians);
    });

    test('happy path: calls payOrder, then technician mirror', () async {
      await sut(
        const PayOrderCommand(orderId: 'order-1', paymentMethod: 'cash'),
      );

      expect(orders.payCalls, 1);
      expect(technicians.completeCalls, 1);
      expect(technicians.lastOrderId, 'order-1');
    });

    test('skips technician mirror when payOrder throws', () async {
      final boom = Exception('pay failed');
      orders.throwOnPay = boom;

      await expectLater(
        () => sut(
          const PayOrderCommand(orderId: 'order-1', paymentMethod: 'cash'),
        ),
        throwsA(same(boom)),
      );

      expect(orders.payCalls, 1);
      // Critical: mirror is NEVER called if payOrder fails.
      expect(technicians.completeCalls, 0);
    });

    test('does not throw when technician mirror fails (best-effort)', () async {
      technicians.throwOnComplete = Exception('mirror failed');

      // Should NOT throw — mirror is best-effort.
      await sut(
        const PayOrderCommand(orderId: 'order-1', paymentMethod: 'cash'),
      );

      expect(orders.payCalls, 1);
      expect(technicians.completeCalls, 1);
    });
  });
}
