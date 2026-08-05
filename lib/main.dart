import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/view/app.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/network/supabase_service.dart';
import 'package:flutter_application_1/core/notifications/notification_service.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    // TODO:
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    // أو Sentry.captureException(...)
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());

    // TODO:
    // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  };

  try {
    await _bootstrap();

    runApp(const ProviderScope(child: App()));
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

Future<void> _bootstrap() async {
  await dotenv.load(fileName: '.env');

  await StorageService.init();

  if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
    throw Exception('Supabase configuration is missing. Check .env file.');
  }

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

  // Initialize NotificationService
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();

  // Handle pending notification from background tap
  await notificationService.handlePendingNotification();

  // Subscribe to role-based topics after auth
  _subscribeToRoleTopics();
}

/// Subscribe to role-based topics when user is authenticated
void _subscribeToRoleTopics() {
  final authState = Supabase.instance.client.auth.currentUser;
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
      // User signed out - unsubscribe from topics
      final notificationService = NotificationService();
      notificationService.unsubscribeFromRoleTopics('', '');
    }
  });
}
