import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class to access environment variables from the .env file.
class Env {
  Env._(); // Private constructor to prevent instantiation

  /// The URL for the Supabase project.
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// The anonymous key for the Supabase project.
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Mapbox access token used for directions and map display.
  static String get mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  /// Firebase configuration values.
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseIosBundleId =>
      dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';
  static String get firebaseAndroidClientId =>
      dotenv.env['FIREBASE_ANDROID_CLIENT_ID'] ?? '';
  static String get firebaseIosClientId =>
      dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '';
  static String get firebaseMeasurementId =>
      dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';
}
