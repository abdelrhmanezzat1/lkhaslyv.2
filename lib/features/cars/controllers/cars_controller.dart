// Phase 4.1 — feature-local controller for the Cars vertical.
//
// All screens that need car data (service request, add-car, profile car
// list) must read this controller instead of going through
// `RegistrationController`. The controller only owns data-fetch methods;
// any cross-repo orchestration belongs in `features/cars/domain/usecases/`.

import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/cars/domain/repositories/cars_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cars_controller.g.dart';

/// Controller for the Cars feature.
///
/// Phase 4.1 scope: read-only fetch (`getCars`) and the post-registration
/// `saveCar` convenience used by `add_car_screen.dart`. Action flows that
/// require a side-effect to a use-case (notifications, etc.) live in
/// `features/cars/domain/usecases/`.
@riverpod
class CarsController extends _$CarsController {
  @override
  FutureOr<List<Car>> build() {
    // Initial state: empty list. Screens call `loadCars(userId)` from
    // `initState` (or watch the future-provider variant exposed via
    // `serviceLocatorProvider`). Phase 4.2 will switch home screens to
    // watch `AsyncValue` directly.
    return const <Car>[];
  }

  /// Loads cars owned by [userId]. Updates [state] through `AsyncValue.guard`
  /// so a calling `ConsumerStatefulWidget` can `ref.listen` for errors.
  Future<List<Car>> loadCars(String userId) async {
    final CarsRepository carsRepository = ref.read(carsRepositoryProvider);
    state = const AsyncLoading();
    final List<Car> result = await AsyncValue.guard(
      () => carsRepository.getCars(userId: userId),
    ).then((value) => value.valueOrNull ?? const <Car>[]);
    state = AsyncData<List<Car>>(result);
    return result;
  }

  /// Persists a new car. Returns the saved `Car` (with id assigned by the
  /// repository). Used by the post-registration add-car path and any future
  /// car-management screen.
  Future<Car> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) async {
    state = const AsyncLoading();
    try {
      final CarsRepository carsRepository = ref.read(carsRepositoryProvider);
      final car = await carsRepository.saveCar(
        userId: userId,
        carType: carType,
        carModel: carModel,
        plateNumber: plateNumber,
        carYear: carYear,
        color: color,
      );
      // Reload the full list after insert so the provider state is in sync.
      state = await AsyncValue.guard(
        () => carsRepository.getCars(userId: userId),
      );
      return car;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
/// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
/// is the public, fully-reactive API. The controller above is for imperative
/// loads called from `initState`.
@riverpod
Future<List<Car>> carsForUser(
  CarsForUserRef ref,
  String userId,
) async {
  final CarsRepository repository = ref.read(carsRepositoryProvider);
  return repository.getCars(userId: userId);
}
