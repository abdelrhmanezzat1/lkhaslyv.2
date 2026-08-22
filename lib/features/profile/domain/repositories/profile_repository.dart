import '../../../_shared/domain/entities/user_profile.dart';

/// Repository for the user's profile record (the `profiles` table).
///
/// Phase 2 of the refactor roadmap splits this out from `AuthRepository`
/// so that authentication, profile management and the technician
/// update-location method each own their own concern.
abstract class ProfileRepository {
  /// Reads the profile row for [userId], or returns `null` if missing.
  Future<UserProfile?> getProfile(String userId);

  /// Inserts/updates a profile row.
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  });

  /// Replaces the auth user's full name and the matching `profiles` row.
  Future<void> updateUser({required String name});
}
