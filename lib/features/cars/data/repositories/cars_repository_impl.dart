import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/data/mappers/entity_mappers.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/cars/domain/repositories/cars_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [CarsRepository].
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
      if (carYear != null) 'car_year': carYear,
      if (color != null) 'color': color,
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

  @override
  Future<Car> updateCar({
    required String carId,
    String? carType,
    String? carModel,
    String? plateNumber,
    String? carYear,
    String? color,
  }) async {
    appLogger.i('CarsRepository.updateCar carId=$carId');
    final payload = <String, dynamic>{
      'car_type': carType,
      'car_model': carModel,
      'plate_number': plateNumber,
      'car_year': carYear,
      'color': color,
      'updated_at': DateTime.now().toIso8601String(),
    }..removeWhere((key, value) => value == null);

    final updated = await _supabase
        .from('cars')
        .update(payload)
        .eq('id', carId)
        .select()
        .single();

    return EntityMappers.carFromJson(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> deleteCar(String carId) async {
    appLogger.i('CarsRepository.deleteCar carId=$carId');
    await _supabase.from('cars').delete().eq('id', carId);
  }

  @override
  Future<bool> carHasOrders(String carId) async {
    appLogger.i('CarsRepository.carHasOrders carId=$carId');
    final response = await _supabase
        .from('orders')
        .select('id')
        .eq('car_id', carId)
        .limit(1);
    return response.isNotEmpty;
  }
}
