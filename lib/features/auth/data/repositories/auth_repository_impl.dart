import 'package:flutter_application_1/features/auth/data/services/supabase_auth_service.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the [AuthRepository] that uses [SupabaseAuthService].
///
/// Phase 2.6 retargets this class away from the historical 17-method
/// `AuthService` god-class and onto `SupabaseAuthService`, which exposes
/// only the auth-session related methods. Per-feature concerns
/// (profile, cars, orders, technician location) live in their own
/// repositories — see `lib/features/{profile,cars,orders,technician}`.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final SupabaseAuthService _authService;

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
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> updateUser({required String name}) {
    return _authService.updateUser(name: name);
  }
}
