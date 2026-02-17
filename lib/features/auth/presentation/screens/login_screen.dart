import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../services/google_auth_service.dart';
import '../providers/auth_providers.dart';

/// Login screen with YouTube OAuth connection.
///
/// Displays branding and a "Connect with YouTube" button.
/// Tapping the button opens the native OAuth consent sheet via flutter_appauth.
/// After authorization, the code is sent to the backend for exchange.
/// On success, the user session is saved and navigation goes to the dashboard.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  /// Perform native OAuth via flutter_appauth.
  ///
  /// 1. Show loading spinner
  /// 2. Call GoogleAuthService.login() (native OAuth → backend code exchange)
  /// 3. Save session via AuthStateNotifier
  /// 4. Navigate to dashboard with success toast
  Future<void> _connectYouTube() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Native OAuth + backend exchange
      final googleAuth = ref.read(googleAuthServiceProvider);
      final result = await googleAuth.login();

      // Step 2: Save session and refresh user status
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.login(
        userId: result['user_id']!,
        channelId: result['channel_id']!,
        channelName: result['channel_name']!,
      );

      if (mounted) {
        // Step 3: Success toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('YouTube Connected Successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Step 4: Navigate to dashboard
        context.go('/dashboard');
      }
    } on GoogleAuthException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to connect: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo ──────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────
              Text(
                'CreatorPilot',
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered insights for\nyour YouTube channel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // ── Features list ─────────────────────────────────────
              _FeatureRow(
                icon: Icons.analytics_outlined,
                text: 'Real-time channel analytics',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.lightbulb_outline_rounded,
                text: 'AI-driven growth recommendations',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.video_library_outlined,
                text: 'Video performance breakdown',
              ),

              const Spacer(flex: 1),

              // ── Connect Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _connectYouTube,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000), // YouTube red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                size: 24, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'Connect with YouTube',
                              style: AppTextStyles.button,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Terms ─────────────────────────────────────────────
              Text(
                'By connecting, you agree to our Terms of Service\nand Privacy Policy',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single feature row for the login screen.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryLight),
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
      ],
    );
  }
}
