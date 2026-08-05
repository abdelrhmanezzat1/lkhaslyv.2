import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/mechanical/data/services/supabase_mechanical_catalog_service.dart';
import 'package:flutter_application_1/features/mechanical/domain/entities/mechanical_catalog_entities.dart';
import 'package:flutter_application_1/features/mechanical/domain/repositories/mechanical_catalog_repository.dart';

/// Supabase-backed implementation of [MechanicalCatalogRepository].
///
/// Matching contract (spec):
///   * BRAND + MODEL ONLY — case-insensitive, trimmed.
///   * The car's year is NEVER used (year_start/year_end are not part of
///     the match condition; they are stored for future use/display).
///   * issues_common are always included; issues_extra only when the
///     matched catalog entry has gets_extra_issues = true.
class MechanicalCatalogRepositoryImpl implements MechanicalCatalogRepository {
  MechanicalCatalogRepositoryImpl(this._service);

  final SupabaseMechanicalCatalogService _service;

  @override
  Future<MechanicalIssuesResult> getMechanicalIssuesForCar(Car car) async {
    appLogger.i(
      'MechanicalCatalogRepository.getMechanicalIssuesForCar '
      'brand="${car.carType}" model="${car.carModel}"',
    );

    final catalogRows = await _service.getCatalog();
    final catalog =
        catalogRows.map(CarModelCatalogEntry.fromJson).toList(growable: false);

    final normalizedBrand = car.carType.trim().toLowerCase();
    final normalizedModel = car.carModel.trim().toLowerCase();

    // BRAND + MODEL ONLY. No year filtering.
    CarModelCatalogEntry? match;
    for (final entry in catalog) {
      if (entry.brand.trim().toLowerCase() == normalizedBrand &&
          entry.model.trim().toLowerCase() == normalizedModel) {
        match = entry;
        break;
      }
    }

    if (match == null) {
      appLogger.i(
        'MechanicalCatalogRepository: no catalog match for '
        '"$normalizedBrand $normalizedModel" — falling back to free text.',
      );
      return const MechanicalIssuesResult.noMatch();
    }

    // `match` is promoted to non-null here — capture in a local so the
    // collection-if below reads cleanly.
    final CarModelCatalogEntry matched = match;

    final issueRows = await _service.getIssues();
    final issues = <MechanicalIssue>[
      for (final row in issueRows)
        if (row['is_common'] == true)
          MechanicalIssue.fromJson(row)
        else if (matched.getsExtraIssues)
          MechanicalIssue.fromJson(row),
    ];

    appLogger.i(
      'MechanicalCatalogRepository: matched "${matched.brand} ${matched.model}" '
      'getsExtra=${matched.getsExtraIssues} issues=${issues.length}',
    );

    return MechanicalIssuesResult.matched(
      modelEntry: matched,
      issues: issues,
    );
  }

  @override
  Future<List<CarModelCatalogEntry>> getCarModelCatalog() async {
    final rows = await _service.getCatalog();
    return rows.map(CarModelCatalogEntry.fromJson).toList(growable: false);
  }
}
