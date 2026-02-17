import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import 'api_client.dart';

/// Provides [VideoService] with injected Dio client.
final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService(dio: ref.watch(apiClientProvider));
});

/// Service for AI-powered video analysis via the /execute endpoint.
///
/// Sends user queries to the MCP orchestration layer, which dispatches
/// to the appropriate tools (analytics, recommendations, etc.).
class VideoService {
  VideoService({required this.dio});

  final Dio dio;

  /// Execute an AI query against the user's channel data.
  ///
  /// [userId] – authenticated user's UUID
  /// [channelId] – YouTube channel ID
  /// [message] – the user's natural language query
  /// [metadata] – optional context (e.g., `{ "user_plan": "PRO" }`)
  ///
  /// Returns the full [ExecuteResponse] as a map:
  /// `answer`, `confidence`, `tools_used`, `content_type`, `error`
  Future<Map<String, dynamic>> executeQuery({
    required String userId,
    required String channelId,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await dio.post(
      ApiPaths.execute,
      data: {
        'user_id': userId,
        'channel_id': channelId,
        'message': message,
        if (metadata != null) 'metadata': metadata,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
