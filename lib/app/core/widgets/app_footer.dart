import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Shared footer for all pages.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 32 : 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: isMobile ? _MobileFooter() : _DesktopFooter(),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Just Game Engine',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A comprehensive 2D game engine built for Flutter.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'BSD-3-Clause License  •  Made with Flutter',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _FooterLink(
              label: 'GitHub',
              url: 'https://github.com/just-unknown-dev/just-game-engine',
            ),
            const SizedBox(height: 4),
            _FooterLink(label: 'Discord', url: 'https://discord.gg/AaAZayn3'),
            const SizedBox(height: 4),
            _FooterLink(
              label: 'pub.dev',
              url: 'https://pub.dev/packages/just_game_engine',
            ),
            const SizedBox(height: 4),
            _FooterLink(
              label: 'justunknown.com',
              url: 'https://justunknown.com',
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Just Game Engine',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: 8),
        Text(
          'A comprehensive 2D game engine built for Flutter.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Links row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(
              label: 'GitHub',
              url: 'https://github.com/just-unknown-dev/just-game-engine',
            ),
            const SizedBox(width: 16),
            _FooterLink(label: 'Discord', url: 'https://discord.gg/AaAZayn3'),
            const SizedBox(width: 16),
            _FooterLink(
              label: 'pub.dev',
              url: 'https://pub.dev/packages/just_game_engine',
            ),
            const SizedBox(width: 16),
            _FooterLink(
              label: 'justunknown.com',
              url: 'https://justunknown.com',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'BSD-3-Clause License  •  Made with Flutter',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String url;

  const _FooterLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.accentLight,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentLight.withOpacity(0.4),
        ),
      ),
    );
  }
}
