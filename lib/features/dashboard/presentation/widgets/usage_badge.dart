import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Usage badge showing query consumption (e.g., "1/3 free").
///
/// Changes color when limit is approaching or exhausted.
class UsageBadge extends StatelessWidget {
  const UsageBadge({
    super.key,
    required this.used,
    required this.limit,
    required this.isExhausted,
    this.onUpgradeTap,
  });

  final int used;
  final int limit;
  final bool isExhausted;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color progressColor;

    if (isExhausted) {
      bgColor = AppColors.error.withOpacity(0.12);
      textColor = AppColors.error;
      progressColor = AppColors.error;
    } else if (used >= limit - 1) {
      bgColor = AppColors.warning.withOpacity(0.12);
      textColor = AppColors.warning;
      progressColor = AppColors.warning;
    } else {
      bgColor = AppColors.accent.withOpacity(0.12);
      textColor = AppColors.accent;
      progressColor = AppColors.accent;
    }

    return GestureDetector(
      onTap: isExhausted ? onUpgradeTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: progressColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: limit > 0 ? used / limit : 0,
                    strokeWidth: 3,
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                  Text(
                    '$used',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExhausted ? 'Limit reached' : '$used / $limit queries',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isExhausted)
                  Text(
                    'Tap to upgrade',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
