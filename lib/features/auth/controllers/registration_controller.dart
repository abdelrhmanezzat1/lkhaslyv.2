import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/entities/registration_payload.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/accept_order_use_case.dart';
import 'package:flutter_application_1/features/orders/domain/usecases/pay_order_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'registration_controller.g.dart';

/// Result of registration.
class RegistrationResult {
  const RegistrationResult({required this.user, required this.isTechnician});
  final User user;
  final bool isTechnician;
}

@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  FutureOr<RegistrationResult?> build() {
    return null;
  }

  /// Registers a new user with full profile.
  ///
  /// Phase 3.4: the two-repo orchestration (auth `signUp` + profile save)
  /// lives in `register_user_use_case.dart`. The controller just bundles
  /// input into a typed `RegistrationPayload` and forwards it.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    final registerUser = ref.read(registerUserUseCaseProvider);
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = await registerUser(
        RegistrationPayload(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phone: phone,
          userType: userType,
        ),
      );

      return RegistrationResult(
        user: user,
        isTechnician: userType == 'technician',
      );
    });
  }

  /// Saves a car after successful registration.
  Future<void> saveCarAfterRegistration({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) async {
    final carsRepository = ref.read(carsRepositoryProvider);
    final currentResult = state.value;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await carsRepository.saveCar(
        userId: userId,
        carType: carType,
        carModel: carModel,
        plateNumber: plateNumber,
        carYear: carYear,
        color: color,
      );
      return currentResult;
    });
  }

  /// Creates an order.
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) async {
    final ordersRepository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ordersRepository.createOrder(
        clientId: clientId,
        carId: carId,
        serviceType: serviceType,
        description: description,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );
      return state.value;
    });
  }

  /// Gets cars for the current user.
  Future<List<Car>> getCars(String userId) async {
    final carsRepository = ref.read(carsRepositoryProvider);
    return carsRepository.getCars(userId: userId);
  }

  /// Gets orders for the current user.
  Future<List<Order>> getOrders(String userId) async {
    final ordersRepository = ref.read(ordersRepositoryProvider);
    return ordersRepository.getClientOrders(clientId: userId);
  }

  /// Gets a user profile by user ID.
  Future<UserProfile?> getProfile(String userId) async {
    final profileRepository = ref.read(profileRepositoryProvider);
    return profileRepository.getProfile(userId);
  }

  /// Gets all pending orders for technicians.
  Future<List<Order>> getPendingOrders() async {
    final ordersRepository = ref.read(ordersRepositoryProvider);
    return ordersRepository.getPendingOrders();
  }

  /// Technician accepts a pending order.
  ///
  /// Phase 3.4: the underlying work lives in `accept_order_use_case.dart`.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    final acceptOrder = ref.read(acceptOrderUseCaseProvider);
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await acceptOrder(
        AcceptOrderCommand(
          orderId: orderId,
          technicianId: technicianId,
          technicianName: technicianName,
        ),
      );
      return state.value;
    });
  }

  /// Confirms completion of a finished order.
  Future<void> confirmOrderCompletion({required String orderId}) async {
    final ordersRepository = ref.read(ordersRepositoryProvider);
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ordersRepository.confirmOrderCompletion(orderId: orderId);
      return state.value;
    });
  }

  /// Pays an order. Phase 3.4: the orchestration
  /// (`orders.payOrder` + `technician.completeOrderAfterPayment`)
  /// lives in `pay_order_use_case.dart`, which documents call order and
  /// error semantics.
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    final payOrder = ref.read(payOrderUseCaseProvider);
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await payOrder(
        PayOrderCommand(
          orderId: orderId,
          paymentMethod: paymentMethod,
        ),
      );
      return state.value;
    });
  }
}
