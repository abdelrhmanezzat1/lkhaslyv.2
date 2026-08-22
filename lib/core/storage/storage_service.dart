import 'package:shared_preferences/shared_preferences.dart';

/// A service for managing local key-value storage.
///
/// This class is a wrapper around `shared_preferences` to provide a
/// simple and type-safe API for storing and retrieving data. It must be
/// initialized with `StorageService.init()` before use.
class StorageService {
  StorageService._(); // Private constructor to prevent instantiation

  static late final SharedPreferences _prefs;

  /// Initializes the storage service. Must be called once at app startup.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Writes a string value to storage.
  static Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Reads a string value from storage. Returns null if the key is not found.
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Writes a boolean value to storage.
  static Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  /// Reads a boolean value from storage. Returns null if the key is not found.
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Writes an integer value to storage.
  static Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  /// Reads an integer value from storage. Returns null if the key is not found.
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Removes a value from storage by its key.
  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Clears all data from storage.
  static Future<bool> clear() {
    return _prefs.clear();
  }
}
