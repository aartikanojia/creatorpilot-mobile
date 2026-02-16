import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/video_service.dart';
import '../domain/entities/video_analysis.dart';
import '../domain/repositories/video_repository.dart';

/// Provides [VideoRepositoryImpl].
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(videoService: ref.watch(videoServiceProvider));
});

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({required this.videoService});

  final VideoService videoService;

  @override
  Future<VideoAnalysis> analyzeVideo({
    required String userId,
    required String channelId,
    required String videoId,
  }) async {
    final data = await videoService.executeQuery(
      userId: userId,
      channelId: channelId,
      message: 'Analyze this video: $videoId — give me performance insights, growth signals, and actionable recommendations.',
    );
    return VideoAnalysis.fromJson(data);
  }
}
