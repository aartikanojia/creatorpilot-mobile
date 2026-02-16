import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../domain/entities/ask_result.dart';

/// Overlay result panel showing AI response after a query.
///
/// Displays the answer text with clean formatting.
/// Shows error states for plan limits and failures.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.result,
    this.onDismiss,
    this.onUpgradeTap,
  });

  final AskResult result;
  final VoidCallback? onDismiss;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    if (result.isPlanLimitReached) {
      return _buildLimitReachedPanel();
    }

    if (!result.success) {
      return _buildErrorPanel();
    }

    return _buildSuccessPanel();
  }

  Widget _buildSuccessPanel() {
    return PremiumCard(
      useGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Insight',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Answer
          Text(
            result.answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.7,
            ),
          ),

          // Confidence bar (subtle)
          if (result.confidence > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.confidence,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        result.confidence > 0.7
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(result.confidence * 100).toInt()}% confidence',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLimitReachedPanel() {
    return PremiumCard(
      child: Column(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 40,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            'Free limit reached',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Upgrade to PRO for unlimited queries and deeper insights.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onUpgradeTap != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradeTap,
                child: const Text('Upgrade to PRO'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorPanel() {
    return PremiumCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not process your query',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'An error occurred while analyzing. Please try again.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onDismiss,
              child: const Text('Dismiss'),
            ),
          ],
        ],
      ),
    );
  }
}
