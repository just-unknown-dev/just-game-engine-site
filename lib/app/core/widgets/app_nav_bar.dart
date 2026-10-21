import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/site.dart';
import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../theme/theme_cubit.dart';
import '../utils/open_link.dart';
import '../utils/responsive.dart';
import 'layout.dart';
import 'logo.dart';

class NavItem {
  const NavItem(this.label, this.route, {this.match, required this.icon});

  final String label;
  final String route;

  /// Path prefix that marks the item active; defaults to [route].
  final String? match;
  final IconData icon;

  bool isActive(String path) => path.startsWith(match ?? route);
}

/// The bar at the top of every page.
class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, this.maxWidth = kContentWidth});

  /// How wide its content gets; pages with a wider grid (the docs) pass
  /// theirs so the logo lines up with their first column.
  final double maxWidth;

  static const height = 68.0;

  static const items = [
    NavItem('Features', '/features', icon: Icons.widgets_outlined),
    NavItem('Editor', '/editor', icon: Icons.design_services_outlined),
    NavItem('CLI', '/cli', icon: Icons.terminal_rounded),
    NavItem(
      'Docs',
      '/docs/introduction',
      match: '/docs',
      icon: Icons.menu_book_outlined,
    ),
    NavItem('Roadmap', '/roadmap', icon: Icons.timeline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final compact = context.isMobileOrSmaller;
    final path = context.router.currentPath;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.bg.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: p.border.withValues(alpha: 0.7)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            children: [
              const _Brand(),
              const Spacer(),
              if (!compact) ...[
                for (final item in items)
                  _NavLink(item: item, active: item.isActive(path)),
                const SizedBox(width: 12),
                _IconAction(
                  icon: Icons.code_rounded,
                  tooltip: 'GitHub',
                  onTap: () => openLink(context, Links.engineRepo),
                ),
              ],
              const _ThemeToggle(),
              if (compact)
                _IconAction(
                  icon: Icons.menu_rounded,
                  tooltip: 'Menu',
                  onTap: () => _openMenu(context, path),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context, String path) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => _MobileMenu(path: path, pageContext: context),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: 'Just Game Engine home',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.router.navigatePath('/'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoTiles(tileSize: 13, gap: 2),
              const SizedBox(width: 12),
              Text('Just Game Engine', style: context.type.wordmark),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.item, required this.active});

  final NavItem item;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lit = widget.active || _hover;
    return Semantics(
      link: true,
      selected: widget.active,
      child: InkWell(
        onTap: () => context.router.navigatePath(widget.item.route),
        onHover: (h) => setState(() => _hover = h),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.label,
                style: context.type.nav.copyWith(
                  color: lit ? p.textPrimary : p.textSecondary,
                  fontWeight: widget.active ? FontWeight.w600 : null,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: widget.active ? 18 : (_hover ? 10 : 0),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      iconSize: 20,
      style: IconButton.styleFrom(
        foregroundColor: p.textSecondary,
        hoverColor: p.surfaceAlt,
      ),
      icon: Icon(icon),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeCubit>().isDark;
    return _IconAction(
      icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      tooltip: dark ? 'Switch to light theme' : 'Switch to dark theme',
      onTap: () => context.read<ThemeCubit>().toggle(),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.path, required this.pageContext});

  final String path;

  /// The page's context: the sheet's own is gone once it closes.
  final BuildContext pageContext;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;

    void go(String url) {
      Navigator.of(context).pop();
      openLink(pageContext, url);
    }

    Widget tile(
      IconData icon,
      String label,
      String url, {
      bool active = false,
    }) {
      return ListTile(
        leading: Icon(icon, color: active ? p.accent : p.textSecondary),
        title: Text(
          label,
          style: t.label.copyWith(
            color: active ? p.accentText : p.textPrimary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: isExternal(url)
            ? Icon(Icons.north_east_rounded, size: 16, color: p.textMuted)
            : null,
        onTap: () => go(url),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(Icons.home_outlined, 'Home', '/', active: path == '/'),
            for (final item in AppNavBar.items)
              tile(
                item.icon,
                item.label,
                item.route,
                active: item.isActive(path),
              ),
            Divider(color: p.border, height: 20, indent: 16, endIndent: 16),
            tile(Icons.code_rounded, 'GitHub', Links.engineRepo),
            tile(Icons.forum_outlined, 'Discord', Links.discord),
          ],
        ),
      ),
    );
  }
}
