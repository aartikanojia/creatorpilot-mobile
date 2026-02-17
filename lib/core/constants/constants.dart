/// Centralized API path constants.
///
/// All endpoint paths are defined here to avoid hardcoding across the app.
/// These are relative paths — the base URL comes from [AppConfig].
class ApiPaths {
  const ApiPaths._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String authYouTubeStart = '/auth/youtube/start';
  static const String authYouTubeLogin = '/auth/youtube/login';
  static const String authYouTubeCallback = '/auth/youtube/callback';

  // ── User ──────────────────────────────────────────────────────────────
  static const String userStatus = '/api/v1/user/status';

  // ── Channel ───────────────────────────────────────────────────────────
  static const String channelStats = '/api/v1/channel/stats';
  static const String channelTopVideo = '/api/v1/channel/top-video';

  // ── Execute (AI ask) ──────────────────────────────────────────────────
  static const String execute = '/api/v1/execute';
}

/// General app constants.
class AppConstants {
  const AppConstants._();

  static const String appName = 'CreatorPilot AI';
  static const int freePlanQueryLimit = 3;
  static const String defaultPeriod = '7d';
}
