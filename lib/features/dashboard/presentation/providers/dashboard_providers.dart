import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/dashboard_repository_impl.dart';
import '../../domain/entities/channel_stats.dart';
import '../../domain/entities/top_video.dart';
import '../../domain/entities/ask_result.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Fetches channel stats on mount. Re-fetches when auth state changes.
final channelStatsProvider = FutureProvider<ChannelStats>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) throw Exception('Not authenticated');

  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getChannelStats(user.userId);
});

/// Fetches the top video on mount.
final topVideoProvider = FutureProvider<TopVideo>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) throw Exception('Not authenticated');

  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getTopVideo(user.userId);
});

/// Manages the AI Ask flow with loading/result states.
final askResultProvider =
    AsyncNotifierProvider<AskResultNotifier, AskResult?>(AskResultNotifier.new);

class AskResultNotifier extends AsyncNotifier<AskResult?> {
  @override
  Future<AskResult?> build() async {
    return null; // No result initially
  }

  /// Submit an AI query and update state.
  Future<void> submitQuery(String message) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(dashboardRepositoryProvider);
      final result = await repo.executeQuery(
        userId: user.userId,
        channelId: user.channelId,
        message: message,
      );

      // Refresh user status after query (updates usage counter)
      ref.read(authStateProvider.notifier).refreshStatus();

      return result;
    });
  }

  /// Clear the current result (dismiss panel).
  void clearResult() {
    state = const AsyncData(null);
  }
}
