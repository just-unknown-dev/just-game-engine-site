import 'package:flutter/material.dart';

import '../constants/site.dart';
import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../utils/open_link.dart';
import '../utils/responsive.dart';
import 'layout.dart';
import 'logo.dart';

/// The footer at the bottom of every page.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const _columns = [
    (
      'Toolkit',
      [
        ('Features', '/features'),
        ('Editor', '/editor'),
        ('CLI', '/cli'),
        ('Documentation', '/docs/introduction'),
        ('Roadmap', '/roadmap'),
      ],
    ),
    (
      'Resources',
      [
        ('API reference', Links.apiReference),
        ('Migrating from 1.x', '/docs/migration'),
        ('Changelog', Links.engineChangelog),
        ('Live examples (1.x)', Links.examples),
        ('Packages on pub.dev', Links.publisher),
      ],
    ),
    (
      'Community',
      [
        ('GitHub', Links.org),
        ('Discord', Links.discord),
        ('Report an issue', Links.engineIssues),
        ('justunknown.com', Links.company),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final compact = context.isMobileOrSmaller;

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoTiles(tileSize: 13, gap: 2),
            const SizedBox(width: 12),
            Text('Just Game Engine', style: t.wordmark),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'A Flutter game engine that thinks in systems. '
            'Engine, editor and CLI, open source.',
            style: t.bodySmall,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'v${Versions.engine} · stable ${Versions.engineStable}',
          style: t.caption.copyWith(fontFamily: t.code.fontFamily),
        ),
      ],
    );

    final columns = [
      for (final (title, links) in _columns)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.label.copyWith(fontSize: 14)),
            const SizedBox(height: 14),
            for (final (label, url) in links)
              _FooterLink(label: label, url: url),
          ],
        ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.bgElevated,
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 32,
        vertical: compact ? 40 : 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                brand,
                const SizedBox(height: 32),
                Wrap(spacing: 48, runSpacing: 28, children: columns),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: brand),
                    for (final c in columns) Expanded(flex: 2, child: c),
                  ],
                ),
              const SizedBox(height: 40),
              Divider(color: p.border),
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} Just Unknown. Just Game Engine and the '
                'just_* packages are BSD-3-Clause licensed.',
                style: t.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        link: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: () => openLink(context, widget.url),
            child: Text(
              widget.label,
              style: context.type.bodySmall.copyWith(
                height: 1.3,
                color: _hover ? p.accentText : p.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
