import 'package:flutter/material.dart';

/// The site's colours, one set per theme.
///
/// Read them with `context.palette`. Code blocks stay dark in both themes,
/// so their colours are the same in each.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.info,
    required this.codeBg,
    required this.codeHeader,
    required this.codeBorder,
    required this.codeText,
    required this.codeMuted,
  });

  final Brightness brightness;

  /// Page background.
  final Color bg;

  /// Nav bar, footer and other bands that sit a step above the page.
  final Color bgElevated;

  /// Cards.
  final Color surface;

  /// Hovered cards, inputs and chips.
  final Color surfaceAlt;

  final Color border;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// The coral brand colour, for fills and icons.
  final Color accent;

  /// The coral for small text, dark enough to read on [bg].
  final Color accentText;

  /// Text and icons drawn on [accent].
  final Color onAccent;

  final Color success;
  final Color warning;
  final Color info;

  final Color codeBg;
  final Color codeHeader;
  final Color codeBorder;
  final Color codeText;
  final Color codeMuted;

  bool get isDark => brightness == Brightness.dark;

  /// A faint coral wash for icon tiles and highlights.
  Color get accentSoft => accent.withValues(alpha: isDark ? 0.14 : 0.12);

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF080B17),
    bgElevated: Color(0xFF0E1224),
    surface: Color(0xFF121729),
    surfaceAlt: Color(0xFF192036),
    border: Color(0xFF232B42),
    borderStrong: Color(0xFF343E5C),
    textPrimary: Color(0xFFEEF0F7),
    textSecondary: Color(0xFFA6ACC2),
    textMuted: Color(0xFF727A96),
    accent: Color(0xFFF5746F),
    accentText: Color(0xFFF5746F),
    onAccent: Color(0xFF1C0F10),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF7AB8FF),
    codeBg: Color(0xFF0B0F1D),
    codeHeader: Color(0xFF111628),
    codeBorder: Color(0xFF232B42),
    codeText: Color(0xFFE4E7F2),
    codeMuted: Color(0xFF6C7491),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF7F7FA),
    bgElevated: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F2F7),
    border: Color(0xFFE3E5EE),
    borderStrong: Color(0xFFCBD0DE),
    textPrimary: Color(0xFF11131C),
    textSecondary: Color(0xFF4A5068),
    textMuted: Color(0xFF737995),
    accent: Color(0xFFEF5F59),
    accentText: Color(0xFFC63A33),
    onAccent: Color(0xFF1C0F10),
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    info: Color(0xFF1D6FD1),
    codeBg: Color(0xFF0E1224),
    codeHeader: Color(0xFF141A30),
    codeBorder: Color(0xFF1E2640),
    codeText: Color(0xFFE4E7F2),
    codeMuted: Color(0xFF7A82A0),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: l(bg, other.bg),
      bgElevated: l(bgElevated, other.bgElevated),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      accent: l(accent, other.accent),
      accentText: l(accentText, other.accentText),
      onAccent: l(onAccent, other.onAccent),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      info: l(info, other.info),
      codeBg: l(codeBg, other.codeBg),
      codeHeader: l(codeHeader, other.codeHeader),
      codeBorder: l(codeBorder, other.codeBorder),
      codeText: l(codeText, other.codeText),
      codeMuted: l(codeMuted, other.codeMuted),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// The current theme's colours.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
