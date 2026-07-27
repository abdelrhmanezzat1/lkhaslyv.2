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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createOrder(
        clientId: clientId,
        carId: carId,
        serviceType: serviceType,
        description: description,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );
      // Preserve previously-cached orders; the controller's state is a
      // list cache, not an action result, hence the `?? const <Order>[]`
      // fall-back for the brief AsyncLoading step.
      return state.value ?? const <Order>[];
    });
  }

  /// Technician claims a pending order. The contract is locked down via
  /// `AcceptOrderCommand` — see `accept_order_use_case.dart`.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    final AcceptOrderUseCase acceptOrder = ref.read(acceptOrderUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await acceptOrder(
        AcceptOrderCommand(
          orderId: orderId,
          technicianId: technicianId,
          technicianName: technicianName,
        ),
      );
      return state.value ?? const <Order>[];
    });
  }

  /// Technician marks a job as done — the client is now expected to
  /// confirm + pay.
  Future<void> confirmOrderCompletion({required String orderId}) async {
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.confirmOrderCompletion(orderId: orderId);
      return state.value ?? const <Order>[];
    });
  }

  /// Pays an order. The two-repo orchestration
  /// (`orders.payOrder` + `technician.completeOrderAfterPayment`) is
  /// delegated to `pay_order_use_case.dart`, which documents the call
  /// order and establishes the strict-vs-best-effort error contract.
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    final PayOrderUseCase payOrderUseCase = ref.read(payOrderUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await payOrderUseCase(
        PayOrderCommand(
          orderId: orderId,
          paymentMethod: paymentMethod,
        ),
      );
      return state.value ?? const <Order>[];
    });
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
