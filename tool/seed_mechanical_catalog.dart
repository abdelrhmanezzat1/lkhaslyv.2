// ============================================================================
// One-time, idempotent seed script for the Mechanical Issues Catalog.
//
// Reads `assets/data/mechanical_catalog.json` and upserts:
//   - public.mechanical_issues   (common + extra issue names)
//   - public.car_model_catalog   (brand/model/year/extra-flag rows)
//
// Safe to run more than once — no duplicates are created.
//
// Run from the project root (Dart VM — no Flutter engine needed):
//
//   dart run tool/seed_mechanical_catalog.dart ^
//     --url=https://uewkpfwrmmpklpleqltg.supabase.co ^
//     --service-role-key=sb_secret_xxxxx
//
// (or via env vars):
//
//   set SUPABASE_URL=https://uewkpfwrmmpklpleqltg.supabase.co
//   set SUPABASE_SERVICE_ROLE_KEY=sb_secret_xxxxx
//   dart run tool/seed_mechanical_catalog.dart
//
// IMPORTANT: uses the *service role* key to bypass RLS for writes.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:supabase/supabase.dart';

const String _catalogPath = 'assets/data/mechanical_catalog.json';

Future<void> main(List<String> args) async {
  // ── Parse CLI args / env ────────────────────────────────────────────────
  String url = Platform.environment['SUPABASE_URL'] ?? '';
  String serviceRoleKey =
      Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  for (final arg in args) {
    if (arg.startsWith('--url=')) {
      url = arg.substring('--url='.length);
    } else if (arg.startsWith('--service-role-key=')) {
      serviceRoleKey = arg.substring('--service-role-key='.length);
    }
  }

  if (url.isEmpty || serviceRoleKey.isEmpty) {
    stderr.writeln(
      'Missing credentials.\n'
      'Pass --url and --service-role-key, or set SUPABASE_URL and '
      'SUPABASE_SERVICE_ROLE_KEY env vars.',
    );
    exitCode = 2;
    return;
  }

  // ── Load catalog JSON ────────────────────────────────────────────────────
  final file = File(_catalogPath);
  if (!file.existsSync()) {
    stderr.writeln('Catalog file not found: $_catalogPath');
    exitCode = 2;
    return;
  }

  final Map<String, dynamic> catalog;
  try {
    catalog = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } catch (e) {
    stderr.writeln('Failed to parse $_catalogPath: $e');
    exitCode = 2;
    return;
  }

  final issuesCommon =
      (catalog['issues_common'] as List).cast<String>();
  final issuesExtra =
      (catalog['issues_extra'] as List).cast<String>();
  final carModels =
      (catalog['car_models'] as List).cast<Map<String, dynamic>>();

  stdout.writeln(
    'Seed payload: ${issuesCommon.length} common, '
    '${issuesExtra.length} extra, ${carModels.length} car models.',
  );

  // ── Connect (pure Dart — does not need a Flutter engine) ────────────────
  final supabase = SupabaseClient(url, serviceRoleKey);

  try {
    // ── 1) mechanical_issues: upsert by unique name ───────────────────────
    final issueRows = <Map<String, dynamic>>[
      for (final name in issuesCommon)
        {'name': name, 'is_common': true},
      for (final name in issuesExtra)
        {'name': name, 'is_common': false},
    ];

    if (issueRows.isNotEmpty) {
      final inserted = await supabase
          .from('mechanical_issues')
          .upsert(
            issueRows,
            onConflict: 'name',
          )
          .select('id, name');
      stdout.writeln(
        'mechanical_issues: upserted ${inserted.length} rows '
        '(no-op on re-runs).',
      );
    }

    // ── 2) car_model_catalog: upsert by case-insensitive brand+model ─────
    // `onConflict` requires a unique index/constraint. The migration creates
    // the expression index `(lower(btrim(brand)), lower(btrim(model)))`; we
    // must reference it with the same expression in `onConflict`.
    final modelRows = <Map<String, dynamic>>[
      for (final m in carModels)
        {
          'brand': (m['brand'] as String).trim(),
          'model': (m['model'] as String).trim(),
          'year_start': m['year_start'] as int?,
          'year_end': m['year_end'] as int?,
          'gets_extra_issues': m['gets_extra_issues'] as bool,
        },
    ];

    if (modelRows.isNotEmpty) {
      final inserted = await supabase
          .from('car_model_catalog')
          .upsert(
            modelRows,
            onConflict: 'brand,model',
          )
          .select('id, brand, model');
      stdout.writeln(
        'car_model_catalog: upserted ${inserted.length} rows '
        '(no-op on re-runs).',
      );
    }

    stdout.writeln('Seed complete.');
  } catch (e, st) {
    stderr.writeln('Seed failed: $e\n$st');
    exitCode = 1;
  } finally {
    await supabase.dispose();
  }
}
