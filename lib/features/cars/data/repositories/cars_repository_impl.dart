import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/data/mappers/entity_mappers.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/cars/domain/repositories/cars_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [CarsRepository].
///
/// `saveCar` writes the row and immediately re-reads it so callers get
/// back the persisted primary key, matching the contract used by the
/// legacy [AuthService].
class CarsRepositoryImpl implements CarsRepository {
  CarsRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Car> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) async {
    appLogger.i('CarsRepository.saveCar userId=$userId');
    final payload = <String, dynamic>{
      'user_id': userId,
      'car_type': carType,
      'car_model': carModel,
      'plate_number': plateNumber,
      'car_year': ?carYear,
      'color': ?color,
      'created_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _supabase
        .from('cars')
        .insert(payload)
        .select()
        .single();

    return EntityMappers.carFromJson(Map<String, dynamic>.from(inserted));
  }

  @override
  Future<List<Car>> getCars({required String userId}) async {
    appLogger.i('CarsRepository.getCars userId=$userId');
    final response = await _supabase
        .from('cars')
        .select()
        .eq('user_id', userId);

    return EntityMappers.carsFromJson(
      response.cast<Map<String, dynamic>>(),
    );
  }
}
