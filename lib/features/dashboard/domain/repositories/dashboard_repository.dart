import '../entities/channel_stats.dart';
import '../entities/top_video.dart';
import '../entities/ask_result.dart';

/// Abstract contract for dashboard data operations.
abstract class DashboardRepository {
  Future<ChannelStats> getChannelStats(String userId, {String period = '7d'});
  Future<TopVideo> getTopVideo(String userId, {String period = '7d'});
  Future<AskResult> executeQuery({
    required String userId,
    required String channelId,
    required String message,
  });
}
