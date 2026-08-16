import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart' show AuthRepository;

import '../../../_shared/domain/entities/order.dart';

/// Owns reads/writes against the `orders` table.
///
/// Replaces the `createOrder`, `getOrders`, `getPendingOrders`,
/// `acceptOrder`, `confirmOrderCompletion` and `payOrder` methods
/// that lived on [AuthRepository] before Phase 2.
abstract class OrdersRepository {
  /// Creates a new order for the supplied client/car.
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  });

  /// Orders placed by the given client (or by anyone when [clientId] is null).
  Future<List<Order>> getClientOrders({required String clientId});

  /// Orders pending a technician — visible on the Incoming Requests screen.
  Future<List<Order>> getPendingOrders();

  /// A technician claims [orderId].
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  });

  /// Technician has completed the work; awaits client confirmation.
  Future<void> confirmOrderCompletion({required String orderId});

  /// Marks an order as paid via [paymentMethod].
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  });

  /// Stores the client's rating for [orderId].
  Future<void> submitRating({
    required String orderId,
    required int rating,
    String? comment,
  });

  /// True if [technicianId] has any accepted/active/in-progress orders.
  Future<bool> hasAcceptedOrders({required String technicianId});
}
