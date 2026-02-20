import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import 'api_client.dart';

/// Provides the [GoogleAuthService] singleton.
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(dio: ref.watch(apiClientProvider));
});

/// Handles native Google OAuth via flutter_appauth.
///
/// Flow:
/// 1. Opens native OAuth consent sheet (ASWebAuthenticationSession on iOS)
/// 2. Gets authorization code from Google
/// 3. Sends code to backend for server-side token exchange
/// 4. Returns channel connection result
///
/// Security:
/// - No tokens stored on device
/// - No client secret in Flutter
/// - Backend handles all token exchange and persistence
class GoogleAuthService {
  GoogleAuthService({required this.dio});

  final Dio dio;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // From clientid.plist
  static const String _clientId =
      '697429001294-2mrf5v637ash0uj522spsoill1r9oqpq.apps.googleusercontent.com';
  static const String _redirectUrl =
      'com.googleusercontent.apps.697429001294-2mrf5v637ash0uj522spsoill1r9oqpq:/oauthredirect';

  static const List<String> _scopes = [
    'openid',
    'email',
    'profile',
    'https://www.googleapis.com/auth/youtube.readonly',
    'https://www.googleapis.com/auth/yt-analytics.readonly',
  ];

  static const _serviceConfig = AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenEndpoint: 'https://oauth2.googleapis.com/token',
  );

  /// Perform native OAuth and exchange code with backend.
  ///
  /// Returns a map with `user_id`, `channel_id`, `channel_name` on success.
  /// Throws [GoogleAuthException] on failure with a user-friendly message.
  Future<Map<String, String>> login() async {
    // Step 1: Get authorization code via native OAuth
    final AuthorizationResponse? authResponse;
    try {
      authResponse = await _appAuth.authorize(
        AuthorizationRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: _serviceConfig,
          scopes: _scopes,
          preferEphemeralSession: true,
          additionalParameters: {
            'prompt': 'consent',
            'access_type': 'offline',
          },
        ),
      );
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('cancel') || message.contains('dismiss')) {
        throw GoogleAuthException('Login cancelled');
      }
      if (message.contains('redirect_uri_mismatch')) {
        throw GoogleAuthException(
          'OAuth configuration error. Please contact support.',
        );
      }
      throw GoogleAuthException('OAuth failed: ${e.toString()}');
    }

    if (authResponse == null) {
      throw GoogleAuthException('No authorization code received');
    }

    final code = authResponse.authorizationCode;
    final codeVerifier = authResponse.codeVerifier;
    if (code == null || code.isEmpty) {
      throw GoogleAuthException('No authorization code received');
    }
    debugPrint('[GoogleAuth] Authorization code obtained, exchanging with backend...');

    // Step 2: Send code to backend for server-side exchange
    try {
      final response = await dio.post(
        '/auth/youtube/mobile/exchange',
        data: {
          'code': code,
          'code_verifier': codeVerifier,
          'user_id': AppConfig.defaultUserId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw GoogleAuthException('Backend exchange failed');
      }

      return {
        'user_id': data['user_id'] as String,
        'channel_id': data['channel_id'] as String,
        'channel_name': data['channel_name'] as String,
      };
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw GoogleAuthException('Backend exchange failed: $detail');
    }
  }
}

/// Exception thrown by [GoogleAuthService] with user-friendly messages.
class GoogleAuthException implements Exception {
  GoogleAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
