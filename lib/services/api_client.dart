import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';

/// Centralized Dio HTTP client for all API calls.
///
/// Features:
/// - Base URL from [AppConfig]
/// - Configurable timeout
/// - Logging interceptor (debug builds)
/// - Error mapping interceptor
///
/// Exposed as a Riverpod provider so every service shares one instance.
final apiClientProvider = Provider<Dio>((ref) {
  return ApiClient.create();
});

class ApiClient {
  const ApiClient._();

  /// Create a configured [Dio] instance.
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Logging (debug builds only) ────────────────────────────────
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print('[DIO] $obj'),
        ),
      );
      return true;
    }());

    // ── Error mapping ──────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Wrap DioExceptions with user-friendly messages
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                type: error.type,
                message: 'Connection timed out. Please try again.',
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
