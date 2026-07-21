// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app/view/app.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() async {
    // Ensure a clean state before each test.
    await dotenv.load(fileName: ".env");
    await StorageService.init();
    await StorageService.clear(); // Clear storage for test independence
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    await setupServiceLocator();
  });

  testWidgets('App starts and navigates to Onboarding screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Verify that the splash screen's progress indicator is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Settle the widget tree to allow for animations and futures to complete.
    // This will trigger the navigation from the splash screen.
    await tester.pumpAndSettle();

    // After navigation, verify that the OnboardingScreen is now visible.
    expect(find.text('Welcome to Lakhsly'), findsOneWidget);
  });
}
