import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract repository for handling user authentication (session only).
///
/// Phase 2.1 + 2.6 narrow this contract to its pure auth concerns.
/// Profile reads/writes live in `ProfileRepository`, cars live in
/// `CarsRepository`, orders live in `OrdersRepository`, and live
/// technician location lives in `TechnicianLocationRepository`.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges;

  /// Signs a user in with their email and password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs a new user up and returns the created user.
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  });

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs out the current user.
  Future<void> signOut();

  /// Updates the current user's full_name (auth metadata + profiles mirror).
  Future<void> updateUser({required String name});
}
