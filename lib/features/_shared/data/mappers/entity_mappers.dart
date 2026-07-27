// DTO -> Entity adapters for the shared cross-feature entities.
//
// These let the data layer keep its raw `Map<String, dynamic>` shape
// (for now) while the application layer works with typed entities.
// Phase 2 will replace the legacy AuthService / AuthRepository with
// implementations that return `Car`, `Order` and `UserProfile` directly.
library;

import '../../domain/entities/car.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/user_profile.dart';

/// Mapping helpers used by both repositories (Phase 2) and by tests.
class EntityMappers {
  const EntityMappers._();

  static Car carFromJson(Map<String, dynamic> json) => Car.fromJson(json);

  static List<Car> carsFromJson(List<Map<String, dynamic>> rows) =>
      rows.map(Car.fromJson).toList(growable: false);

  static UserProfile profileFromJson(Map<String, dynamic> json) =>
      UserProfile.fromJson(json);

  static Order orderFromJson(Map<String, dynamic> json) =>
      Order.fromJson(json);

  static List<Order> ordersFromJson(List<Map<String, dynamic>> rows) =>
      rows.map(Order.fromJson).toList(growable: false);
}
