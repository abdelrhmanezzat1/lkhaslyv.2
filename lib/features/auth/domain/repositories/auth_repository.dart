import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract repository for handling user authentication.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges;

  /// Signs in a user with their email and password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up a new user and returns the created user.
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  });

  /// Saves a user profile into the profiles table.
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  });

  /// Saves a car into the cars table.
  Future<void> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  });

  /// Creates a new order in the orders table.
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  });

  /// Fetches cars for the current user.
  Future<List<Map<String, dynamic>>> getCars({required String userId});

  /// Fetches orders for the current user.
  Future<List<Map<String, dynamic>>> getOrders({required String userId});

  /// Fetches a user profile by user ID.
  Future<Map<String, dynamic>?> getProfile({required String userId});

  /// Fetches all pending orders for technicians.
  Future<List<Map<String, dynamic>>> getPendingOrders();

  /// Technician accepts a pending order.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  });

  /// Confirms completion of a finished order.
  Future<void> confirmOrderCompletion({
    required String orderId,
  });

  /// Marks an order as paid and updates the payment method.
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  });

  /// Updates the current technician location in the profiles table.
  Future<void> updateTechnicianLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
  });

  /// Checks if a technician has any accepted orders.
  Future<bool> hasAcceptedOrders({required String technicianId});

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs out the current user.
  Future<void> signOut();

  /// Updates the current user's data.
  Future<void> updateUser({required String name});
}
