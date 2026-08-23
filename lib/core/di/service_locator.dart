import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/network/dio_client.dart';
import 'package:flutter_application_1/core/notifications/notification_service.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_1/features/auth/data/services/supabase_auth_service.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:flutter_application_1/features/cars/data/services/supabase_cars_service.dart';
import 'package:flutter_application_1/features/cars/domain/repositories/cars_repository.dart';
import 'package:flutter_application_1/features/mechanical/data/repositories/mechanical_catalog_repository_impl.dart';
import 'package:flutter_application_1/features/mechanical/data/services/supabase_mechanical_catalog_service.dart';
import 'package:flutter_application_1/features/mechanical/domain/repositories/mechanical_catalog_repository.dart';
import 'package:flutter_application_1/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_application_1/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_application_1/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:flutter_application_1/features/orders/data/services/supabase_orders_service.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_application_1/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_application_1/features/profile/data/services/supabase_profile_service.dart';
import 'package:flutter_application_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_application_1/features/technician/data/repositories/technician_location_repository_impl.dart';
import 'package:flutter_application_1/features/technician/data/repositories/technician_repository_impl.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_location_repository.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes the service locator and registers all feature dependencies.
///
/// Called once at application startup (see `lib/main.dart`).
Future<void> setupServiceLocator() async {
  // ──────────────────────────────────────────────────────────────────────────
  // Core
  // ──────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient.dio);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<NotificationService>(NotificationService.new);

  // ──────────────────────────────────────────────────────────────────────────
  // Per-feature Supabase services (Phase 2.6 split)
  // ──────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseAuthService>(
    () => SupabaseAuthService(sl()),
  );
  sl.registerLazySingleton<SupabaseProfileService>(
    () => SupabaseProfileService(sl()),
  );
  sl.registerLazySingleton<SupabaseCarsService>(
    () => SupabaseCarsService(sl()),
  );
  sl.registerLazySingleton<SupabaseOrdersService>(
    () => SupabaseOrdersService(sl()),
  );
  sl.registerLazySingleton<SupabaseMechanicalCatalogService>(
    () => SupabaseMechanicalCatalogService(sl()),
  );

  // ──────────────────────────────────────────────────────────────────────────
  // Feature repositories (Phase 2.1–2.5 / Phase 3.1 wiring)
  // ──────────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseAuthService>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<CarsRepository>(
    () => CarsRepositoryImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<MechanicalCatalogRepository>(
    () => MechanicalCatalogRepositoryImpl(sl<SupabaseMechanicalCatalogService>()),
  );
  sl.registerLazySingleton<TechnicianRepository>(
    TechnicianRepositoryImpl.new,
  );
  sl.registerLazySingleton<TechnicianLocationRepository>(
    () => TechnicianLocationRepositoryImpl(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<SupabaseClient>()),
  );
}
