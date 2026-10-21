import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';

/// A screenshot from the engine or editor, with its description.
class Shot {
  const Shot(this.asset, this.caption);

  final String asset;
  final String caption;
}

/// A rounded, bordered screenshot. Clicking it opens [shot] large.
class ScreenshotFrame extends StatefulWidget {
  const ScreenshotFrame({
    super.key,
    required this.shot,
    this.aspectRatio = 16 / 9,
    this.radius = 14,
    this.showCaption = false,
    this.glow = false,
  });

  final Shot shot;
  final double aspectRatio;
  final double radius;
  final bool showCaption;
  final bool glow;

  @override
  State<ScreenshotFrame> createState() => _ScreenshotFrameState();
}

class _ScreenshotFrameState extends State<ScreenshotFrame> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final frame = Semantics(
      image: true,
      label: widget.shot.caption,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => showShot(context, widget.shot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: _hover ? p.accent.withValues(alpha: 0.6) : p.border,
              ),
              boxShadow: [
                if (widget.glow)
                  BoxShadow(
                    color: p.accent.withValues(alpha: p.isDark ? 0.18 : 0.14),
                    blurRadius: 80,
                    spreadRadius: 2,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0.35 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius - 1),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: AnimatedScale(
                  scale: _hover ? 1.02 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Image.asset(
                    widget.shot.asset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => ColoredBox(color: p.surfaceAlt),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.showCaption) return frame;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frame,
        const SizedBox(height: 10),
        Text(widget.shot.caption, style: context.type.caption),
      ],
    );
  }
}

/// Shows [shot] over the page, zoomable, with its caption.
Future<void> showShot(BuildContext context, Shot shot) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  maxScale: 4,
                  child: Image.asset(shot.asset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shot.caption,
              textAlign: TextAlign.center,
              style: context.type.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    },
  );
}
