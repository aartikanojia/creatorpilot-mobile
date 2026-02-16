import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/presentation/providers/auth_providers.dart';
import '../dashboard/presentation/screens/dashboard_screen.dart';
import '../chat/chat_screen.dart';

/// Tab index provider for persistence across rebuilds.
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Shell widget with bottom navigation bar.
///
/// Uses [IndexedStack] to preserve state when switching tabs.
/// Tabs:
///   0 – Dashboard (stats, top video)
///   1 – AI Assistant (chat interface)
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      // ── AppBar ──────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CreatorPilot',
              style: AppTextStyles.headlineMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textMuted,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),

      // ── Body (IndexedStack preserves tab state) ─────────────────
      body: IndexedStack(
        index: currentIndex,
        children: const [
          DashboardScreen(),
          ChatScreen(),
        ],
      ),

      // ── Bottom Navigation ───────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded),
              activeIcon: Icon(Icons.smart_toy_rounded),
              label: 'Assistant',
            ),
          ],
        ),
      ),
    );
  }
}
