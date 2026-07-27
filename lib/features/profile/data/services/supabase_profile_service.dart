import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase wrapper for the `profiles` table.
///
/// Phase 2.6 of the refactor splits the original 17-method `AuthService`
/// into per-feature services. This class owns the small set of methods
/// that mutate `profiles`:
///   * [saveProfile] — upsert with first/last/email/phone/role
///   * [getProfile] — fetch user metadata row
///   * [getProfileById] — alias that returns `null` when missing
///
/// Note: live-technician location lives in
/// `TechnicianLocationRepositoryImpl` (Phase 2.5). Auth bootstrap of a
/// profile row stays on `SupabaseAuthService._ensureProfileExists` so
/// sign-in failure is never possible due to a profile-write error.
class SupabaseProfileService {
  SupabaseProfileService(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'profiles';

  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  }) async {
    try {
      appLogger.i('SupabaseProfileService.saveProfile userId=$userId');
      final now = DateTime.now().toIso8601String();
      final payload = <String, dynamic>{
        'id': userId,
        'name': '$firstName $lastName',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': userType,
        'user_type': userType,
        'created_at': now,
        'updated_at': now,
      };
      await _supabase.from(_table).upsert(payload);
    } on PostgrestException catch (e, st) {
      appLogger.e(
        'saveProfile PostgrestException code=${e.code} msg=${e.message}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      appLogger.e('saveProfile exception', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final row = await _supabase
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return Map<String, dynamic>.from(row);
    } on PostgrestException catch (e, st) {
      appLogger.e(
        'getProfileById PostgrestException code=${e.code} msg=${e.message}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
