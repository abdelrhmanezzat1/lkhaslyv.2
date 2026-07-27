import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_application_1/core/env/env.dart';

/// Default [FirebaseOptions] for the current platform.
///
/// Values are read from environment variables defined in the .env file.
/// Run `flutterfire configure` after setting up your Firebase project
/// to generate platform-specific Firebase configuration files.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (const bool.fromEnvironment('dart.library.js')) {
      return web;
    }
    if (const bool.fromEnvironment('dart.library.objc')) {
      return ios;
    }
    return android;
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
        iosBundleId: Env.firebaseIosBundleId,
        iosClientId: Env.firebaseIosClientId,
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
        authDomain: Env.firebaseAuthDomain,
        storageBucket: Env.firebaseStorageBucket,
        measurementId: Env.firebaseMeasurementId,
      );
}
