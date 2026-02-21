import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/providers/auth_providers.dart';
import '../dashboard/data/dashboard_repository_impl.dart';


/// A single chat message (user or AI).
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isError = false,
    this.isLiked = false,
    this.isDisliked = false,
    this.timestamp,
  });

  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isError;
  final bool isLiked;
  final bool isDisliked;
  final DateTime? timestamp;

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isLoading,
    bool? isError,
    bool? isLiked,
    bool? isDisliked,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      timestamp: timestamp ?? this.timestamp,
    );
  }
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

  /// Toggle like for a message at [index]. Clears dislike.
  void toggleLike(int index) {
    final messages = List<ChatMessage>.from(state);
    final msg = messages[index];
    messages[index] = msg.copyWith(
      isLiked: !msg.isLiked,
      isDisliked: false,
    );
    state = messages;
  }

  /// Toggle dislike for a message at [index]. Clears like.
  void toggleDislike(int index) {
    final messages = List<ChatMessage>.from(state);
    final msg = messages[index];
    messages[index] = msg.copyWith(
      isDisliked: !msg.isDisliked,
      isLiked: false,
    );
    state = messages;
  }

  void clear() {
    state = [];
  }
}
