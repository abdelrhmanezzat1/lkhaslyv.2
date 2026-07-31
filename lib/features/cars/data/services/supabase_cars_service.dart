import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase wrapper for the `cars` table.
///
/// Phase 2.6 carve-out: owns all cars DB-row traffic so feature
/// repositories don't have to know which table or which columns map to
/// which entity.
class SupabaseCarsService {
  SupabaseCarsService(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'cars';

  Future<String> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) async {
    appLogger.i('SupabaseCarsService.saveCar userId=$userId plate=$plateNumber');
    final response = await _supabase.from(_table).insert(<String, dynamic>{
      'user_id': userId,
      'car_type': carType,
      'car_model': carModel,
      'plate_number': plateNumber,
      'car_year': carYear,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    return response['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getCars({required String userId}) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', userId);
    return (response as List).cast<Map<String, dynamic>>();
  }
}
