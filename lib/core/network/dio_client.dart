import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';

/// Provides a configured Dio instance for network requests.
class DioClient {
  DioClient._(); // Private constructor

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.supabaseUrl,
        receiveTimeout: const Duration(milliseconds: 15000), // 15 seconds
        connectTimeout: const Duration(milliseconds: 15000),
        sendTimeout: const Duration(milliseconds: 15000),
        headers: {
          'Content-Type': 'application/json',
          'apikey': Env.supabaseAnonKey,
          // Supabase uses the 'Authorization' header for user-specific requests,
          // which will be added via an interceptor later.
        },
      ),
    );

    // Add logging interceptor only in debug mode for cleaner production logs.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => appLogger.d(obj.toString()),
        ),
      );
    }

    return dio;
  }
}
