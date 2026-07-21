import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';

/// Lightweight Supabase helper to expose the client and perform basic
/// initialization / verification steps. Never hardcodes keys — uses `Env`.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Attach listeners and perform any runtime configuration for Supabase.
  static Future<void> init() async {
    try {
      // Listen for auth state changes so they surface in logs during development.
      client.auth.onAuthStateChange.listen((event) {
        debugPrint('Supabase auth change: $event');
      });
    } catch (e) {
      debugPrint('Failed to setup Supabase listeners: $e');
    }
  }

  /// Basic verification that initialization completed and the client is usable.
  /// This checks env vars and attempts to access the auth client.
  static Future<bool> verify() async {
    if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
      debugPrint('Supabase env vars are empty');
      return false;
    }

    try {
      // Accessing currentUser is a lightweight, local check that should be
      // available even without network connectivity.
      final currentUser = client.auth.currentUser;
      debugPrint('Supabase client present. currentUser=$currentUser');
      return true;
    } catch (e) {
      debugPrint('Supabase verify error: $e');
      return false;
    }
  }
}
