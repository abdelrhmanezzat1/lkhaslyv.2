// Phase 3.4 — RegisterUserUseCase tests.

import 'package:flutter_application_1/features/_shared/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/entities/registration_payload.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/domain/usecases/register_user_use_case.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  int signUpCalls = 0;
  String? lastEmail;
  String? lastPassword;
  Map<String, dynamic>? lastMetadata;

  /// Returns null when nullReturn is true.
  User? buildUser(bool nullReturn) {
    if (nullReturn) return null;
    return User(
      id: 'user-1',
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: 'authenticated',
      email: 'alice@example.com',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  bool nullReturn = false;
  Exception? throwOnSignUp;

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    signUpCalls += 1;
    lastEmail = email;
    lastPassword = password;
    lastMetadata = metadata;
    final t = throwOnSignUp;
    if (t != null) throw t;
    return buildUser(nullReturn);
  }

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();
  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();
  @override
  Future<void> sendPasswordResetEmail({required String email}) async =>
      throw UnimplementedError();
  @override
  Future<void> signOut() async => throw UnimplementedError();
  @override
  Future<void> updateUser({required String name}) async =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements ProfileRepository {
  int saveCalls = 0;
  String? lastUserId;
  String? lastFirstName;
  String? lastUserType;
  Exception? throwOnSave;

  @override
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  }) async {
    saveCalls += 1;
    lastUserId = userId;
    lastFirstName = firstName;
    lastUserType = userType;
    final t = throwOnSave;
    if (t != null) throw t;
  }

  @override
  Future<UserProfile?> getProfile(String userId) async =>
      throw UnimplementedError();
  @override
  Future<void> updateUser({required String name}) async =>
      throw UnimplementedError();
}

void main() {
  group('RegisterUserUseCase', () {
    late _FakeAuthRepository auth;
    late _FakeProfileRepository profile;
    late RegisterUserUseCase sut;

    const payload = RegistrationPayload(
      firstName: 'Alice',
      lastName: 'Ahmed',
      email: 'alice@example.com',
      password: 'p@ssw0rd!',
      phone: '+201234567890',
      userType: 'client',
    );

    setUp(() {
      auth = _FakeAuthRepository();
      profile = _FakeProfileRepository();
      sut = RegisterUserUseCase(auth, profile);
    });

    test('happy path: signUp then saveProfile, returns the new User',
        () async {
      final user = await sut(payload);

      expect(auth.signUpCalls, 1);
      expect(profile.saveCalls, 1);
      expect(user.id, 'user-1');
      expect(profile.lastUserId, 'user-1');
      expect(profile.lastFirstName, 'Alice');
      expect(profile.lastUserType, 'client');
      expect(auth.lastMetadata, containsPair('first_name', 'Alice'));
      expect(auth.lastMetadata, containsPair('full_name', 'Alice Ahmed'));
      expect(auth.lastMetadata, containsPair('user_type', 'client'));
    });

    test('throws StateError and does NOT call saveProfile when signUp returns null',
        () async {
      auth.nullReturn = true;

      await expectLater(() => sut(payload), throwsA(isA<StateError>()));
      expect(profile.saveCalls, 0);
    });

    test('rethrows signUp errors without calling saveProfile', () async {
      final boom = Exception('network gone');
      auth.throwOnSignUp = boom;

      await expectLater(() => sut(payload), throwsA(same(boom)));
      // Critical: never write a profile for a user that doesn't exist.
      expect(profile.saveCalls, 0);
    });

    test('rethrows saveProfile errors after a successful signUp', () async {
      final boom = Exception('profiles table missing');
      profile.throwOnSave = boom;

      await expectLater(() => sut(payload), throwsA(same(boom)));
      expect(auth.signUpCalls, 1);
    });
  });
}
