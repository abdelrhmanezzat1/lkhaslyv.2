import 'package:flutter_application_1/features/auth/data/services/auth_service.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the [AuthRepository] that uses [AuthService].
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) {
    return _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      metadata: metadata,
    );
  }

  @override
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  }) {
    return _authService.saveProfile(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      userType: userType,
    );
  }

  @override
  Future<void> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) {
    return _authService.saveCar(
      userId: userId,
      carType: carType,
      carModel: carModel,
      plateNumber: plateNumber,
      carYear: carYear,
      color: color,
    );
  }

  @override
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) {
    return _authService.createOrder(
      clientId: clientId,
      carId: carId,
      serviceType: serviceType,
      description: description,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCars({required String userId}) {
    return _authService.getCars(userId: userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders({required String userId}) {
    return _authService.getOrders(userId: userId);
  }

  @override
  Future<Map<String, dynamic>?> getProfile({required String userId}) {
    return _authService.getProfile(userId: userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOrders() {
    return _authService.getPendingOrders();
  }

  @override
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) {
    return _authService.acceptOrder(
      orderId: orderId,
      technicianId: technicianId,
      technicianName: technicianName,
    );
  }

  @override
  Future<void> confirmOrderCompletion({
    required String orderId,
  }) {
    return _authService.confirmOrderCompletion(orderId: orderId);
  }

  @override
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) {
    return _authService.payOrder(
      orderId: orderId,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> updateTechnicianLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
  }) {
    return _authService.updateTechnicianLocation(
      technicianId: technicianId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<bool> hasAcceptedOrders({required String technicianId}) {
    return _authService.hasAcceptedOrders(technicianId: technicianId);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Future<void> updateUser({required String name}) {
    return _authService.updateUser(name: name);
  }
}
