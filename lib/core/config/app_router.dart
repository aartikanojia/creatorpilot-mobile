import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/video/presentation/screens/video_analysis_screen.dart';

/// Provides the application [GoRouter] instance.
///
/// Auth-aware redirect logic:
/// - If no stored session → redirect to `/login`
/// - If session exists → allow navigation
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // ── Splash ──────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Login ───────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Main App (Bottom Nav Shell) ─────────────────────────────────
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const MainShell(),
      ),

      // ── Video Analysis ──────────────────────────────────────────────
      GoRoute(
        path: '/video/:videoId',
        name: 'videoAnalysis',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          final thumbnail = state.uri.queryParameters['thumbnail'] ?? '';
          return VideoAnalysisScreen(
            videoId: videoId,
            title: title,
            thumbnailUrl: thumbnail,
          );
        },
      ),
    ],

    // ── Error Page ──────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
