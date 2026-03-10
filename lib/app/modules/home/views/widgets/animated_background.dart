import 'dart:math';

import 'package:flutter/material.dart';

/// A full-screen animated background representing a game studio atmosphere.
/// Features drifting particles, a soft ambient glow, subtle scanlines,
/// and a quiet vignette — all at low intensity to stay out of the way of UI.
class AnimatedStudioBackground extends StatefulWidget {
  final Widget child;
  const AnimatedStudioBackground({super.key, required this.child});

  @override
  State<AnimatedStudioBackground> createState() =>
      _AnimatedStudioBackgroundState();
}

class _AnimatedStudioBackgroundState extends State<AnimatedStudioBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  Offset? _cursor; // normalised [0..1] in both axes

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rng = Random(42);
    _particles = List.generate(70, (_) => _Particle.random(rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return MouseRegion(
      onHover: (e) => setState(() {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(e.position);
        _cursor = Offset(
          (local.dx / box.size.width).clamp(0.0, 1.0),
          (local.dy / box.size.height).clamp(0.0, 1.0),
        );
      }),
      onExit: (_) => setState(() => _cursor = null),
      child: Listener(
        onPointerMove: (e) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(e.position);
          setState(() {
            _cursor = Offset(
              (local.dx / box.size.width).clamp(0.0, 1.0),
              (local.dy / box.size.height).clamp(0.0, 1.0),
            );
          });
        },
        onPointerUp: (_) => setState(() => _cursor = null),
        onPointerCancel: (_) => setState(() => _cursor = null),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _StudioPainter(
                  progress: _controller.value,
                  particles: _particles,
                  color: color,
                  cursor: _cursor,
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

// ─── Data ────────────────────────────────────────────────────────────────────

class _Particle {
  final double x; // normalised [0..1]
  final double y; // normalised [0..1]
  final double speed; // fraction of screen height per full cycle
  final double size;
  final double opacity;
  final double phase; // sine sway phase offset

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
    size: 2.0 + rng.nextDouble() * 4.0,
    opacity: 0.18 + rng.nextDouble() * 0.40,
    phase: rng.nextDouble() * 2 * pi,
  );
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _StudioPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final Color color;
  final Offset? cursor;

  const _StudioPainter({
    required this.progress,
    required this.particles,
    required this.color,
    this.cursor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Background ───────────────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07070F), Color(0xFF0C0C1C), Color(0xFF060610)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Offset.zero & size),
    );

    // ── Soft ambient glow (breathes slowly) ──────────────────────
    final breathe = 0.5 + 0.5 * sin(progress * 2 * pi);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 0.75,
          colors: [
            color.withOpacity(0.07 + breathe * 0.04),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    // ── Drifting particles ───────────────────────────────────────
    const repelRadius = 0.14; // normalised influence radius
    const repelStrength = 0.06; // max push amount (normalised)
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      // Drift upward and wrap
      final rawY = (p.y - progress * p.speed) % 1.0;
      final y = rawY < 0 ? rawY + 1.0 : rawY;
      // Gentle horizontal sway
      final rawX = p.x + 0.015 * sin(progress * 2 * pi * 1.5 + p.phase);
      var nx = rawX % 1.0;
      var ny = y;

      // Cursor repulsion
      if (cursor != null) {
        final dx = nx - cursor!.dx;
        final dy = ny - cursor!.dy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < repelRadius && dist > 0) {
          final force = (1.0 - dist / repelRadius) * repelStrength;
          nx = (nx + dx / dist * force).clamp(0.0, 1.0);
          ny = (ny + dy / dist * force).clamp(0.0, 1.0);
        }
      }

      // Fade in and out as particle completes its loop
      const fadeBand = 0.08;
      final fadeOpacity =
          (y < fadeBand
                  ? y / fadeBand
                  : y > (1.0 - fadeBand)
                  ? (1.0 - y) / fadeBand
                  : 1.0)
              .clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(nx * size.width, ny * size.height),
        p.size,
        particlePaint
          ..color = color.withOpacity(p.opacity * fadeOpacity * 0.60),
      );
    }

    // ── Scanlines — very faint CRT / display nod ─────────────────
    final scanPaint = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    // ── Vignette ─────────────────────────────────────────────────
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_StudioPainter old) =>
      old.progress != progress || old.color != color || old.cursor != cursor;
}
