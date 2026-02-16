import '../entities/user.dart';

/// Abstract contract for authentication operations.
///
/// Implemented by [AuthRepositoryImpl] in the data layer.
/// Consumed by presentation layer providers.
abstract class AuthRepository {
  /// Check if a valid session exists locally.
  Future<bool> isLoggedIn();

  /// Load the stored user session (returns null if not logged in).
  Future<User?> getStoredUser();

  /// Get the YouTube OAuth URL to open in browser.
  Future<String> getAuthUrl(String userId);

  /// Save session data after successful OAuth callback.
  Future<void> saveSession({
    required String userId,
    required String channelId,
    required String channelName,
  });

  /// Fetch live user plan/status from backend and return updated User.
  Future<User> refreshUserStatus(String userId);

  /// Clear session (logout).
  Future<void> logout();
}
