import 'package:flutter/material.dart';

/// Centralized color palette for the Just Game Engine website.
abstract final class AppColors {
  // ── Background gradient stops ─────────────────────────────────
  static const Color bgDark = Color(0xFF07070F);
  static const Color bgMid = Color(0xFF0C0C1C);
  static const Color bgLight = Color(0xFF060610);

  // ── Surface / card ────────────────────────────────────────────
  static const Color surface = Color(0xFF111122);
  static const Color surfaceVariant = Color(0xFF181830);
  static const Color surfaceBright = Color(0xFF1E1E3A);

  // ── Accent ────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF5746F);
  static const Color accentLight = Color(0xFFF99B97);
  static const Color accentDim = Color(0xFFB85450);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE0E0E8);
  static const Color textSecondary = Color(0xFF9E9EB8);
  static const Color textMuted = Color(0xFF6E6E88);

  // ── Borders ───────────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A44);
  static const Color borderBright = Color(0xFF3A3A5A);

  // ── Code blocks ───────────────────────────────────────────────
  static const Color codeBg = Color(0xFF0D0D1A);
  static const Color codeBorder = Color(0xFF2A2A44);

  // ── Misc ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}
