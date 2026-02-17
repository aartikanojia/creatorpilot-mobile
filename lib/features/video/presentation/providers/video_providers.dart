import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/video_repository_impl.dart';
import '../../domain/entities/video_analysis.dart';

/// Provider family for video analysis — keyed by video ID.
final videoAnalysisProvider =
    FutureProvider.family<VideoAnalysis, String>((ref, videoId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) throw Exception('Not authenticated');

  final repo = ref.watch(videoRepositoryProvider);
  final result = await repo.analyzeVideo(
    userId: user.userId,
    channelId: user.channelId,
    videoId: videoId,
  );

  // Refresh usage status after analysis query
  ref.read(authStateProvider.notifier).refreshStatus();

  return result;
});
