// Phase 3.4 use-case that wires the auth + profile creation in one place.
//
// `RegistrationController.register` used to inline:
//
//   1. `AuthRepository.signUpWithEmailAndPassword(metadata: ...)`
//   2. `ProfileRepository.saveProfile(userId: ..., firstName: ..., ...)`
//
// Extracting the orchestration here:
//
//   * lets the controller depend on ONE thing instead of two,
//   * documents the call order (signUp → saveProfile) explicitly,
//   * gives Phase 7 a single test seam where both repos are faked.
//
// Failure semantics:
//   * If signUp throws, the use-case rethrows WITHOUT calling saveProfile
//     (the user is gone — we never want a half-baked profile row).
//   * If signUp returns `null`, the use-case throws a clear error so the
//     controller surfaces "registration failed" instead of silently
//     succeeding with a missing user.
//   * If saveProfile throws AFTER signUp succeeded, the use-case rethrows.
//     The auth user exists without a profile row; that is recoverable
//     later via `ProfileRepository.updateUser` but we surface the error
//     here so the controller can react immediately.

import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/auth/domain/entities/registration_payload.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterUserUseCase {
  RegisterUserUseCase(this._authRepository, this._profileRepository);

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  /// Signs the user up and writes the matching profile row.
  ///
  /// Returns the freshly-created [User] so callers (controllers / scripts)
  /// can read `id`, `email`, etc. without having to re-fetch.
  Future<User> call(RegistrationPayload payload) async {
    _validate(payload);

    appLogger.i(
      'RegisterUserUseCase: signing up ${payload.email} as ${payload.userType}',
    );

    // Step 1 — auth.
    final user = await _authRepository.signUpWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
      metadata: payload.metadata,
    );

    if (user == null) {
      appLogger.e(
        'RegisterUserUseCase: signUpWithEmailAndPassword returned null '
        'for ${payload.email}',
      );
      throw StateError(
        'Registration failed: no user returned for ${payload.email}',
      );
    }

    // Step 2 — profile mirror.
    try {
      await _profileRepository.saveProfile(
        userId: user.id,
        firstName: payload.firstName,
        lastName: payload.lastName,
        email: payload.email,
        phone: payload.phone,
        userType: payload.userType,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        'RegisterUserUseCase: saveProfile failed for user=${user.id}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    appLogger.i(
      'RegisterUserUseCase: registration complete for user=${user.id}',
    );
    return user;
  }

  void _validate(RegistrationPayload payload) {
    assert(payload.firstName.isNotEmpty, 'firstName must not be empty');
    assert(payload.lastName.isNotEmpty, 'lastName must not be empty');
    assert(payload.email.isNotEmpty, 'email must not be empty');
    assert(payload.password.isNotEmpty, 'password must not be empty');
    assert(payload.phone.isNotEmpty, 'phone must not be empty');
    assert(
      payload.userType == 'client' || payload.userType == 'technician',
      "userType must be 'client' or 'technician'",
    );
  }
}
