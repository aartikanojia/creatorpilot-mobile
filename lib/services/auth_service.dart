import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/constants.dart';
import 'api_client.dart';

/// Keys used in secure storage.
class _StorageKeys {
  static const userId = 'user_id';
  static const channelId = 'channel_id';
  static const channelName = 'channel_name';
  static const userPlan = 'user_plan';
}

/// Provides the singleton [FlutterSecureStorage] instance.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Provides [AuthService] with injected dependencies.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    dio: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// Handles authentication flow and user session persistence.
///
/// Responsibilities:
/// - Initiate YouTube OAuth flow via backend
/// - Persist user session to secure storage
/// - Retrieve cached session
/// - Fetch user plan/usage status
/// - Logout (clear session)
class AuthService {
  AuthService({required this.dio, required this.storage});

  final Dio dio;
  final FlutterSecureStorage storage;

  // ── OAuth Flow ────────────────────────────────────────────────────────

  /// Get the Google OAuth authorization URL from the backend.
  ///
  /// Opens `GET /api/v1/auth/youtube/start?user_id=...`
  /// Returns the `auth_url` string to open in the system browser.
  Future<String> getAuthUrl(String userId) async {
    final response = await dio.get(
      ApiPaths.authYouTubeStart,
      queryParameters: {'user_id': userId},
    );
    return response.data['auth_url'] as String;
  }

  // ── User Status ───────────────────────────────────────────────────────

  /// Fetch user plan and usage from the backend.
  ///
  /// Returns a map: `{ user_plan, usage: { used, limit, exhausted } }`
  Future<Map<String, dynamic>> getUserStatus(String userId) async {
    final response = await dio.get(
      ApiPaths.userStatus,
      queryParameters: {'user_id': userId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ── Session Persistence ───────────────────────────────────────────────

  /// Save authenticated session locally.
  Future<void> saveSession({
    required String userId,
    required String channelId,
    required String channelName,
    String? userPlan,
  }) async {
    await storage.write(key: _StorageKeys.userId, value: userId);
    await storage.write(key: _StorageKeys.channelId, value: channelId);
    await storage.write(key: _StorageKeys.channelName, value: channelName);
    if (userPlan != null) {
      await storage.write(key: _StorageKeys.userPlan, value: userPlan);
    }
  }

  /// Read the stored user ID, or `null` if not logged in.
  Future<String?> getStoredUserId() async {
    return storage.read(key: _StorageKeys.userId);
  }

  /// Read the stored channel ID.
  Future<String?> getStoredChannelId() async {
    return storage.read(key: _StorageKeys.channelId);
  }

  /// Read the stored channel name.
  Future<String?> getStoredChannelName() async {
    return storage.read(key: _StorageKeys.channelName);
  }

  /// Check if a session exists (user is logged in).
  Future<bool> isLoggedIn() async {
    final userId = await getStoredUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Clear session data (logout).
  Future<void> logout() async {
    await storage.deleteAll();
  }
}
