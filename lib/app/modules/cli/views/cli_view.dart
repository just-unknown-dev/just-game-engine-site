import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/site.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/code_block.dart';
import '../../../core/widgets/code_highlighter.dart';
import '../../../core/widgets/layout.dart';

@RoutePage()
class CliView extends StatefulWidget {
  const CliView({super.key});

  @override
  State<CliView> createState() => _CliViewState();
}

class _CliViewState extends State<CliView> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'cli'},
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      children: [
        _Hero(),
        _Commands(),
        _HowItWorks(),
        _FlagsAndExitCodes(),
        _Library(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final compact = context.isMobileOrSmaller;
    return GlowBackdrop(
      child: PageSection(
        top: compact ? 48 : 80,
        bottom: compact ? 40 : 64,
        child: SplitRow(
          startFlex: 6,
          endFlex: 5,
          gap: 48,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill(
                label:
                    'just_core_cli ${Versions.coreCli}  ·  '
                    'just_game_engine_cli ${Versions.gameCli}',
              ),
              const SizedBox(height: 22),
              Text(
                'Create, run and ship games from one command line.',
                style: t.h1,
              ),
              const SizedBox(height: 18),
              Text(
                'just is the Just ecosystem\'s command-line tool. Its game '
                'plugin brings what the engine needs: run the game and its '
                'editor, build releases that provably hold no editor, manage '
                'scenes, and keep packages and saved files current.',
                style: t.lead,
              ),
              const SizedBox(height: 28),
              const CommandLine('dart pub global activate just_core_cli'),
              const SizedBox(height: 22),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'CLI guide',
                    url: '/docs/cli',
                    trailingIcon: Icons.arrow_forward_rounded,
                  ),
                  AppButton.secondary(label: 'GitHub', url: Links.gameCliRepo),
                  AppButton.secondary(label: 'pub.dev', url: Links.gameCliPub),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Prefer a binary? Download just and ju for Windows, macOS or '
                'Linux from the just_core_cli releases. ju is the same tool, '
                'for machines where just is another program.',
                style: t.caption,
              ),
            ],
          ),
          end: const _Terminal(),
        ),
      ),
    );
  }
}

/// A terminal window showing a typical first session.
class _Terminal extends StatelessWidget {
  const _Terminal();

  static const lines = [
    '# a new game from the template',
    'just create my_game',
    'cd my_game',
    '# the game, with the level editor',
    'just game run --editor',
    '# a release build, checked for editor code',
    'just game build windows',
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final highlighter = CodeHighlighter('bash', base: t.code);
    return Container(
      decoration: BoxDecoration(
        color: p.codeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.codeBorder),
        boxShadow: [
          BoxShadow(
            color: p.accent.withValues(alpha: p.isDark ? 0.16 : 0.12),
            blurRadius: 80,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: p.codeHeader,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              border: Border(bottom: BorderSide(color: p.codeBorder)),
            ),
            child: Row(
              children: [
                for (final c in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ]) ...[
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                ],
                const Spacer(),
                Text(
                  'my_game — just',
                  style: t.code.copyWith(fontSize: 12, color: p.codeMuted),
                ),
                const Spacer(),
                const SizedBox(width: 54),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text.rich(
                      TextSpan(
                        style: t.code,
                        children: [
                          if (!line.startsWith('#'))
                            TextSpan(
                              text: r'$ ',
                              style: TextStyle(color: p.codeMuted),
                            ),
                          ...highlighter.line(line),
                        ],
                      ),
                      softWrap: false,
                    ),
                  ),
                Text(r'$ ▍', style: t.code.copyWith(color: p.codeMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Commands extends StatelessWidget {
  const _Commands();

  static const groups = [
    (
      Icons.folder_open_rounded,
      'Projects',
      'From just_core_cli: make a project, check it, and keep its tools on '
          'versions that work together.',
      'just create my_game        # a new game\n'
          'just check                 # every plugin\'s checks\n'
          'just doctor                # Flutter, tools, links\n'
          'just upgrade               # tools, packages, migrations\n'
          'just dev link ../packages  # use local checkouts\n'
          'just help game run         # a command\'s own help',
    ),
    (
      Icons.play_arrow_rounded,
      'Run and build',
      'Run the game with or without the editor, and build releases that are '
          'checked for editor code.',
      'just game run --editor     # desktop, debug\n'
          'just game run              # args after -- go to flutter\n'
          'just game build windows    # then checks for the editor\n'
          'just game check release-build --platform web',
    ),
    (
      Icons.layers_outlined,
      'Scenes',
      'Create and manage levels exactly as the editor writes them, never '
          'while the editor has the project open.',
      'just game scene new cave --after level_01\n'
          'just game scene list\n'
          'just game scene rename | delete | order\n'
          'just game scene migrate | validate',
    ),
    (
      Icons.health_and_safety_outlined,
      'Health and upgrades',
      'Check the project, move the engine\'s packages to a tested set, and '
          'rewrite old saved files.',
      'just game check            # no editor; formats readable\n'
          'just game doctor           # SDK floors, versions, links\n'
          'just game upgrade --check  # what would move\n'
          'just game migrate          # rewrite old saved files',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Commands',
            title: 'Everything from a new project to a release.',
            subtitle:
                'just check, doctor, upgrade and dev link run the matching '
                'game commands for you: they are the game plugin\'s hooks.',
          ),
          const SizedBox(height: 40),
          CardGrid(
            maxColumns: 2,
            minItemWidth: 380,
            children: [
              for (final (icon, title, body, code) in groups)
                HoverCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon, size: 40),
                          const SizedBox(width: 14),
                          Text(title, style: t.h3),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(body, style: t.bodySmall),
                      const SizedBox(height: 18),
                      CodeBlock(
                        code: code,
                        language: 'bash',
                        showHeader: false,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const items = [
    (
      Icons.undo_rounded,
      'All or nothing',
      'Every change is journalled and backed up first. A failure puts every '
          'byte back, and a crash is rolled back on the next run.',
    ),
    (
      Icons.push_pin_outlined,
      'Projects pin their own just',
      'A global just hands over to the version in the project\'s dev '
          'dependencies, so a whole team runs the same tool.',
    ),
    (
      Icons.layers_outlined,
      'Versions travel in sets',
      'GameSet holds the engine\'s packages, the editors, and the Flutter and '
          'Dart they need. just upgrade moves them together.',
    ),
    (
      Icons.verified_outlined,
      'Releases are checked',
      'just game build builds, then checks the build holds no editor, and no '
          '3D physics in a 2D game.',
    ),
    (
      Icons.restore_from_trash_outlined,
      'Nothing is lost',
      'What a scene change or a migration replaces goes to the editor\'s '
          'trash, and can be restored from the editor.',
    ),
    (
      Icons.description_outlined,
      'Pubspecs keep every other byte',
      'A tool edits only its own marked block of pubspec.yaml, leaving '
          'comments, order and line endings as they were.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'How it works',
            title: 'Safe to run on a real project.',
          ),
          const SizedBox(height: 40),
          CardGrid(
            children: [
              for (final (icon, title, body) in items)
                FeatureCard(icon: icon, title: title, body: body),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FlagsAndExitCodes extends StatelessWidget {
  const _FlagsAndExitCodes();

  static const flags = [
    ('--json', 'One JSON document on stdout; messages go to stderr.'),
    ('--yes', 'Go ahead without asking, for scripts and CI.'),
    ('--verbose', 'Say more about what is happening.'),
    ('--project <folder>', 'Run on another project folder.'),
  ];

  static const codes = [
    ('0', 'Done, or nothing to do.'),
    ('1', 'Failed. A change that fails is rolled back first.'),
    ('2', 'Called wrongly: unknown command, missing argument, bad option.'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;

    Widget table(String title, List<(String, String)> rows) {
      return HoverCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
              child: Text(title, style: t.h4),
            ),
            for (final (key, value) in rows)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        key,
                        style: t.code.copyWith(
                          fontSize: 13,
                          color: p.accentText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Expanded(child: Text(value, style: t.bodySmall)),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Scripting',
            title: 'Made for CI as much as for people.',
            subtitle:
                'Every command takes the same flags and exits with the same '
                'codes. game run hands the terminal to flutter run and exits '
                'with its code.',
          ),
          const SizedBox(height: 36),
          CardGrid(
            maxColumns: 2,
            minItemWidth: 380,
            children: [
              table('Flags on every command', flags),
              table('Exit codes', codes),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Library extends StatelessWidget {
  const _Library();

  static const _code =
      '''import 'package:just_game_engine_cli/just_game_engine_cli.dart';

void main() {
  final project = JustProject('.');
  final rules = project.releaseRules(); // the editor's packages + each store item's
  final reachable = project.editorReachableFrom('lib/main.dart', rules: rules);
  if (reachable.isNotEmpty) throw StateError('The editor would ship: \$reachable');
}''';

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return PageSection(
      child: SplitRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        startFlex: 4,
        endFlex: 6,
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('As a library'),
            const SizedBox(height: 14),
            Text('The same checks in your own scripts.', style: t.h2),
            const SizedBox(height: 14),
            Text(
              'just_game_engine_cli is also a Dart library: the release '
              'rules, format checks and version sets the commands use, for '
              'your own tests and tools. The text-based checks run on every '
              'platform, the web included.',
              style: t.lead,
            ),
            const SizedBox(height: 24),
            const ArrowLink(
              label: 'just_core_cli on GitHub',
              url: Links.coreCliRepo,
            ),
          ],
        ),
        end: const CodeBlock(code: _code, title: 'tool/check_release.dart'),
      ),
    );
  }
}
