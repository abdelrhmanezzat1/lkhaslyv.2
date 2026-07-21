import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'registration_controller.g.dart';

/// Result of registration.
class RegistrationResult {
  final User user;
  final bool isTechnician;

  RegistrationResult({required this.user, required this.isTechnician});
}

@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  FutureOr<RegistrationResult?> build() {
    return null;
  }

  /// Registers a new user with full profile.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      print('[REG] signUpWithEmailAndPassword starting');
      final user = await authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        metadata: {
          'full_name': '$firstName $lastName',
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'user_type': userType,
        },
      );
      print('[REG] signUpWithEmailAndPassword completed. user=${user?.id}');

      if (user == null) {
        print('[REG] user is null, throwing exception');
        throw Exception('Registration failed. No user returned.');
      }

      print('[REG] Calling saveProfile for userId=${user.id}');
      await authRepository.saveProfile(
        userId: user.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        userType: userType,
      );
      print('[REG] saveProfile completed');

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
    final authRepository = sl<AuthRepository>();
    final currentResult = state.value;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await authRepository.saveCar(
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
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await authRepository.createOrder(
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
  Future<List<Map<String, dynamic>>> getCars(String userId) async {
    final authRepository = sl<AuthRepository>();
    return authRepository.getCars(userId: userId);
  }

  /// Gets orders for the current user.
  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final authRepository = sl<AuthRepository>();
    return authRepository.getOrders(userId: userId);
  }

  /// Gets a user profile by user ID.
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final authRepository = sl<AuthRepository>();
    return authRepository.getProfile(userId: userId);
  }

  /// Gets all pending orders for technicians.
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final authRepository = sl<AuthRepository>();
    return authRepository.getPendingOrders();
  }

  /// Technician accepts a pending order.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await authRepository.acceptOrder(
        orderId: orderId,
        technicianId: technicianId,
        technicianName: technicianName,
      );
      return state.value;
    });
  }

  /// Confirms completion of a finished order.
  Future<void> confirmOrderCompletion({required String orderId}) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await authRepository.confirmOrderCompletion(orderId: orderId);
      return state.value;
    });
  }

  Future<void> payOrder({required String orderId, required String paymentMethod}) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await authRepository.payOrder(orderId: orderId, paymentMethod: paymentMethod);
      return state.value;
    });
  }
}
