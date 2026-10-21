import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../utils/responsive.dart';

/// The widest the page content gets.
const double kContentWidth = 1080;

/// The widest the docs get: sidebar, article and "On this page" together.
const double kDocsWidth = 1360;

/// A full-width band of the page with its content centred at
/// [kContentWidth].
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.background,
    this.top,
    this.bottom,
    this.maxWidth = kContentWidth,
    this.borderTop = false,
  });

  final Widget child;
  final Color? background;

  /// Vertical padding; defaults depend on the screen size.
  final double? top;
  final double? bottom;
  final double maxWidth;
  final bool borderTop;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobileOrSmaller;
    final v = compact ? 48.0 : 72.0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: borderTop
            ? Border(top: BorderSide(color: context.palette.border))
            : null,
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 32,
        top ?? v,
        compact ? 20 : 32,
        bottom ?? v,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// A soft coral glow behind a page's opening section.
class GlowBackdrop extends StatelessWidget {
  const GlowBackdrop({
    super.key,
    required this.child,
    this.center = const Alignment(0.75, -0.7),
  });

  final Widget child;
  final Alignment center;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: center,
                radius: 1.1,
                colors: [
                  p.accent.withValues(alpha: p.isDark ? 0.14 : 0.10),
                  p.accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// The coral uppercase label used above headings.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: context.type.eyebrow);
}

/// Eyebrow, heading and optional lead paragraph, as each section starts.
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.center = false,
    this.large = false,
    this.maxTextWidth = 720,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final bool center;

  /// Page titles use the bigger h1 style.
  final bool large;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 14)],
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTextWidth + 80),
          child: Text(title, style: large ? t.h1 : t.h2, textAlign: align),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxTextWidth),
            child: Text(subtitle!, style: t.lead, textAlign: align),
          ),
        ],
      ],
    );
  }
}

/// Lays [children] out in rows of equal-height cells; the number of columns
/// follows the available width.
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.children,
    this.maxColumns = 3,
    this.minItemWidth = 280,
    this.spacing = 20,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
                .floor();
        final columns = fit.clamp(1, maxColumns);
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final cells = <Widget>[];
          for (var c = 0; c < columns; c++) {
            if (c > 0) cells.add(SizedBox(width: spacing));
            final index = i + c;
            cells.add(
              Expanded(
                child: index < children.length
                    ? children[index]
                    : const SizedBox.shrink(),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

/// Two widgets side by side on wide screens, stacked on narrow ones.
class SplitRow extends StatelessWidget {
  const SplitRow({
    super.key,
    required this.start,
    required this.end,
    this.startFlex = 1,
    this.endFlex = 1,
    this.gap = 56,
    this.breakpoint = Breakpoints.tablet,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.endFirstWhenStacked = false,
  });

  final Widget start;
  final Widget end;
  final int startFlex;
  final int endFlex;
  final double gap;
  final double breakpoint;
  final CrossAxisAlignment crossAxisAlignment;
  final bool endFirstWhenStacked;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          final items = endFirstWhenStacked ? [end, start] : [start, end];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              items[0],
              SizedBox(height: gap * 0.75),
              items[1],
            ],
          );
        }
        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Expanded(flex: startFlex, child: start),
            SizedBox(width: gap),
            Expanded(flex: endFlex, child: end),
          ],
        );
      },
    );
  }
}
