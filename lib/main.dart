import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/view/app.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/network/supabase_service.dart';
import 'package:flutter_application_1/core/notifications/firebase_debug.dart';
import 'package:flutter_application_1/core/notifications/notification_service.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash handlers are installed in `_bootstrap` right after
  // Firebase.initializeApp (Crashlytics requires a live Firebase app).
  FlutterError.onError = _logFlutterError;
  PlatformDispatcher.instance.onError = _logPlatformError;  try {
    await _bootstrap();
  } catch (e, stack) {
    debugPrint('BOOTSTRAP FAILED');
    debugPrint(e.toString());
    debugPrint(stack.toString());

    runApp(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Application failed to start.\n\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-Firebase fallback: log to the console until `_bootstrap` swaps in
/// the Crashlytics-aware handlers.
void _logFlutterError(FlutterErrorDetails details) {
  FlutterError.presentError(details);
}

bool _logPlatformError(Object error, StackTrace stack) {
  debugPrint(error.toString());
  debugPrint(stack.toString());
  return true;
}

Future<void> _bootstrap() async {
  await dotenv.load(fileName: '.env');

  await StorageService.init();

  if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
    throw Exception('Supabase configuration is missing. Check .env file.');
  }

  // Initialize Firebase with platform-specific options.
  // Guarded: on Android, the native SDK auto-initializes a default
  // FirebaseApp via FirebaseInitProvider (before any Dart code runs), so
  // calling initializeApp(options:) unguarded with DIFFERENT options throws
  // [core/duplicate-app]. Prefer reusing the already-initialized app.
  debugLogFirebaseApps('main._bootstrap BEFORE Firebase.initializeApp()');
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    debugPrint(
      '🔥 [FirebaseDebug] Reusing already-initialized native default app; '
      'skipping Firebase.initializeApp(options:).',
    );
  }
  debugLogFirebaseApps('main._bootstrap AFTER Firebase.initializeApp()');

  // Route errors to Firebase Crashlytics now that a Firebase app is live.
  // Web is skipped (Crashlytics has no web support); bootstrap failures
  // before this point keep the debugPrint-only handlers from `main()`.
  if (!kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      _logFlutterError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final bool handled = _logPlatformError(error, stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return handled;
    };
  }

  // Set background message handler (no-op on web — service worker handles it)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  await SupabaseService.init();

  final verified = await SupabaseService.verify();

  if (!verified) {
    throw Exception('Supabase verification failed.');
  }

  await setupServiceLocator();

  // Initialize NotificationService (skip on web — local notifications not supported)
  if (!kIsWeb) {
    final notificationService = sl<NotificationService>();
    await notificationService.initialize();

    // Handle pending notification from background tap AFTER the router has been
    // built (the router is registered into GetIt when `goRouterProvider` first
    // resolves, during the first frame build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationService.handlePendingNotification();
    });
  }

  runApp(const ProviderScope(child: App()));

  // Subscribe to role-based topics after auth (works on web via FCM)
  _subscribeToRoleTopics();
}

/// Subscribe to role-based topics when user is authenticated
void _subscribeToRoleTopics() {  final authState = Supabase.instance.client.auth.currentUser;
  if (authState != null) {
    final userType =
        authState.userMetadata?['user_type'] as String? ?? 'client';
    final notificationService = NotificationService();
    notificationService.subscribeToRoleTopics(authState.id, userType);
  }

  // Listen for auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    final user = event.session?.user;
    if (user != null) {
      final userType = user.userMetadata?['user_type'] as String? ?? 'client';
      final notificationService = NotificationService();
      notificationService.subscribeToRoleTopics(user.id, userType);
    } else {
      // User signed out - unsubscribe from the topics we subscribed to
      final notificationService = NotificationService();
      notificationService.unsubscribeFromRoleTopics();
    }
  });
}
