import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_controller.g.dart';

/// A provider that streams the authentication state of the current user.
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final authRepository = sl<AuthRepository>();
  return authRepository.authStateChanges;
}

/// Controller responsible for handling authentication actions like signing in.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // This controller is for actions, so the build method is a no-op.
  }

  /// Attempts to sign in the user with the given email and password.
  /// The state of the provider will be updated to reflect the loading and error states.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  /// Sends a password reset email.
  /// The state of the provider will be updated to reflect the loading and error states.
  Future<void> sendPasswordResetEmail({required String email}) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authRepository.sendPasswordResetEmail(email: email),
    );
  }

  /// Signs out the current user.
  /// The state of the provider will be updated to reflect the loading and error states.
  Future<void> signOut() async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => authRepository.signOut());
  }

  /// Updates the current user's name.
  /// The state of the provider will be updated to reflect the loading and error states.
  Future<void> updateUser({required String name}) async {
    final authRepository = sl<AuthRepository>();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => authRepository.updateUser(name: name));
  }
}
