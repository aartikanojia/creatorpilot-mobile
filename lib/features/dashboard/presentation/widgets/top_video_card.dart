import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../domain/entities/top_video.dart';

/// Card displaying the top-performing video with thumbnail and stats.
///
/// Tapping navigates to the video analysis screen.
/// When [compact] is true, the thumbnail is constrained to 180px height
/// and text is more space-efficient for the dashboard layout.
class TopVideoCard extends StatelessWidget {
  const TopVideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.compact = false,
  });

  final TopVideo video;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!video.isAvailable) {
      return PremiumCard(
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No video data available',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Thumbnail ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: SizedBox(
              height: compact ? 140 : null,
              width: double.infinity,
              child: video.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.cardBgElevated,
                        child: const Center(
                          child: LoadingSkeleton(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 0,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.cardBgElevated,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      height: compact ? 140 : 200,
                      color: AppColors.cardBgElevated,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                    ),
            ),
          ),

          // ── Info ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most watched this week',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontSize: compact ? 11 : null,
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  video.title ?? 'Untitled',
                  style: compact
                      ? AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : AppTextStyles.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 6 : 10),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.visibility_outlined,
                      label: _formatViews(video.views),
                    ),
                    const SizedBox(width: 16),
                    if (video.growthPercentage != 0)
                      _StatChip(
                        icon: video.growthPercentage > 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        label:
                            '${video.growthPercentage > 0 ? '+' : ''}${video.growthPercentage.toStringAsFixed(1)}%',
                        color: video.growthPercentage > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    if (!compact) ...[
                      const Spacer(),
                      Text(
                        'Tap to analyze',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    return '${NumberFormatter.compact(views)} views';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: chipColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: chipColor),
        ),
      ],
    );
  }
}
