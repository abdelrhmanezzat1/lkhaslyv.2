// Phase 3.4 use-case for accepting a pending order.
//
// Wraps [OrdersRepository.acceptOrder] so the controller layer does not have
// to know which repository owns this action. Today the orchestration is a
// single repository call, but extracting it here:
//
//   * locks down the payload contract (so the controller can't pass ad-hoc
//     broken metadata by accident), and
//   * gives us a single testable seam — Phase 7 mocks the use-case instead
//     of the repository.
//
// If a future story adds post-acceptance work (e.g. push notification,
// technician-side request mirror), it lands here without touching the
// controller.

import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';

/// Typed payload for `AcceptOrderUseCase` — keeps the call-site named.
class AcceptOrderCommand {
  const AcceptOrderCommand({
    required this.orderId,
    required this.technicianId,
    required this.technicianName,
  });

  final String orderId;
  final String technicianId;
  final String technicianName;

  @override
  String toString() =>
      'AcceptOrderCommand(orderId=$orderId, technicianId=$technicianId, '
      'technicianName=$technicianName)';
}

class AcceptOrderUseCase {
  AcceptOrderUseCase(this._ordersRepository);

  final OrdersRepository _ordersRepository;

  /// Technician (identified by `command.technicianId`) claims the order
  /// (identified by `command.orderId`).
  ///
  /// Throws if the order cannot be fetched/updated.
  Future<void> call(AcceptOrderCommand command) async {
    assert(
      command.orderId.isNotEmpty,
      'AcceptOrderUseCase requires a non-empty orderId',
    );
    assert(
      command.technicianId.isNotEmpty,
      'AcceptOrderUseCase requires a non-empty technicianId',
    );
    assert(
      command.technicianName.isNotEmpty,
      'AcceptOrderUseCase requires a non-empty technicianName',
    );

    appLogger.i(
      'AcceptOrderUseCase: technician=${command.technicianId} '
      'accepting order=${command.orderId}',
    );

    try {
      await _ordersRepository.acceptOrder(
        orderId: command.orderId,
        technicianId: command.technicianId,
        technicianName: command.technicianName,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        'AcceptOrderUseCase: failed to accept order=${command.orderId}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
