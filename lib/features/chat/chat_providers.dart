import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/providers/auth_providers.dart';
import '../dashboard/data/dashboard_repository_impl.dart';
import '../dashboard/domain/entities/ask_result.dart';

/// A single chat message (user or AI).
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isError = false,
    this.timestamp,
  });

  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isError;
  final DateTime? timestamp;
}

/// Manages the list of chat messages.
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(ref),
);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this.ref) : super([]);

  final Ref ref;

  /// Send a message and get AI response.
  Future<void> sendMessage(String text) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    // Add user message
    state = [
      ...state,
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    // Add loading placeholder
    state = [
      ...state,
      const ChatMessage(text: '', isUser: false, isLoading: true),
    ];

    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final result = await repo.executeQuery(
        userId: user.userId,
        channelId: user.channelId,
        message: text,
      );

      // Refresh usage counter
      ref.read(authStateProvider.notifier).refreshStatus();

      // Replace loading with actual response
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          text: result.answer,
          isUser: false,
          isError: !result.success,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Replace loading with error
      state = [
        ...state.where((m) => !m.isLoading),
        ChatMessage(
          text: 'Something went wrong. Please try again.',
          isUser: false,
          isError: true,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  void clear() {
    state = [];
  }
}
