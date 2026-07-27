import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/register_user_use_case.dart';
import 'package:flutter_application_1/features/cars/domain/repositories/cars_repository.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/accept_order_use_case.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/pay_order_use_case.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_location_repository.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Riverpod bridge for the global [GetIt] service locator.
///
/// Phase 3.2 introduces this bridge so feature controllers / providers can
/// resolve their dependencies through a normal [Provider] (which is overridable
/// in tests via `ProviderContainer`) rather than a raw `sl<T>()` call.
///
/// **Coexistence rule:** the legacy `sl` global still works. New Riverpod code
/// should prefer the typed *Repository providers below — every controller test
/// in Phase 7 will override them with mocks instead of `GetIt`'s static state.

/// Exposes the [GetIt] instance itself. Useful when downstream code needs to
/// resolve a binding that isn't yet exposed as a typed [Provider].
final serviceLocatorProvider = Provider<GetIt>((ref) {
  return sl;
});

/// Typed repositories sourced from the service locator.
///
/// These are intentionally *plain* `Provider`s (not `AutoDispose`) — they
/// represent process-lifetime singletons backed by [GetIt].

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<AuthRepository>();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<ProfileRepository>();
});

final carsRepositoryProvider = Provider<CarsRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<CarsRepository>();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<OrdersRepository>();
});

final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<TechnicianRepository>();
});

final technicianLocationRepositoryProvider =
    Provider<TechnicianLocationRepository>((ref) {
  return ref.watch(serviceLocatorProvider)<TechnicianLocationRepository>();
});

// ─────────────────────────────────────────────────────────────────────────────
// Phase 3.4 — use-case providers.
//
// Use-cases are plain classes (not factories). They are constructed fresh each
// time the provider is read so we never share mutable per-call state between
// controllers.
// ─────────────────────────────────────────────────────────────────────────────

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  return RegisterUserUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  );
});

final acceptOrderUseCaseProvider = Provider<AcceptOrderUseCase>((ref) {
  return AcceptOrderUseCase(ref.watch(ordersRepositoryProvider));
});

final payOrderUseCaseProvider = Provider<PayOrderUseCase>((ref) {
  return PayOrderUseCase(
    ref.watch(ordersRepositoryProvider),
    ref.watch(technicianRepositoryProvider),
  );
});
