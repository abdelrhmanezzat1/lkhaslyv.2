import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app/view/app.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/network/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await StorageService.init();

  if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
    debugPrint(
      'Supabase environment variables are missing; skipping Supabase init.',
    );
    await setupServiceLocator();
    runApp(const ProviderScope(child: App()));
    return;
  }

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    await SupabaseService.init();
    final ok = await SupabaseService.verify();
    if (!ok) {
      debugPrint('Supabase initialization verification failed.');
    } else {
      debugPrint('Supabase initialized and verified.');
    }
  } catch (e, st) {
    debugPrint('Supabase initialization error: $e');
    debugPrint('$st');
  }

  await setupServiceLocator();

  runApp(const ProviderScope(child: App()));
}
