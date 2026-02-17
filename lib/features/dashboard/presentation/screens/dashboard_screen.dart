import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../premium/presentation/screens/upgrade_modal.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/welcome_header.dart';
import '../widgets/usage_badge.dart';
import '../widgets/top_video_card.dart';

/// Dashboard tab — stats, top video, channel overview.
///
/// No AI chat here; that lives in [ChatScreen].
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final channelStats = ref.watch(channelStatsProvider);
    final topVideo = ref.watch(topVideoProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        title: 'Session Error',
        message: 'Unable to load your profile.',
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false, // AppBar already handles top safe area
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Welcome header ──────────────────────────────
                      WelcomeHeader(
                        channelName: user.channelName,
                        plan: user.plan,
                      ),
                      const SizedBox(height: 16),

                      // ── Usage badge ─────────────────────────────────
                      UsageBadge(
                        used: user.queriesUsed,
                        limit: user.queryLimit,
                        isExhausted: user.isLimitExhausted,
                        onUpgradeTap: () => _showUpgradeModal(context),
                      ),
                      const SizedBox(height: 24),

                      // ── Channel Stats Row ───────────────────────────
                      channelStats.when(
                        loading: () => _buildStatsSkeleton(),
                        error: (e, _) => const SizedBox.shrink(),
                        data: (stats) => _buildStatsRow(stats),
                      ),
                      const SizedBox(height: 24),

                      // ── Top Performing Video (compact) ──────────────
                      Text(
                        'Top Performing Video',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      topVideo.when(
                        loading: () => const LoadingSkeleton(
                          width: double.infinity,
                          height: 180,
                          borderRadius: 16,
                        ),
                        error: (e, _) => ErrorState(
                          title: 'Could not load video',
                          message: 'Pull to refresh.',
                          onRetry: () => ref.invalidate(topVideoProvider),
                        ),
                        data: (video) => TopVideoCard(
                          video: video,
                          compact: true,
                          onTap: video.isAvailable
                              ? () => context.push(
                                    '/video/${video.videoId}'
                                    '?title=${Uri.encodeComponent(video.title ?? '')}'
                                    '&thumbnail=${Uri.encodeComponent(video.thumbnailUrl ?? '')}',
                                  )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsSkeleton() {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
            child: const LoadingSkeleton(
              width: double.infinity,
              height: 80,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(dynamic stats) {
    return Row(
      children: [
        _StatTile(
          label: 'Subscribers',
          value: NumberFormatter.compact(stats.subscriberCount),
          icon: Icons.people_outline_rounded,
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: 'Views',
          value: NumberFormatter.compact(stats.viewCount),
          icon: Icons.visibility_outlined,
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: 'Videos',
          value: NumberFormatter.compact(stats.videoCount),
          icon: Icons.video_library_outlined,
        ),
      ],
    );
  }

  void _showUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UpgradeModal(),
    );
  }
}

/// Small KPI stat tile for the dashboard.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryLight),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
