import '../../../_shared/domain/entities/car.dart';
import '../entities/mechanical_catalog_entities.dart';

/// Owns reads against the `mechanical_issues` + `car_model_catalog` tables.
///
/// The matching contract enforced by every implementation:
///   * match on BRAND + MODEL ONLY (case-insensitive, trimmed)
///   * NEVER use year_start/year_end in the match
///   * issues = all common issues + extra issues only if the matched
///     entry has gets_extra_issues = true
abstract class MechanicalCatalogRepository {
  /// Resolves the applicable mechanical issues for [car].
  ///
  /// Returns [MechanicalIssuesResult.noMatch] when the catalog has no
  /// brand+model entry for [car].
  Future<MechanicalIssuesResult> getMechanicalIssuesForCar(Car car);

  /// Fetches the full brand/model catalog (for admin/debugging or future
  /// pickers). Entries are ordered by brand then model.
  Future<List<CarModelCatalogEntry>> getCarModelCatalog();
}
