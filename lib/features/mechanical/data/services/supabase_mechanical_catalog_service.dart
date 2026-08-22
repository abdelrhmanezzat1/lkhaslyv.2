import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase wrapper for the `mechanical_issues` + `car_model_catalog` tables.
///
/// Phase 2.6-style carve-out: owns all catalog DB-row traffic so feature
/// repositories don't have to know table-specific column names.
class SupabaseMechanicalCatalogService {
  SupabaseMechanicalCatalogService(this._supabase);

  final SupabaseClient _supabase;

  static const String _issuesTable = 'mechanical_issues';
  static const String _catalogTable = 'car_model_catalog';

  /// Returns all issue names with their `is_common` flag.
  ///
  /// Common issues are returned first, extras after; each group is ordered
  /// alphabetically by name (deterministic regardless of DB insert order).
  Future<List<Map<String, dynamic>>> getIssues() async {
    final response = await _supabase
        .from(_issuesTable)
        .select('id, name, is_common')
        .order('is_common', ascending: false)
        .order('name');
    return response.cast<Map<String, dynamic>>();
  }

  /// Returns the brand/model catalog rows, ordered by brand then model.
  Future<List<Map<String, dynamic>>> getCatalog() async {
    final response = await _supabase
        .from(_catalogTable)
        .select('id, brand, model, year_start, year_end, gets_extra_issues')
        .order('brand')
        .order('model');
    return response.cast<Map<String, dynamic>>();
  }
}
