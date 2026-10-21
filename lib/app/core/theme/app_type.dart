import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/responsive.dart';
import 'app_palette.dart';

/// The site's text styles, coloured for the current theme.
///
/// Headings use Space Grotesk, body text Inter, code Fira Code, and the
/// brand wordmark Major Mono Display. Read them with `context.type`.
class AppType {
  AppType(this.p, {required this.compact});

  final AppPalette p;

  /// True below the tablet breakpoint: large headings shrink.
  final bool compact;

  // ── Brand ─────────────────────────────────────────────────────
  TextStyle get wordmark => GoogleFonts.majorMonoDisplay(
    fontSize: 16,
    color: p.textPrimary,
    letterSpacing: 0.5,
  );

  // ── Headings ──────────────────────────────────────────────────
  TextStyle get display => GoogleFonts.spaceGrotesk(
    fontSize: compact ? 38 : 60,
    fontWeight: FontWeight.w700,
    height: 1.06,
    letterSpacing: compact ? -0.8 : -1.6,
    color: p.textPrimary,
  );

  TextStyle get h1 => GoogleFonts.spaceGrotesk(
    fontSize: compact ? 32 : 44,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: compact ? -0.5 : -1.0,
    color: p.textPrimary,
  );

  TextStyle get h2 => GoogleFonts.spaceGrotesk(
    fontSize: compact ? 26 : 34,
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -0.6,
    color: p.textPrimary,
  );

  TextStyle get h3 => GoogleFonts.spaceGrotesk(
    fontSize: compact ? 19 : 21,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: p.textPrimary,
  );

  TextStyle get h4 => GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: p.textPrimary,
  );

  TextStyle get stat => GoogleFonts.spaceGrotesk(
    fontSize: compact ? 28 : 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    color: p.accentText,
  );

  // ── Body ──────────────────────────────────────────────────────
  TextStyle get lead => GoogleFonts.inter(
    fontSize: compact ? 16.5 : 18.5,
    height: 1.6,
    color: p.textSecondary,
  );

  TextStyle get body =>
      GoogleFonts.inter(fontSize: 16, height: 1.7, color: p.textSecondary);

  TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 14.5, height: 1.6, color: p.textSecondary);

  TextStyle get caption =>
      GoogleFonts.inter(fontSize: 13, height: 1.5, color: p.textMuted);

  /// Small coral uppercase label above a section heading.
  TextStyle get eyebrow => GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: p.accentText,
  );

  TextStyle get label => GoogleFonts.inter(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: p.textPrimary,
  );

  TextStyle get nav => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: p.textSecondary,
  );

  // ── Code ──────────────────────────────────────────────────────
  TextStyle get code =>
      GoogleFonts.firaCode(fontSize: 13.5, height: 1.65, color: p.codeText);

  /// Inline `code` inside body text.
  TextStyle get inlineCode =>
      GoogleFonts.firaCode(fontSize: 14, color: p.textPrimary);
}

extension AppTypeContext on BuildContext {
  /// The current theme's text styles.
  AppType get type => AppType(palette, compact: isMobileOrSmaller);
}
