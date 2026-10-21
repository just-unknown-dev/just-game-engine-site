import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// The hero's animated backdrop: drifting coral particles that move aside
/// for the pointer, a slow breathing glow, and faint scanlines in the dark
/// theme. Kept low-key so the text stays the focus.
class AnimatedStudioBackground extends StatefulWidget {
  const AnimatedStudioBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedStudioBackground> createState() =>
      _AnimatedStudioBackgroundState();
}

class _AnimatedStudioBackgroundState extends State<AnimatedStudioBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _cursor = ValueNotifier<Offset?>(null); // normalised [0..1]

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    final rng = Random(42);
    _particles = List.generate(64, (_) => _Particle.random(rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cursor.dispose();
    super.dispose();
  }

  void _track(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(global);
    _cursor.value = Offset(
      (local.dx / box.size.width).clamp(0.0, 1.0),
      (local.dy / box.size.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return MouseRegion(
      onHover: (e) => _track(e.position),
      onExit: (_) => _cursor.value = null,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (e) => _track(e.position),
        onPointerUp: (_) => _cursor.value = null,
        onPointerCancel: (_) => _cursor.value = null,
        // The painting fills whatever size the child takes, so the hero can
        // have a fixed height (desktop) or size to its content (mobile).
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StudioPainter(
                    animation: reduceMotion
                        ? const AlwaysStoppedAnimation(0.3)
                        : _controller,
                    cursor: _cursor,
                    particles: _particles,
                    palette: palette,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.phase,
  });

  factory _Particle.random(Random rng) => _Particle(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    speed: 0.04 + rng.nextDouble() * 0.10,
    size: 1.6 + rng.nextDouble() * 3.4,
    opacity: 0.18 + rng.nextDouble() * 0.42,
    phase: rng.nextDouble() * 2 * pi,
  );

  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
  final double phase;
}

class _StudioPainter extends CustomPainter {
  _StudioPainter({
    required this.animation,
    required this.cursor,
    required this.particles,
    required this.palette,
  }) : super(repaint: Listenable.merge([animation, cursor]));

  final Animation<double> animation;
  final ValueNotifier<Offset?> cursor;
  final List<_Particle> particles;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final progress = animation.value;
    final accent = palette.accent;
    final dark = palette.isDark;

    // Base: the page colour, a touch lighter towards the top right.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [palette.bg, palette.bg, palette.bgElevated],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );

    // A coral glow behind the logo card, breathing slowly.
    final breathe = 0.5 + 0.5 * sin(progress * 2 * pi);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.62, -0.1),
          radius: 0.9,
          colors: [
            accent.withValues(alpha: (dark ? 0.13 : 0.10) + breathe * 0.04),
            accent.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    // Drifting particles.
    const repelRadius = 0.14;
    const repelStrength = 0.06;
    final c = cursor.value;
    final paint = Paint();
    for (final p in particles) {
      final rawY = (p.y - progress * p.speed) % 1.0;
      final y = rawY < 0 ? rawY + 1.0 : rawY;
      var nx = (p.x + 0.015 * sin(progress * 2 * pi * 1.5 + p.phase)) % 1.0;
      var ny = y;

      if (c != null) {
        final dx = nx - c.dx;
        final dy = ny - c.dy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < repelRadius && dist > 0) {
          final force = (1.0 - dist / repelRadius) * repelStrength;
          nx = (nx + dx / dist * force).clamp(0.0, 1.0);
          ny = (ny + dy / dist * force).clamp(0.0, 1.0);
        }
      }

      const fadeBand = 0.08;
      final fade =
          (y < fadeBand
                  ? y / fadeBand
                  : y > 1 - fadeBand
                  ? (1 - y) / fadeBand
                  : 1.0)
              .clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(nx * size.width, ny * size.height),
        p.size,
        paint
          ..color = accent.withValues(
            alpha: p.opacity * fade * (dark ? 0.55 : 0.45),
          ),
      );
    }

    if (dark) {
      // Faint scanlines, a nod to old displays.
      final scan = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 1;
      for (double y = 0; y < size.height; y += 4) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
      }
    }

    // Fade the edges into the page so the hero has no hard border.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.bg.withValues(alpha: 0), palette.bg],
          stops: const [0.72, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_StudioPainter old) =>
      old.palette != palette || old.particles != particles;
}
