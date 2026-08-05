// Domain entities for the Mechanical Issues Catalog.
//
// Mirrors the `public.mechanical_issues` and `public.car_model_catalog`
// tables. Matching in the app uses BRAND + MODEL ONLY (case-insensitive,
// trimmed); year_start/year_end are stored for future use/display and are
// intentionally NOT part of any matching condition.

import '../../../_shared/domain/entities/car.dart';

/// A single mechanical issue row from `mechanical_issues`.
class MechanicalIssue {
  const MechanicalIssue({
    required this.id,
    required this.name,
    required this.isCommon,
  });

  factory MechanicalIssue.fromJson(Map<String, dynamic> json) => MechanicalIssue(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        isCommon: json['is_common'] as bool? ?? true,
      );

  final String id;
  final String name;
  final bool isCommon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MechanicalIssue &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MechanicalIssue(id=$id, name=$name)';
}

/// A row from `car_model_catalog` — a brand/model year-range lookup entry.
class CarModelCatalogEntry {
  const CarModelCatalogEntry({
    required this.id,
    required this.brand,
    required this.model,
    this.yearStart,
    this.yearEnd,
    required this.getsExtraIssues,
  });

  factory CarModelCatalogEntry.fromJson(Map<String, dynamic> json) =>
      CarModelCatalogEntry(
        id: json['id']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        yearStart: (json['year_start'] as num?)?.toInt(),
        yearEnd: (json['year_end'] as num?)?.toInt(),
        getsExtraIssues: json['gets_extra_issues'] as bool? ?? false,
      );

  final String id;
  final String brand;
  final String model;
  final int? yearStart;
  final int? yearEnd;
  final bool getsExtraIssues;

  /// Matches a [Car] against this catalog entry using BRAND + MODEL ONLY.
  ///
  /// Comparison is case-insensitive and trimmed. The car's year is NOT
  /// considered (per spec — year_start/year_end are for future use only).
  bool matchesCar(Car car) {
    final carBrand = car.carType.trim().toLowerCase();
    final carModel = car.carModel.trim().toLowerCase();
    return brand.trim().toLowerCase() == carBrand &&
        model.trim().toLowerCase() == carModel;
  }

  @override
  String toString() => 'CarModelCatalogEntry(id=$id, brand=$brand, model=$model)';
}

/// Result of resolving the mechanical issues applicable to a [Car].
///
/// [hasMatch] is true when the catalog contained the car's brand+model.
class MechanicalIssuesResult {
  const MechanicalIssuesResult._({
    required this._modelEntry,
    required this._issues,
    required this._hasMatch,
  });

  /// No brand+model entry found in the catalog — callers should fall back
  /// to a free-text description.
  const MechanicalIssuesResult.noMatch()
      : this._(modelEntry: null, issues: const [], hasMatch: false);

  const MechanicalIssuesResult.matched({
    required CarModelCatalogEntry modelEntry,
    required List<MechanicalIssue> issues,
  })  : this._(modelEntry: modelEntry, issues: issues, hasMatch: true);

  final CarModelCatalogEntry? _modelEntry;
  final List<MechanicalIssue> _issues;
  final bool _hasMatch;

  CarModelCatalogEntry? get modelEntry => _modelEntry;
  List<MechanicalIssue> get issues => _issues;
  bool get hasMatch => _hasMatch;
}
