import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class to access environment variables from the .env file.
class Env {
  Env._(); // Private constructor to prevent instantiation

  /// The URL for the Supabase project.
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// The anonymous key for the Supabase project.
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Mapbox access token used for directions and map display.
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
}
