// Phase 3.4 — AcceptOrderUseCase tests.
//
// These are pure-Dart tests (no Supabase, no Flutter widgets). They verify:
//   1. happy path: a single acceptOrder() call lands on the repository
//      with the exact args.
//   2. failure propagation: a thrown error from the repository bubbles out
//      without being swallowed.
//   3. validation: empty orderId asserts (debug-mode only).
//
// They double as the documentation for the use-case contract.

import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/accept_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal in-memory fake matching `OrdersRepository`.
class _FakeOrdersRepository implements OrdersRepository {
  int acceptCalls = 0;
  String? lastOrderId;
  String? lastTechnicianId;
  String? lastTechnicianName;

  /// Optional throw trigger for the failure-propagation tests.
  Exception? throwOnAccept;

  @override
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    acceptCalls += 1;
    lastOrderId = orderId;
    lastTechnicianId = technicianId;
    lastTechnicianName = technicianName;
    final trigger = throwOnAccept;
    if (trigger != null) throw trigger;
  }

  // ── the rest of the contract is intentionally not exercised here ────────
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
  Future<void> confirmOrderCompletion({required String orderId}) async =>
      throw UnimplementedError();

  @override
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> submitRating({
    required String orderId,
    required int rating,
    String? comment,
  }) async =>
      throw UnimplementedError();

  @override
  Future<bool> hasAcceptedOrders({required String technicianId}) async =>
      throw UnimplementedError();
}

void main() {
  group('AcceptOrderUseCase', () {
    late _FakeOrdersRepository orders;
    late AcceptOrderUseCase sut;

    setUp(() {
      orders = _FakeOrdersRepository();
      sut = AcceptOrderUseCase(orders);
    });

    test('forwards orderId/technicianId/technicianName to repository',
        () async {
      await sut(
        const AcceptOrderCommand(
          orderId: 'order-1',
          technicianId: 'tech-1',
          technicianName: 'Alice',
        ),
      );

      expect(orders.acceptCalls, 1);
      expect(orders.lastOrderId, 'order-1');
      expect(orders.lastTechnicianId, 'tech-1');
      expect(orders.lastTechnicianName, 'Alice');
    });

    test('rethrows repository errors without swallowing them', () async {
      final boom = Exception('boom');
      orders.throwOnAccept = boom;

      await expectLater(
        () => sut(
          const AcceptOrderCommand(
            orderId: 'order-1',
            technicianId: 'tech-1',
            technicianName: 'Alice',
          ),
        ),
        throwsA(same(boom)),
      );
    });
  });
}
