import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Material themes built from [AppPalette].
abstract final class AppTheme {
  static ThemeData get dark => _build(AppPalette.dark);
  static ThemeData get light => _build(AppPalette.light);

  static ThemeData _build(AppPalette p) {
    final base = ThemeData(useMaterial3: true, brightness: p.brightness);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: p.brightness,
        ).copyWith(
          primary: p.accent,
          onPrimary: p.onAccent,
          secondary: p.accent,
          surface: p.surface,
          onSurface: p.textPrimary,
          outline: p.border,
        );

    return base.copyWith(
      colorScheme: scheme,
      primaryColor: p.accent,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      extensions: [p],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: p.accent.withValues(alpha: 0.06),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.28),
      ),
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: p.textSecondary, displayColor: p.textPrimary),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: p.textSecondary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark ? p.surfaceAlt : p.textPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          color: p.isDark ? p.textPrimary : p.bg,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        isDense: true,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: p.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.accent),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(p.textMuted.withValues(alpha: 0.35)),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.bgElevated,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
