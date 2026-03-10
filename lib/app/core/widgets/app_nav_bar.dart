import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/remote_config_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Top navigation bar used across all pages.
class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({super.key});

  static const navItems = [
    NavItem('Home', '/'),
    NavItem('Roadmap', '/roadmap'),
    NavItem('Features', '/features'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final currentPath = context.router.currentPath;
    final isMobile = context.isMobileOrSmaller;

    return Container(
      height: 64,
      decoration: BoxDecoration(color: AppColors.bgDark.withOpacity(0.50)),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Row(
        children: [
          // ── Logo ──────────────────────────────────────────
          InkWell(
            onTap: () => context.router.pushPath('/'),
            hoverColor: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/plus.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Image.asset('assets/icons/cross.png', width: 24, height: 24),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Just Game Engine',
                    style: AppTextStyles.displaySmall.copyWith(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),

          // ── Desktop nav links ────────────────────────────
          if (!isMobile) ...[
            for (final item in navItems)
              _NavLink(
                label: item.label,
                route: item.route,
                isActive: _isActive(currentPath, item.route),
              ),
            if (RemoteConfigService.instance.showEngineEditorButton)
              _EngineEditor(),
          ],

          // ── Mobile hamburger menu ────────────────────────
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => _showMobileMenu(context, currentPath),
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context, String currentPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MobileNavMenu(currentPath: currentPath),
    );
  }

  static bool _isActive(String currentPath, String route) {
    if (route == '/') return currentPath == '/';
    return currentPath.startsWith(route);
  }
}

/// Data class for navigation items - made public for reuse.
class NavItem {
  final String label;
  final String route;
  const NavItem(this.label, this.route);
}

/// Mobile navigation menu shown as bottom sheet.
class _MobileNavMenu extends StatelessWidget {
  final String currentPath;

  const _MobileNavMenu({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Nav items
            for (final item in AppNavBar.navItems)
              _MobileNavItem(
                item: item,
                isActive: AppNavBar._isActive(currentPath, item.route),
              ),
            const Divider(color: AppColors.border, height: 24),
            // Editor button if available
            if (RemoteConfigService.instance.showEngineEditorButton)
              ListTile(
                leading: const Icon(Icons.launch, color: AppColors.accentLight),
                title: Text(
                  'Engine Editor',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentLight,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(
                    Uri.parse('https://editor.engine.justunknown.com/'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;

  const _MobileNavItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForRoute(item.route),
        color: isActive ? AppColors.accent : AppColors.textSecondary,
      ),
      title: Text(
        item.label,
        style: isActive
            ? AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              )
            : AppTextStyles.bodyMedium,
      ),
      trailing: isActive
          ? Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        context.router.pushPath(item.route);
      },
    );
  }

  IconData _getIconForRoute(String route) {
    switch (route) {
      case '/':
        return Icons.home_outlined;
      case '/features':
        return Icons.widgets_outlined;
      case '/examples':
        return Icons.code;
      case '/roadmap':
        return Icons.timeline;
      default:
        return Icons.article_outlined;
    }
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final String route;
  final bool isActive;

  const _NavLink({
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: () => context.router.pushPath(widget.route),
        hoverColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? AppColors.accent
                    : _hovering
                    ? AppColors.accent.withOpacity(0.4)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: widget.isActive
                ? AppTextStyles.navLinkActive
                : AppTextStyles.navLink,
          ),
        ),
      ),
    );
  }
}

class _EngineEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse('https://editor.engine.justunknown.com/')),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Editor',
          style: AppTextStyles.label.copyWith(color: AppColors.accentLight),
        ),
      ),
    );
  }
}
