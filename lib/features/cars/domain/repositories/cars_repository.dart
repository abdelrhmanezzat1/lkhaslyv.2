import '../../../_shared/domain/entities/car.dart';

/// Owns reads/writes against the `cars` table.
///
/// Replaces the `saveCar` / `getCars` methods that used to live on the
/// over-burdened `AuthRepository`. Returns typed [Car] entities
/// (Phase 1).
abstract class CarsRepository {
  /// Saves (inserts) a car for [userId]. Returns the persisted entity
  /// populated with the generated primary key.
  Future<Car> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  });

  /// Lists all cars owned by [userId]. Returns an empty list when none.
  Future<List<Car>> getCars({required String userId});

  /// Updates an existing car identified by [carId] with the given fields.
  /// Returns the updated [Car].
  Future<Car> updateCar({
    required String carId,
    String? carType,
    String? carModel,
    String? plateNumber,
    String? carYear,
    String? color,
  });

  /// Deletes a car by [carId]. Throws if the car has order references.
  Future<void> deleteCar(String carId);

  /// Returns true if any order references [carId].
  Future<bool> carHasOrders(String carId);
}
