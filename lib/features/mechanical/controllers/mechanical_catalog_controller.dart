import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/mechanical/domain/entities/mechanical_catalog_entities.dart';
import 'package:flutter_application_1/features/mechanical/domain/repositories/mechanical_catalog_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mechanical_catalog_controller.g.dart';

/// Resolves the mechanical issues applicable to [car] from the catalog.
///
/// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
/// year is never used. Returns a no-match result (hasMatch = false, empty
/// issue list) when the catalog has no entry for the car's brand+model;
/// callers then fall back to the free-text description field.
@riverpod
Future<MechanicalIssuesResult> mechanicalIssuesForCar(
  MechanicalIssuesForCarRef ref,
  Car car,
) async {
  final MechanicalCatalogRepository repository =
      ref.watch(mechanicalCatalogRepositoryProvider);
  return repository.getMechanicalIssuesForCar(car);
}
