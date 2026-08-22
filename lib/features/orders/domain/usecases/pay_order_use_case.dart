// Phase 3.4 use-case for paying an order.
//
// This is the most obvious orchestration in the codebase today: the client
// side has to both:
//   1. flip the `orders` row to `paid` via [OrdersRepository.payOrder], and
//   2. tell the local technician mirror account that the job is done via
//      [TechnicianRepository.completeOrderAfterPayment].
//
// Keeping both calls behind a single use-case means the controller no longer
// has to import two repositories, the call order is documented in one place,
// and we have a single test seam.

import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';

/// Typed payload for [PayOrderUseCase].
class PayOrderCommand {
  const PayOrderCommand({
    required this.orderId,
    required this.paymentMethod,
  });

  final String orderId;

  /// Free-form string kept to match [OrdersRepository.payOrder]'s existing
  /// contract. We deliberately *do not* tie it to the `PaymentMethod` enum
  /// yet because the underlying schema field is a string and changing that
  /// is out-of-scope for the Phase 3.4 refactor.
  final String paymentMethod;

  @override
  String toString() =>
      'PayOrderCommand(orderId=$orderId, paymentMethod=$paymentMethod)';
}

class PayOrderUseCase {
  PayOrderUseCase(this._ordersRepository, this._technicianRepository);

  final OrdersRepository _ordersRepository;
  final TechnicianRepository _technicianRepository;

  Future<void> call(PayOrderCommand command) async {
    assert(
      command.orderId.isNotEmpty,
      'PayOrderUseCase requires a non-empty orderId',
    );
    assert(
      command.paymentMethod.isNotEmpty,
      'PayOrderUseCase requires a non-empty paymentMethod',
    );

    appLogger.i(
      'PayOrderUseCase: paying order=${command.orderId} via '
      '${command.paymentMethod}',
    );

    try {
      // Step 1: persistence layer — orders row → paid.
      await _ordersRepository.payOrder(
        orderId: command.orderId,
        paymentMethod: command.paymentMethod,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        'PayOrderUseCase: payOrder failed for order=${command.orderId}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    // Step 2: in-memory mirror — drop the technician's "active" count.
    //
    // We deliberately swallow mirror failures here. The order is paid (the
    // source of truth). The mirrored technician state is a UI affordance —
    // if it fails, we log and continue; a Phase 7 task can revisit this if
    // we want stronger guarantees.
    try {
      await _technicianRepository.completeOrderAfterPayment(command.orderId);
    } catch (error, stackTrace) {
      appLogger.w(
        'PayOrderUseCase: technician mirror update failed for '
        'order=${command.orderId} — the local UI will refresh on next read.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
