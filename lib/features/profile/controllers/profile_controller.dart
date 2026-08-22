// Phase 4.1 — feature-local controller for the Profile vertical.
//
// Replaces `RegistrationController.getProfile(userId)` so screens can read
// the current user's profile from a dedicated, typed controller. Reads
// are also exposed as a `Future`-returning family provider for screens
// that want pure declarative `AsyncValue` consumption (Phase 4.2 will
// migrate those screens).

import 'dart:async';

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<UserProfile?> build() => null;

  /// Loads the profile row for [userId] and stores it in state.
  Future<UserProfile?> loadProfile(String userId) async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    final UserProfile? result = await AsyncValue.guard(
      () => repository.getProfile(userId),
    ).then((AsyncValue<UserProfile?> value) => value.valueOrNull);
    state = AsyncData<UserProfile?>(result);
    return result;
  }

  /// Convenience updater that re-reads after a save so callers can
  /// `await` a "fresh" profile in one call.
  Future<UserProfile?> reloadProfile(String userId) async {
    return loadProfile(userId);
  }
}

/// Declarative read of a profile by user id. Lets a screen write
/// `final profile = ref.watch(profileByIdProvider(userId))` and react
/// to `AsyncValue` states without manually calling into the notifier
/// from `initState`.
@riverpod
Future<UserProfile?> profileById(
  ProfileByIdRef ref,
  String userId,
) async {
  final ProfileRepository repository = ref.read(profileRepositoryProvider);
  return repository.getProfile(userId);
}
