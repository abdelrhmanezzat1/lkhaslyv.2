import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/data/mappers/entity_mappers.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/user_profile.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [ProfileRepository].
///
/// All writes go through `upsert` so the same code works for inserts and
/// updates. Timestamps are added at the repository boundary — UI code
/// never has to think about Supabase-specific columns.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return EntityMappers.profileFromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e, st) {
      appLogger.e(
        'ProfileRepository.getProfile PostgrestException code=${e.code} msg=${e.message}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  }) async {
    appLogger.i('ProfileRepository.saveProfile userId=$userId');
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
    await _supabase.from('profiles').upsert(payload);
  }

  @override
  Future<void> updateUser({required String name}) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('No authenticated user.');
    }

    await _supabase.auth.updateUser(
      UserAttributes(data: <String, dynamic>{'full_name': name}),
    );
    await _supabase
        .from('profiles')
        .update(<String, dynamic>{
          'name': name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', currentUser.id);
  }

}
