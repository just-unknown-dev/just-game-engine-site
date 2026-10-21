import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../utils/open_link.dart';

enum AppButtonKind { primary, secondary }

/// The site's buttons: coral [AppButtonKind.primary] and outlined
/// [AppButtonKind.secondary].
///
/// Give [url] to make it a link: a site path (`/docs/...`) navigates, any
/// other url opens in a new tab and gets the ↗ arrow.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.url,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.trailingIcon,
    this.compact = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.url,
    this.icon,
    this.trailingIcon,
    this.compact = false,
  }) : kind = AppButtonKind.secondary;

  final String label;
  final VoidCallback? onPressed;
  final String? url;
  final AppButtonKind kind;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final primary = kind == AppButtonKind.primary;
    final external = url != null && isExternal(url!);
    final trailing =
        trailingIcon ?? (external ? Icons.north_east_rounded : null);
    final fg = primary ? p.onAccent : p.textPrimary;

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, compact ? 40 : 48)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 16 : 22),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final hover =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused);
        if (primary) {
          return hover ? Color.lerp(p.accent, Colors.white, 0.14) : p.accent;
        }
        return hover ? p.surfaceAlt : p.surface.withValues(alpha: 0.4);
      }),
      foregroundColor: WidgetStatePropertyAll(fg),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: primary
          ? null
          : WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color:
                    states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused)
                    ? p.accent.withValues(alpha: 0.7)
                    : p.borderStrong,
              ),
            ),
      textStyle: WidgetStatePropertyAll(
        context.type.label.copyWith(fontSize: compact ? 14 : 15),
      ),
      elevation: const WidgetStatePropertyAll(0),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
    );

    return TextButton(
      style: style,
      onPressed:
          onPressed ?? (url == null ? null : () => openLink(context, url!)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 16, color: fg),
          ],
        ],
      ),
    );
  }
}

/// A coral text link with an arrow, for "Read the docs →" style links.
class ArrowLink extends StatefulWidget {
  const ArrowLink({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  State<ArrowLink> createState() => _ArrowLinkState();
}

class _ArrowLinkState extends State<ArrowLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final external = isExternal(widget.url);
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => openLink(context, widget.url),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: context.type.label.copyWith(
                  fontSize: 14,
                  color: p.accentText,
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.only(left: _hover ? 8 : 5),
                child: Icon(
                  external
                      ? Icons.north_east_rounded
                      : Icons.arrow_forward_rounded,
                  size: 15,
                  color: p.accentText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
