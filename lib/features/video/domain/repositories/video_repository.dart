import '../entities/video_analysis.dart';

/// Abstract contract for video analysis operations.
abstract class VideoRepository {
  Future<VideoAnalysis> analyzeVideo({
    required String userId,
    required String channelId,
    required String videoId,
  });
}
