import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_location_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [TechnicianLocationRepository].
///
/// The underlying column writes (`current_lat`, `current_lng`) are byte
/// compatible with the legacy `AuthService.updateTechnicianLocation`
/// implementation so DB consumers (e.g. `map_screen.dart`) keep working
/// without any extra migration step.
class TechnicianLocationRepositoryImpl
    implements TechnicianLocationRepository {
  TechnicianLocationRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'profiles';

  @override
  Future<void> updateLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
  }) async {
    appLogger.i(
      'TechnicianLocationRepository.updateLocation id=$technicianId lat=$latitude lng=$longitude',
    );
    await _supabase.from(_table).update(<String, dynamic>{
      'current_lat': latitude,
      'current_lng': longitude,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', technicianId);
  }

  @override
  Future<({double latitude, double longitude, DateTime updatedAt})?>
      readLatest(String technicianId) async {
    final response = await _supabase
        .from(_table)
        .select('current_lat, current_lng, updated_at')
        .eq('id', technicianId)
        .maybeSingle();
    if (response == null) return null;
    final lat = (response['current_lat'] as num?)?.toDouble();
    final lng = (response['current_lng'] as num?)?.toDouble();
    final rawUpdated = response['updated_at'] as String?;
    if (lat == null || lng == null) return null;
    return (
      latitude: lat,
      longitude: lng,
      updatedAt: DateTime.tryParse(rawUpdated ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
