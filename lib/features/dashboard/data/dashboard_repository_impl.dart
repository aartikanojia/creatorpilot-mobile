import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/analytics_service.dart';
import '../../../services/video_service.dart';
import '../domain/entities/channel_stats.dart';
import '../domain/entities/top_video.dart';
import '../domain/entities/ask_result.dart';
import '../domain/repositories/dashboard_repository.dart';

/// Provides [DashboardRepositoryImpl] with injected services.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    analyticsService: ref.watch(analyticsServiceProvider),
    videoService: ref.watch(videoServiceProvider),
  );
});

/// Concrete implementation of [DashboardRepository].
///
/// Maps raw API responses to domain entities.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required this.analyticsService,
    required this.videoService,
  });

  final AnalyticsService analyticsService;
  final VideoService videoService;

  @override
  Future<ChannelStats> getChannelStats(String userId, {String period = '7d'}) async {
    final data = await analyticsService.getChannelStats(
      userId: userId,
      period: period,
    );
    return ChannelStats.fromJson(data);
  }

  @override
  Future<TopVideo> getTopVideo(String userId, {String period = '7d'}) async {
    final data = await analyticsService.getTopVideo(
      userId: userId,
      period: period,
    );
    return TopVideo.fromJson(data);
  }

  @override
  Future<AskResult> executeQuery({
    required String userId,
    required String channelId,
    required String message,
  }) async {
    final data = await videoService.executeQuery(
      userId: userId,
      channelId: channelId,
      message: message,
    );
    return AskResult.fromJson(data);
  }
}
