import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Debug helper: prints the current state of Firebase apps.
///
/// Call immediately BEFORE and AFTER every `Firebase.initializeApp()` call
/// to pinpoint exactly how many Firebase apps exist and when/where a
/// duplicate is created.
void debugLogFirebaseApps(String context) {
  final apps = Firebase.apps;
  debugPrint('🔥 [FirebaseDebug] $context');
  debugPrint('🔥 [FirebaseDebug]   Firebase.apps.length = ${apps.length}');
  for (final app in apps) {
    debugPrint(
      '🔥 [FirebaseDebug]   - name="${app.name}" '
      'options.appId="${app.options.appId}"',
    );
  }
}
