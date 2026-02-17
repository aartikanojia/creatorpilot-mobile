import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import 'api_client.dart';

/// Provides [AnalyticsService] with injected Dio client.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(dio: ref.watch(apiClientProvider));
});

/// Service for fetching YouTube channel analytics data.
///
/// Proxies to the backend's channel endpoints which in turn
/// query the MCP server for real YouTube data.
class AnalyticsService {
  AnalyticsService({required this.dio});

  final Dio dio;

  /// Fetch channel statistics (subscribers, views, watch time, daily chart).
  ///
  /// Returns raw JSON map with keys:
  /// `subscriberCount`, `viewCount`, `videoCount`,
  /// `avgWatchTimeMinutes`, `dailyViews`
  Future<Map<String, dynamic>> getChannelStats({
    required String userId,
    String period = '7d',
  }) async {
    final response = await dio.get(
      ApiPaths.channelStats,
      queryParameters: {
        'user_id': userId,
        'period': period,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Fetch the top-performing video for the period.
  ///
  /// Returns raw JSON map with keys:
  /// `video_id`, `title`, `thumbnail_url`, `views`, `growth_percentage`
  Future<Map<String, dynamic>> getTopVideo({
    required String userId,
    String period = '7d',
  }) async {
    final response = await dio.get(
      ApiPaths.channelTopVideo,
      queryParameters: {
        'user_id': userId,
        'period': period,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
