import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth-session-only Supabase wrapper.
///
/// Phase 2.6 of the refactor splits the original 17-method `AuthService`
/// god-class into per-feature services. This class owns the methods that
/// strictly relate to `supabase.auth.*`:
///   * [authStateChanges]
///   * [signInWithEmailAndPassword] (+ auto profile bootstrap)
///   * [signUpWithEmailAndPassword]
///   * [sendPasswordResetEmail]
///   * [signOut]
///   * [updateUser] (auth.metadata + profiles.name mirror)
///
/// Anything that drives other tables (cars, orders, profiles CRUD) lives
/// in `SupabaseProfileService`, `SupabaseCarsService`,
/// `SupabaseOrdersService` respectively — consumed directly by the
/// feature repositories, never through this class.
class SupabaseAuthService {
  SupabaseAuthService(this._supabase);

  final SupabaseClient _supabase;

  /// Provides a stream of the current user's authentication state.
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange
      .map((event) => event.session?.user);

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _ensureProfileExists();
    } on PostgrestException catch (e, st) {
      appLogger.e(
        'signInWithEmailAndPassword PostgrestException code=${e.code} message=${e.message}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      appLogger.e(
        'signInWithEmailAndPassword exception',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      appLogger.i('Starting signUp for email: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      final user = response.user;
      appLogger.i(
        'signUp completed. user=${user?.id} session=${response.session != null}',
      );
      return user;
    } catch (e, st) {
      appLogger.e('signUp exception', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Updates the auth user's `full_name` metadata and the matching row in
  /// `profiles`. The two writes are isolated here so feature repositories
  /// never have to know that updating a user's name touches two tables.
  Future<void> updateUser({required String name}) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('No authenticated user.');
    }
    await _supabase.auth.updateUser(
      UserAttributes(data: <String, dynamic>{'full_name': name}),
    );
    await _supabase.from('profiles').update(<String, dynamic>{
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser.id);
  }

  Future<void> _ensureProfileExists() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      final existing = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();
      if (existing != null) return;

      final metadata = currentUser.userMetadata ?? <String, dynamic>{};
      final payload = <String, dynamic>{
        'id': currentUser.id,
        'name': metadata['full_name'] ?? '',
        'first_name': metadata['first_name'] ?? '',
        'last_name': metadata['last_name'] ?? '',
        'email': currentUser.email ?? '',
        'phone': metadata['phone'] ?? '',
        'role': metadata['user_type'] ?? 'client',
        'user_type': metadata['user_type'] ?? 'client',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('profiles').upsert(payload);
    } catch (e, st) {
      appLogger.e(
        '_ensureProfileExists exception',
        error: e,
        stackTrace: st,
      );
      // Non-fatal: profile bootstrap must never break sign-in.
    }
  }
}
