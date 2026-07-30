// Phase 4.1 — feature-local controller for the Orders vertical.
//
// Replaces the kitchen-sink read/write methods on `RegistrationController`
// (`getClientOrders`, `getPendingOrders`, `createOrder`, `acceptOrder`,
// `confirmOrderCompletion`, `payOrder`). All order persistence is now
// owned by this controller, which in turn defers to the Phase 3.4
// use-cases for the multi-step orchestrations (`AcceptOrderUseCase`,
// `PayOrderUseCase`).
//
// Repositories are sourced from the typed providers in
// `core/di/service_locator_provider.dart` — never `sl<T>()` directly,
// so Phase 7 tests can override the providers with mocks.

import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/accept_order_use_case.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/pay_order_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'orders_controller.g.dart';

@riverpod
class OrdersController extends _$OrdersController {
  @override
  FutureOr<List<Order>> build() => const <Order>[];

  /// Loads orders placed by [clientId] (e.g. active + history for the
  /// client's "My Orders" tab).
  Future<List<Order>> loadClientOrders(String clientId) async {
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();
    final List<Order> result = await AsyncValue.guard(
      () => repository.getClientOrders(clientId: clientId),
    ).then((AsyncValue<List<Order>> value) {
      return value.valueOrNull ?? const <Order>[];
    });
    state = AsyncData<List<Order>>(result);
    return result;
  }

  /// Loads orders still waiting to be claimed by a technician (the
  /// technician-side "Incoming Requests" feed).
  Future<List<Order>> loadPendingOrders() async {
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();
    final List<Order> result = await AsyncValue.guard(
      repository.getPendingOrders,
    ).then((AsyncValue<List<Order>> value) {
      return value.valueOrNull ?? const <Order>[];
    });
    state = AsyncData<List<Order>>(result);
    return result;
  }

  /// Creates a brand-new order for the client. Phase 4.1 keeps the
  /// repository call inline because the creation flow has no
  /// orchestration beyond a single insert.
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) async {
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    // Capture the cached orders before entering AsyncLoading so we can
    // restore them after the insert without accessing `state.value`
    // from inside the async gap (which would be null during loading).
    final previousOrders = state.value ?? const <Order>[];
    state = const AsyncLoading();
    try {
      await repository.createOrder(
        clientId: clientId,
        carId: carId,
        serviceType: serviceType,
        description: description,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );
      state = AsyncData<List<Order>>(previousOrders);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Technician claims a pending order. The contract is locked down via
  /// `AcceptOrderCommand` — see `accept_order_use_case.dart`.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    final AcceptOrderUseCase acceptOrder = ref.read(acceptOrderUseCaseProvider);
    final previousOrders = state.value ?? const <Order>[];
    state = const AsyncLoading();
    try {
      await acceptOrder(
        AcceptOrderCommand(
          orderId: orderId,
          technicianId: technicianId,
          technicianName: technicianName,
        ),
      );
      state = AsyncData<List<Order>>(previousOrders);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Technician marks a job as done — the client is now expected to
  /// confirm + pay.
  Future<void> confirmOrderCompletion({required String orderId}) async {
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    final previousOrders = state.value ?? const <Order>[];
    state = const AsyncLoading();
    try {
      await repository.confirmOrderCompletion(orderId: orderId);
      state = AsyncData<List<Order>>(previousOrders);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Guards against re-entrant calls that would trigger Riverpod's
  /// "Bad state: Future already completed" error when `state` is set
  /// to `AsyncLoading` while a previous future is still resolving.
  bool _isProcessingPayment = false;

  /// Pays an order. The two-repo orchestration
  /// (`orders.payOrder` + `technician.completeOrderAfterPayment`) is
  /// delegated to `pay_order_use_case.dart`, which documents the call
  /// order and establishes the strict-vs-best-effort error contract.
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    // Guard: prevent double-invocation from rapid taps or duplicate
    // call-sites (e.g. optimistic UI + API response handler).
    if (_isProcessingPayment) {
      appLogger.w(
        'OrdersController.payOrder: already processing payment for '
        'order=$orderId — ignoring duplicate call.',
      );
      return;
    }

    final PayOrderUseCase payOrderUseCase = ref.read(payOrderUseCaseProvider);
    final previousOrders = state.value ?? const <Order>[];

    _isProcessingPayment = true;
    state = const AsyncLoading();

    try {
      await payOrderUseCase(
        PayOrderCommand(
          orderId: orderId,
          paymentMethod: paymentMethod,
        ),
      );
      state = AsyncData<List<Order>>(previousOrders);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } finally {
      _isProcessingPayment = false;
    }
  }
}

/// Read-only family provider returning the placed orders for a given
/// client. Phase 4.2 will switch the relevant screens to this read
/// shape instead of the imperative `loadClientOrders(...)` calls.
@riverpod
Future<List<Order>> clientOrdersForUser(
  ClientOrdersForUserRef ref,
  String clientId,
) async {
  final OrdersRepository repository = ref.read(ordersRepositoryProvider);
  return repository.getClientOrders(clientId: clientId);
}

/// Read-only feed of pending orders for a technician to pick up.
@riverpod
Future<List<Order>> pendingOrdersFeed(
  PendingOrdersFeedRef ref,
) async {
  final OrdersRepository repository = ref.read(ordersRepositoryProvider);
  return repository.getPendingOrders();
}
