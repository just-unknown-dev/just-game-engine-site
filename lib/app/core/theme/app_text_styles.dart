import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized text styles for the Just Game Engine website.
abstract final class AppTextStyles {
  // ── Display / Hero ─────────────────────────────────────────
  static TextStyle displayLarge = GoogleFonts.majorMonoDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 2,
  );

  static TextStyle displayMedium = GoogleFonts.majorMonoDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 1.5,
  );

  static TextStyle displaySmall = GoogleFonts.majorMonoDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 1,
  );

  // ── Headings ──────────────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ── Code ──────────────────────────────────────────────────
  static TextStyle code = GoogleFonts.firaCode(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle codeSmall = GoogleFonts.firaCode(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Navigation ────────────────────────────────────────────
  static TextStyle navLink = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle navLinkActive = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: 0.5,
  );

  // ── Buttons ───────────────────────────────────────────────
  static TextStyle buttonPrimary = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.8,
  );

  static TextStyle buttonSecondary = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    letterSpacing: 0.8,
  );

  // ── Labels / Chips ────────────────────────────────────────
  static TextStyle label = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );
}
