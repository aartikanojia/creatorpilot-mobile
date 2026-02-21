import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/animated_typing_indicator.dart';
import '../../shared/widgets/rotating_status_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/presentation/providers/auth_providers.dart';
import '../premium/presentation/screens/upgrade_modal.dart';
import 'chat_providers.dart';

/// Full-screen AI assistant chat interface.
///
/// Features:
/// - Scrollable message list with modern bubbles
/// - Vertical suggestion cards for empty state
/// - Per-AI-message 👍 👎 📋 action bar
/// - Input field pinned to bottom
/// - Usage counter in header
/// - Upgrade CTA when limit exhausted
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _suggestions = [
    (icon: Icons.play_circle_outline_rounded, text: 'Analyze my last video'),
    (icon: Icons.bar_chart_rounded, text: 'Weekly channel summary'),
    (icon: Icons.rocket_launch_rounded, text: 'How can I grow faster?'),
    (icon: Icons.upload_file_rounded, text: 'What should I upload next?'),
    (icon: Icons.emoji_events_rounded, text: 'Why did this video perform best?'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    ref.read(chatMessagesProvider.notifier).sendMessage(trimmed);
    _controller.clear();

    // Scroll to bottom after message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UpgradeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final isPro = user?.isPro ?? false;
    final isExhausted = !isPro && (user?.isLimitExhausted ?? false);

    return Column(
      children: [
        // ── Usage Counter / PRO Badge ─────────────────────────────
        if (user != null)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: isPro
                // PRO: show badge only, no counter
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.accentGradient,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PRO • Unlimited',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                // FREE: show usage counter
                : Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: isExhausted ? AppColors.error : AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isExhausted
                            ? 'Limit reached'
                            : '${user.queriesUsed} / ${user.queryLimit} queries used',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isExhausted
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (isExhausted)
                        GestureDetector(
                          onTap: _showUpgradeModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.accentGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Upgrade',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

        const Divider(color: AppColors.divider, height: 1),

        // ── Messages or Empty State ───────────────────────────────
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyState(isExhausted)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: messages[index],
                    index: index,
                  ),
                ),
        ),

        // ── Input Box ─────────────────────────────────────────────
        _ChatInput(
          controller: _controller,
          isDisabled: isExhausted,
          isLoading: messages.isNotEmpty && messages.last.isLoading,
          onSubmit: _submit,
          onUpgradeTap: _showUpgradeModal,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isExhausted) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.accentGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI Assistant',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ask anything about your channel\nperformance and growth strategy',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Suggestion Cards ─────────────────────────────────────
          if (!isExhausted) ...[
            Text(
              'Suggested queries',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_suggestions.length, (i) {
              final s = _suggestions[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < _suggestions.length - 1 ? 10 : 0,
                ),
                child: _SuggestionCard(
                  icon: s.icon,
                  text: s.text,
                  onTap: () => _submit(s.text),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Suggestion Card ─────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ──────────────────────────────────────────────────────

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({
    required this.message,
    required this.index,
  });

  final ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content;

    if (message.isLoading) {
      content = Padding(
        key: const ValueKey('loading'),
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTypingIndicator(),
                SizedBox(height: 12),
                RotatingStatusText(),
              ],
            ),
          ),
        ),
      );
    } else {
      final isUser = message.isUser;

      content = Padding(
        key: const ValueKey('loaded'),
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── Bubble ────────────────────────────────────────────
            Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.82,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : AppColors.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 16 : 4),
                      topRight: Radius.circular(isUser ? 4 : 16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.border),
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        )
                      : _buildRichMessageBody(message),
              ),
            ),
          ),

          // ── Action Row (AI only) ───────────────────────────────
          if (!isUser) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thumbs Up
                  _ActionIconButton(
                    icon: message.isLiked
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_outlined,
                    color: message.isLiked
                        ? Colors.greenAccent
                        : AppColors.textMuted,
                    tooltip: 'Helpful',
                    onTap: () => ref
                        .read(chatMessagesProvider.notifier)
                        .toggleLike(index),
                  ),
                  const SizedBox(width: 4),
                  // Thumbs Down
                  _ActionIconButton(
                    icon: message.isDisliked
                        ? Icons.thumb_down_rounded
                        : Icons.thumb_down_outlined,
                    color: message.isDisliked
                        ? Colors.redAccent
                        : AppColors.textMuted,
                    tooltip: 'Not helpful',
                    onTap: () => ref
                        .read(chatMessagesProvider.notifier)
                        .toggleDislike(index),
                  ),
                  const SizedBox(width: 4),
                  // Copy
                  _ActionIconButton(
                    icon: Icons.copy_rounded,
                    color: AppColors.textMuted,
                    tooltip: 'Copy',
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: message.text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.greenAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Copied to clipboard',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: AppColors.border, width: 1),
                              ),
                              backgroundColor: const Color(0xFF1E1E2C),
                              elevation: 8,
                            ),
                          );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 10),
        ],
      ),
    );
  }

  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 400),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.fastOutSlowIn,
    transitionBuilder: (child, animation) {
      return FadeTransition(opacity: animation, child: child);
    },
    child: content,
  );
}

  /// Parses markdown-style **bold** headings and renders them with
  /// stronger typography while keeping body text clean.
  static Widget _buildRichMessageBody(ChatMessage message) {
    final textColor =
        message.isError ? AppColors.error : AppColors.textPrimary;
    final lines = message.text.split('\n');

    final headingPattern = RegExp(r'^\*\*(.+)\*\*$');
    final inlineBoldPattern = RegExp(r'\*\*(.+?)\*\*');

    final children = <Widget>[];
    bool previousWasHeading = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip empty lines but add spacing
      if (line.isEmpty) {
        if (children.isNotEmpty && !previousWasHeading) {
          children.add(const SizedBox(height: 6));
        }
        previousWasHeading = false;
        continue;
      }

      // Full-line heading: **Heading Text**
      final headingMatch = headingPattern.firstMatch(line);
      if (headingMatch != null) {
        final headingText = headingMatch.group(1)!;
        children.add(
          Padding(
            padding: EdgeInsets.only(
              top: children.isNotEmpty ? 20 : 0,
              bottom: 8,
            ),
            child: Text(
              headingText,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        );
        previousWasHeading = true;
        continue;
      }

      // Body line — may contain inline **bold** fragments
      if (inlineBoldPattern.hasMatch(line)) {
        final spans = <InlineSpan>[];
        int lastEnd = 0;

        for (final match in inlineBoldPattern.allMatches(line)) {
          if (match.start > lastEnd) {
            spans.add(TextSpan(
              text: line.substring(lastEnd, match.start),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                color: textColor,
                height: 1.5,
              ),
            ));
          }
          spans.add(TextSpan(
            text: match.group(1),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.5,
            ),
          ));
          lastEnd = match.end;
        }

        if (lastEnd < line.length) {
          spans.add(TextSpan(
            text: line.substring(lastEnd),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              color: textColor,
              height: 1.5,
            ),
          ));
        }

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(text: TextSpan(children: spans)),
          ),
        );
      } else {
        // Plain body text
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        );
      }
      previousWasHeading = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ── Action Icon Button ──────────────────────────────────────────────────

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ── Chat Input ──────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.isDisabled,
    required this.isLoading,
    required this.onSubmit,
    required this.onUpgradeTap,
  });

  final TextEditingController controller;
  final bool isDisabled;
  final bool isLoading;
  final void Function(String) onSubmit;
  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: isDisabled
          ? _buildUpgradeCTA()
          : Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: !isLoading,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about your channel...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 10, top: 10, bottom: 10),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFE0E0E0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                                bottomLeft: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2), // visually center dots
                                child: Icon(
                                  Icons.more_horiz,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (t) => onSubmit(t),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isLoading ? null : () => onSubmit(controller.text),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUpgradeCTA() {
    return GestureDetector(
      onTap: onUpgradeTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.accent.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: AppColors.warning, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Free queries exhausted',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Upgrade to PRO for unlimited insights',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.accentGradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Upgrade',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
