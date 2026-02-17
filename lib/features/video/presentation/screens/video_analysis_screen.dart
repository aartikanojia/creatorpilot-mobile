import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../providers/video_providers.dart';

/// Video analysis detail screen.
///
/// Shows:
/// - Hero thumbnail
/// - Video title
/// - AI-generated performance analysis broken into cards
class VideoAnalysisScreen extends ConsumerWidget {
  const VideoAnalysisScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
  });

  final String videoId;
  final String title;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(videoAnalysisProvider(videoId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.scaffoldBg,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: thumbnailUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.cardBgElevated,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.cardBgElevated,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textMuted,
                              size: 48,
                            ),
                          ),
                        ),
                        // Gradient overlay for readability
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC0A0A0F),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.cardBgElevated,
                      child: const Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Video title
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Analysis content
                analysis.when(
                  loading: () => Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LoadingSkeleton(
                          width: double.infinity,
                          height: 100,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    title: 'Analysis Failed',
                    message: 'Could not analyze this video.',
                    onRetry: () =>
                        ref.invalidate(videoAnalysisProvider(videoId)),
                  ),
                  data: (result) {
                    if (!result.success) {
                      return ErrorState(
                        title: result.isPlanLimitReached
                            ? 'Limit Reached'
                            : 'Analysis Error',
                        message: result.isPlanLimitReached
                            ? 'Upgrade to PRO for unlimited video analysis.'
                            : 'Something went wrong during analysis.',
                      );
                    }

                    return _buildAnalysisCards(result.answer);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse the AI answer into logical sections and display as cards.
  ///
  /// Splits on double newlines to create visual separation.
  Widget _buildAnalysisCards(String answer) {
    // Split answer into paragraphs/sections
    final sections = answer
        .split(RegExp(r'\n{2,}'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (sections.isEmpty) {
      return PremiumCard(
        child: Text(
          answer.isNotEmpty ? answer : 'No analysis available.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      );
    }

    // Map sections to insight cards
    final cardIcons = [
      Icons.insights_rounded,
      Icons.trending_up_rounded,
      Icons.lightbulb_outline_rounded,
      Icons.tips_and_updates_outlined,
      Icons.auto_awesome_rounded,
    ];

    final cardLabels = [
      'Performance Snapshot',
      'Growth Signals',
      'Recommendations',
      'Insights',
      'Analysis',
    ];

    return Column(
      children: List.generate(sections.length, (i) {
        final icon = cardIcons[i % cardIcons.length];
        final label = i < cardLabels.length
            ? cardLabels[i]
            : cardLabels[i % cardLabels.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: AppColors.primaryLight),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  sections[i].trim(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
