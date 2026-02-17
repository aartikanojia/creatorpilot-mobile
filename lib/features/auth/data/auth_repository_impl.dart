import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

/// Provides [AuthRepositoryImpl] to the presentation layer.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(authService: ref.watch(authServiceProvider));
});

/// Concrete implementation of [AuthRepository].
///
/// Delegates all I/O to [AuthService] (API calls + secure storage).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.authService});

  final AuthService authService;

  @override
  Future<bool> isLoggedIn() => authService.isLoggedIn();

  @override
  Future<User?> getStoredUser() async {
    final userId = await authService.getStoredUserId();
    if (userId == null || userId.isEmpty) return null;

    final channelId = await authService.getStoredChannelId() ?? '';
    final channelName = await authService.getStoredChannelName() ?? '';

    return User(
      userId: userId,
      channelId: channelId,
      channelName: channelName,
    );
  }

  @override
  Future<String> getAuthUrl(String userId) {
    return authService.getAuthUrl(userId);
  }

  @override
  Future<void> saveSession({
    required String userId,
    required String channelId,
    required String channelName,
  }) {
    return authService.saveSession(
      userId: userId,
      channelId: channelId,
      channelName: channelName,
    );
  }

  @override
  Future<User> refreshUserStatus(String userId) async {
    final status = await authService.getUserStatus(userId);
    final usage = status['usage'] as Map<String, dynamic>? ?? {};

    final channelId = await authService.getStoredChannelId() ?? '';
    final channelName = await authService.getStoredChannelName() ?? '';

    return User(
      userId: userId,
      channelId: channelId,
      channelName: channelName,
      plan: status['user_plan'] as String? ?? 'free',
      queriesUsed: usage['used'] as int? ?? 0,
      queryLimit: usage['limit'] as int? ?? 3,
      isLimitExhausted: usage['exhausted'] as bool? ?? false,
    );
  }

  @override
  Future<void> logout() => authService.logout();
}
