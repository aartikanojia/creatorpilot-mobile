import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AI Ask input box at the bottom of the dashboard.
///
/// Handles text input, submit, and auto-disables when limit is exhausted.
class AskBox extends StatefulWidget {
  const AskBox({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final void Function(String message) onSubmit;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<AskBox> createState() => _AskBoxState();
}

class _AskBoxState extends State<AskBox> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading || widget.isDisabled) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isDisabled,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.isDisabled
                      ? 'Upgrade to PRO to continue...'
                      : 'Ask about your channel...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: widget.isDisabled
                        ? AppColors.error.withOpacity(0.6)
                        : AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: widget.isDisabled
                  ? null
                  : const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: widget.isDisabled ? AppColors.cardBg : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: widget.isDisabled || widget.isLoading ? null : _submit,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 22,
                          color: widget.isDisabled
                              ? AppColors.textMuted
                              : Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
