import 'dart:ui';

/// Curated color palette for CreatorPilot.
///
/// Dark-mode-first, premium aesthetic with vibrant accents.
/// No default Material colors — every shade is intentional.
class AppColors {
  const AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF0F0F14);
  static const Color cardBg = Color(0xFF1A1A24);
  static const Color cardBgElevated = Color(0xFF22222E);

  // ── Primary (deep violet) ───────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9B5DE5);
  static const Color primaryDark = Color(0xFF5B21B6);

  // ── Accent (electric cyan) ──────────────────────────────────────────
  static const Color accent = Color(0xFF22D3EE);
  static const Color accentMuted = Color(0xFF155E75);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F1F4);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Borders & Dividers ──────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A3A);
  static const Color divider = Color(0xFF1F1F2E);

  // ── Gradients ───────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF4F46E5),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF06B6D4),
    Color(0xFF7C3AED),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1A1A24),
    Color(0xFF12121A),
  ];
}
