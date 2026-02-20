/// Environment configuration for CreatorPilot.
///
/// Reads values from `--dart-define` flags passed at build time.
/// Falls back to development defaults for local development.
class AppConfig {
  const AppConfig._();

  /// API base URL for the CreatorPilot API gateway.
  /// Override with: `--dart-define=API_BASE_URL=https://your-server.com`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// OAuth login URL — opens in system browser, redirects to Google.
  /// Uses the /auth/youtube/login endpoint which performs a 302 redirect.
  static String get oauthLoginUrl =>
      '$apiBaseUrl/auth/youtube/login?user_id=$defaultUserId';

  /// Temporary hardcoded user ID for Phase 1 (single-user mode).
  /// Will be replaced by real auth-issued UUIDs in Phase 2.
  static const String defaultUserId =
      '00000000-0000-0000-0000-000000000001';

  /// Free plan daily query limit.
  static const int freePlanLimit = 3;

  /// API request timeout in seconds.
  static const int apiTimeoutSeconds = 30;
}
