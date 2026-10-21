import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../utils/open_link.dart';

/// A bordered card that lifts and picks up a coral border on hover.
/// Give [url] or [onTap] to make it clickable.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.url,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.color,
    this.bordered = true,
  });

  final Widget child;
  final String? url;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Whether the border shows when the card is not hovered.
  final bool bordered;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  bool get _interactive => widget.url != null || widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = _hover && _interactive;
    final radius = BorderRadius.circular(16);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, active ? -3 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: active ? p.surfaceAlt : (widget.color ?? p.surface),
        borderRadius: radius,
        border: Border.all(
          color: active
              ? p.accent.withValues(alpha: 0.55)
              : (widget.bordered ? p.border : Colors.transparent),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: p.accent.withValues(alpha: p.isDark ? 0.12 : 0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    if (!_interactive) return card;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onHover: (h) => setState(() => _hover = h),
        onFocusChange: (f) => setState(() => _hover = f),
        onTap: widget.onTap ?? () => openLink(context, widget.url!),
        child: card,
      ),
    );
  }
}

/// A rounded square with a coral icon, used at the top of cards.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Icon(icon, size: size * 0.48, color: p.accent),
    );
  }
}

/// Icon, title, text and an optional link line: the standard content card.
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.url,
    this.linkLabel,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? url;
  final String? linkLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;
    return HoverCard(
      url: url,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon),
          const SizedBox(height: 20),
          Text(title, style: t.h3.copyWith(fontSize: 19)),
          const SizedBox(height: 8),
          Text(body, style: t.bodySmall),
          if (footer != null) ...[const SizedBox(height: 16), footer!],
          if (url != null && linkLabel != null) ...[
            const Spacer(),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  linkLabel!,
                  style: t.label.copyWith(fontSize: 14, color: p.accentText),
                ),
                const SizedBox(width: 6),
                Icon(
                  isExternal(url!)
                      ? Icons.north_east_rounded
                      : Icons.arrow_forward_rounded,
                  size: 15,
                  color: p.accentText,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A big coral number over a short label.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return HoverCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: t.stat),
          const SizedBox(height: 8),
          Text(
            label,
            style: t.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rounded label, such as a version or status.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color,
    this.dot = true,
    this.onTap,
    this.trailing,
  });

  final String label;
  final Color? color;
  final bool dot;
  final VoidCallback? onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.accentText;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? p.accent).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (color ?? p.accent).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: context.type.caption.copyWith(
                color: c,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Icon(trailing, size: 14, color: c),
          ],
        ],
      ),
    );
    if (onTap == null) return pill;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: pill),
    );
  }
}

/// A short list with coral check marks.
class CheckList extends StatelessWidget {
  const CheckList(this.items, {super.key, this.icon = Icons.check_rounded});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(icon, size: 17, color: p.accent),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: context.type.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}
