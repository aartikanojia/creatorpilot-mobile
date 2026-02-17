import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Tracks authentication state across the app.
///
/// - `AsyncLoading` → checking stored session
/// - `AsyncData(User)` → logged in
/// - `AsyncData(null)` → not logged in
/// - `AsyncError` → session check failed
final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, User?>(AuthStateNotifier.new);

class AuthStateNotifier extends AsyncNotifier<User?> {
  late final AuthRepository _repo;

  @override
  Future<User?> build() async {
    _repo = ref.watch(authRepositoryProvider);
    final isLoggedIn = await _repo.isLoggedIn();
    if (!isLoggedIn) return null;

    final user = await _repo.getStoredUser();
    if (user == null) return null;

    // Fetch live plan status from backend
    try {
      return await _repo.refreshUserStatus(user.userId);
    } catch (_) {
      // Fail-open: return cached user without live status
      return user;
    }
  }

  /// Save session after successful OAuth and refresh state.
  Future<void> login({
    required String userId,
    required String channelId,
    required String channelName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.saveSession(
        userId: userId,
        channelId: channelId,
        channelName: channelName,
      );
      return _repo.refreshUserStatus(userId);
    });
  }

  /// Refresh user status (called after executing a query to update usage).
  Future<void> refreshStatus() async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    try {
      final updated = await _repo.refreshUserStatus(currentUser.userId);
      state = AsyncData(updated);
    } catch (_) {
      // Silently fail — don't disrupt UX for a status refresh
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }
}
