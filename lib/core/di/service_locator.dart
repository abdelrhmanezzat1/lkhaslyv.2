import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_application_1/core/network/dio_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_1/features/auth/data/services/auth_service.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/data/repositories/technician_repository_impl.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes the service locator and registers dependencies.
///
/// This function should be called once at application startup.
Future<void> setupServiceLocator() async {
  // Core Services
  sl.registerLazySingleton<Dio>(() => DioClient.dio);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Features - Auth
  // Service (acts as a data source)
  sl.registerLazySingleton(() => AuthService(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Features - Technician
  // Repository using Supabase orders data
  sl.registerLazySingleton<TechnicianRepository>(
    () => TechnicianRepositoryImpl(),
  );

  // Other services, repositories, use cases, and controllers will be registered below.
}
