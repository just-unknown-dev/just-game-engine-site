import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

const _tiles = [
  ('just_icon', 'assets/icons/j.png'),
  ('unknown_icon', 'assets/icons/u.png'),
  ('plus_icon', 'assets/icons/plus.png'),
  ('cross_icon', 'assets/icons/cross.png'),
];

/// The 2×2 brand tiles (J, U, +, ×). With [interactive], each tile shrinks a
/// little on hover and press.
class LogoTiles extends StatelessWidget {
  const LogoTiles({
    super.key,
    required this.tileSize,
    required this.gap,
    this.interactive = false,
  });

  final double tileSize;
  final double gap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    Widget tile(int i) => interactive
        ? _BouncyTile(name: _tiles[i].$1, asset: _tiles[i].$2, size: tileSize)
        : Image.asset(
            _tiles[i].$2,
            width: tileSize,
            height: tileSize,
            filterQuality: FilterQuality.medium,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(0),
            SizedBox(width: gap),
            tile(1),
          ],
        ),
        SizedBox(height: gap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(2),
            SizedBox(width: gap),
            tile(3),
          ],
        ),
      ],
    );
  }
}

class _BouncyTile extends StatefulWidget {
  const _BouncyTile({
    required this.name,
    required this.asset,
    required this.size,
  });

  final String name;
  final String asset;
  final double size;

  @override
  State<_BouncyTile> createState() => _BouncyTileState();
}

class _BouncyTileState extends State<_BouncyTile> {
  double _scale = 1;

  Future<void> _tap() async {
    setState(() => _scale = 0.78);
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'game_studio_icon_tapped',
        parameters: {'icon_name': widget.name},
      );
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _scale = 0.92);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _scale = 0.92),
      onExit: (_) => setState(() => _scale = 1),
      child: GestureDetector(
        onTap: _tap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Image.asset(
              widget.asset,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// The logo tiles on a rounded card with a soft coral glow, as the hero art.
class LogoCard extends StatelessWidget {
  const LogoCard({super.key, this.size = 240});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.isDark ? p.surface : p.bgElevated,
        borderRadius: BorderRadius.circular(size * 0.13),
        border: Border.all(color: p.borderStrong.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: p.accent.withValues(alpha: p.isDark ? 0.30 : 0.22),
            blurRadius: size * 0.55,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: LogoTiles(
        tileSize: size * 0.29,
        gap: size * 0.035,
        interactive: true,
      ),
    );
  }
}
