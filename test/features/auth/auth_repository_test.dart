// Smoke tests for the AuthRepository contract.
//
// These tests intentionally AVOID talking to Supabase. They document the
// surface area that AuthRepository must expose so:
//   1. The split God-repository refactor (Phase 2) has a safety net.
//   2. Future contributors can iterate safely.
//
// Phase 0 roadmap: tool/lint.sh / tool/lint.ps1 + this file = guardrails.
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A minimal in-memory fake satisfying the [AuthRepository] contract.
///
/// Only the 6 methods exercised below are implemented. The remaining
/// methods throw `UnimplementedError` so we discover them when (and only
/// when) tests start covering them — which is the whole point of the
/// upcoming refactor.
class _FakeAuthService implements AuthRepository {
  bool signInCalled = false;
  bool signOutCalled = false;

  String? lastEmail;
  String? lastPassword;

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (email.isEmpty) throw ArgumentError('email must not be empty');
  }

  @override
  Future<void> signOut() async => signOutCalled = true;

  // ── Methods OUT-OF-SCOPE for auth (will be split in Phase 2) ────────────
  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) =>
      throw UnimplementedError('split into dedicated auth impl');

  @override
  Future<void> updateUser({required String name}) => throw UnimplementedError();
}

void main() {
  late _FakeAuthService repo;

  setUp(() => repo = _FakeAuthService());

  group('AuthRepository [smoke]', () {
    test('signInWithEmailAndPassword forwards email + password', () async {
      await repo.signInWithEmailAndPassword(
        email: 'user@example.com',
        password: 'hunter2',
      );

      expect(repo.signInCalled, isTrue);
      expect(repo.lastEmail, 'user@example.com');
      expect(repo.lastPassword, 'hunter2');
    });

    test('signOut flip the flag', () async {
      await repo.signOut();
      expect(repo.signOutCalled, isTrue);
    });

    test('sendPasswordResetEmail rejects empty email', () async {
      expect(
        () => repo.sendPasswordResetEmail(email: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('authStateChanges exposes a stream', () async {
      expect(repo.authStateChanges, isA<Stream<User?>>());
    });
  });
}
