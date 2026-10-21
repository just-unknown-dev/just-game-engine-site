import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/features_data.dart';
import '../../../core/constants/site.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/code_block.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/logo.dart';
import '../../../core/widgets/screenshot.dart';
import 'widgets/animated_background.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _whatsNewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'home'},
      );
    } catch (_) {}
  }

  void _showWhatsNew() {
    final target = _whatsNewKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        _Hero(onWhatsNew: _showWhatsNew),
        const _Stats(),
        const _Showcase(),
        const _Toolkit(),
        _WhatsNew(key: _whatsNewKey),
        const _Subsystems(),
        const _GetStarted(),
        const _Resources(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.onWhatsNew});

  final VoidCallback onWhatsNew;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobileOrSmaller;
    final p = context.palette;
    final t = context.type;
    final viewport = MediaQuery.sizeOf(context).height - AppNavBar.height;
    final height = compact ? null : viewport.clamp(620.0, 780.0);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Pill(
          label: 'New: Just Game Engine 2.0 dev preview',
          trailing: Icons.arrow_downward_rounded,
          onTap: onWhatsNew,
        ),
        const SizedBox(height: 26),
        Text(
          'Just Game Engine',
          style: GoogleFonts.majorMonoDisplay(
            fontSize: compact ? 18 : 22,
            color: p.accentText,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text('A Flutter game engine that thinks in systems.', style: t.display),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Entities, components and systems on a fixed-step core. Build in '
            '2D, turn on 3D graphics and physics when you need them, and edit '
            'your levels inside the running game.',
            style: t.lead,
          ),
        ),
        const SizedBox(height: 34),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AppButton(label: 'Get started', url: '/docs/installation'),
            AppButton.secondary(label: 'Tour the editor', url: '/editor'),
            AppButton.secondary(label: 'GitHub', url: Links.engineRepo),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Flutter ${Versions.flutter}+  ·  Android, iOS, Windows, macOS, '
          'Linux and the web  ·  BSD-3',
          style: t.caption,
        ),
      ],
    );

    return SizedBox(
      height: height,
      child: AnimatedStudioBackground(
        child: PageSection(
          top: compact ? 48 : 0,
          bottom: compact ? 64 : 24,
          child: compact
              ? text
              : Row(
                  children: [
                    Expanded(flex: 3, child: text),
                    const SizedBox(width: 48),
                    const Expanded(
                      flex: 2,
                      child: Center(child: LogoCard(size: 250)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// By the numbers
// ─────────────────────────────────────────────────────────────────────────────

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      top: 8,
      bottom: 24,
      child: CardGrid(
        maxColumns: 4,
        minItemWidth: 200,
        spacing: 16,
        children: [
          StatTile(value: '1,874', label: 'Passing engine tests'),
          StatTile(value: '6', label: 'Platforms via Flutter'),
          StatTile(value: '2D + 3D', label: '3D graphics and physics opt-in'),
          StatTile(value: 'BSD-3', label: 'Open-source license'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Showcase
// ─────────────────────────────────────────────────────────────────────────────

class _Showcase extends StatelessWidget {
  const _Showcase();

  static const shots = [
    Shot(
      'assets/screenshots/jge_3d_third_person.webp',
      'A 3D third-person level: PBR materials, shadows, point lights, sky '
          'and fog.',
    ),
    Shot(
      'assets/screenshots/jge_2d_platformer_day.webp',
      'A 2D platformer level: tile map, gradient shapes, physics bodies and '
          'a sprite player.',
    ),
    Shot(
      'assets/screenshots/jge_2d_platformer_night.webp',
      'The same 2D level at night, with particle effects.',
    ),
    Shot(
      'assets/screenshots/jge_3d_materials.webp',
      '3D shapes with PBR materials: gold, chrome, glass, emissive, copper, '
          'jade, ruby and a faceted gem.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Showcase',
            title: 'Levels made in the editor, run by the engine.',
            subtitle:
                'The showcase scenes from the project templates: saved by the '
                'editor as JSON, then loaded and played by the engine.',
          ),
          const SizedBox(height: 40),
          CardGrid(
            maxColumns: 2,
            minItemWidth: 340,
            spacing: 24,
            children: [
              for (final shot in shots)
                ScreenshotFrame(shot: shot, showCaption: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The toolkit
// ─────────────────────────────────────────────────────────────────────────────

class _Toolkit extends StatelessWidget {
  const _Toolkit();

  @override
  Widget build(BuildContext context) {
    return const PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'The toolkit',
            title: 'Engine, editor and CLI, made to work together.',
            subtitle:
                'Write the game in Dart, lay out its levels in the editor, '
                'and let the CLI create, run, check and upgrade the project.',
          ),
          SizedBox(height: 40),
          CardGrid(
            children: [
              _ToolCard(
                icon: Icons.memory_rounded,
                name: 'Engine',
                package: 'just_game_engine',
                version: Versions.engine,
                body:
                    'An ECS world, JSON scenes, physics, cameras, timelines, '
                    'audio and input, drawn inside an ordinary Flutter '
                    'widget.',
                url: '/features',
                linkLabel: 'Explore the engine',
              ),
              _ToolCard(
                icon: Icons.design_services_outlined,
                name: 'Editor',
                package: 'just_game_engine_editor',
                version: Versions.editor,
                body:
                    'A level editor that runs inside your game in debug '
                    'builds, and is never part of a release.',
                url: '/editor',
                linkLabel: 'Tour the editor',
              ),
              _ToolCard(
                icon: Icons.terminal_rounded,
                name: 'CLI',
                package: 'just_game_engine_cli',
                version: Versions.gameCli,
                body:
                    'Create, run and build games with just, keep the '
                    'engine\'s packages in step, and migrate old files.',
                url: '/cli',
                linkLabel: 'See the commands',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.name,
    required this.package,
    required this.version,
    required this.body,
    required this.url,
    required this.linkLabel,
  });

  final IconData icon;
  final String name;
  final String package;
  final String version;
  final String body;
  final String url;
  final String linkLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;
    return HoverCard(
      url: url,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon),
              const Spacer(),
              Pill(label: version, dot: false),
            ],
          ),
          const SizedBox(height: 22),
          Text(name, style: t.h3),
          const SizedBox(height: 4),
          Text(
            package,
            style: t.code.copyWith(fontSize: 13, color: p.textMuted),
          ),
          const SizedBox(height: 12),
          Text(body, style: t.bodySmall),
          const Spacer(),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                linkLabel,
                style: t.label.copyWith(fontSize: 14, color: p.accentText),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 15, color: p.accentText),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// What's new in 2.0
// ─────────────────────────────────────────────────────────────────────────────

class _WhatsNew extends StatelessWidget {
  const _WhatsNew({super.key});

  static const items = [
    (
      Icons.power_settings_new_rounded,
      'Engines you own',
      'Engine() makes a new engine and await initialize() builds it. No '
          'singletons; each engine keeps its own registries.',
      '/docs/engine',
    ),
    (
      Icons.view_in_ar_outlined,
      'Opt-in 3D graphics',
      'glTF models, PBR materials, lights, sky and fog on Flutter GPU. A 2D '
          'game ships none of it.',
      '/docs/graphics-3d',
    ),
    (
      Icons.category_outlined,
      '3D physics on Jolt',
      'RigidBody3D, Collider3D and CharacterBody3D, with the same names and '
          'events as 2D.',
      '/docs/physics-3d',
    ),
    (
      Icons.sports_basketball_outlined,
      'New 2D physics',
      'Box2D v3 through FFI, a pure-Dart engine on the web, and a native '
          'CharacterBody2D.',
      '/docs/physics-2d',
    ),
    (
      Icons.videocam_outlined,
      'Virtual cameras',
      'A camera brain with priorities and blends, framing, confiners, noise, '
          'impulses and dolly paths.',
      '/docs/cameras',
    ),
    (
      Icons.view_timeline_outlined,
      'Timelines and animator graphs',
      'Keyframe any saved field, and drive sprite clips with state machines '
          'and blend trees.',
      '/docs/timelines',
    ),
    (
      Icons.sports_esports_outlined,
      'Action-based input',
      'Named actions across keyboard, mouse, gamepads and touch, with saved '
          'rebinding and local multiplayer.',
      '/docs/input',
    ),
    (
      Icons.grid_on_rounded,
      'Level maps',
      'Tiled import and export, four grid types, merged tile collision and '
          'tile edits while the game runs.',
      '/docs/level-maps',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'New in 2.0',
            title: 'A rebuilt engine, with 3D when you want it.',
            subtitle:
                '2.0 is a breaking release, out first as a dev preview. The '
                'highlights:',
          ),
          const SizedBox(height: 36),
          Container(
            padding: EdgeInsets.all(context.isMobileOrSmaller ? 20 : 32),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardGrid(
                  maxColumns: 2,
                  minItemWidth: 340,
                  spacing: 8,
                  children: [
                    for (final (icon, title, body, url) in items)
                      _NewItem(icon: icon, title: title, body: body, url: url),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: p.border),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const AppButton(
                      label: 'Migrating from 1.x',
                      url: '/docs/migration',
                      trailingIcon: Icons.arrow_forward_rounded,
                    ),
                    const AppButton.secondary(
                      label: 'Full changelog',
                      url: Links.engineChangelog,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Need stable today? ${Versions.engineStable} is the '
                        'latest 1.x release.',
                        style: t.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewItem extends StatelessWidget {
  const _NewItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String body;
  final String url;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return HoverCard(
      url: url,
      color: Colors.transparent,
      bordered: false,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.h4),
                const SizedBox(height: 4),
                Text(body, style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subsystems
// ─────────────────────────────────────────────────────────────────────────────

class _Subsystems extends StatelessWidget {
  const _Subsystems();

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Subsystems',
            title: 'Everything a game needs, nothing bolted on.',
            subtitle:
                'Each part is a set of components and systems in the same '
                'world, so they work together without glue code.',
          ),
          const SizedBox(height: 40),
          CardGrid(
            children: [
              for (final area in FeaturesData.home)
                FeatureCard(
                  icon: area.icon,
                  title: area.name,
                  body: area.summary,
                  url: area.docsPath,
                  linkLabel: 'Read the docs',
                ),
            ],
          ),
          const SizedBox(height: 32),
          const AppButton.secondary(
            label: 'See every feature',
            url: '/features',
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Get started
// ─────────────────────────────────────────────────────────────────────────────

class _GetStarted extends StatelessWidget {
  const _GetStarted();

  static const _quickStart = '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  // A floor, and a ball that falls onto it.
  engine.world
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, 200, 0)),
      RectangleComponent(width: 600, height: 24),
      Collider2D(shape: ColliderShape2D.matchShape),
    ], name: 'Floor')
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, -150, 0)),
      CircleComponent(radius: 24),
      RigidBody2D(),
      Collider2D(shape: ColliderShape2D.matchShape),
    ], name: 'Ball');

  engine.start();
  runApp(MaterialApp(home: GameWidget(engine: engine)));
}''';

  @override
  Widget build(BuildContext context) {
    final t = context.type;

    Widget step(String title, String body, Widget command) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.h4),
        const SizedBox(height: 6),
        Text(body, style: t.bodySmall),
        const SizedBox(height: 14),
        command,
      ],
    );

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Get started',
            title: 'From zero to a running game.',
            subtitle:
                'Start a new game with the CLI, or add the engine to a '
                'Flutter app you already have.',
          ),
          const SizedBox(height: 40),
          SplitRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            gap: 40,
            startFlex: 5,
            endFlex: 6,
            start: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                step(
                  'A new game, with the CLI',
                  'Installs the just tool, creates a game from the template, '
                      'and runs it with the editor.',
                  const CodeBlock(
                    language: 'bash',
                    title: 'terminal',
                    code:
                        'dart pub global activate just_core_cli\n'
                        'just create my_game\n'
                        'cd my_game\n'
                        'just game run --editor',
                  ),
                ),
                const SizedBox(height: 32),
                step(
                  'In an existing Flutter app',
                  'Add the 2.0 preview. Pin the dev version: a plain ^2.0.0 '
                      'does not pick up dev releases.',
                  const CommandLine(
                    'flutter pub add "just_game_engine:${Versions.engineConstraint}"',
                  ),
                ),
                const SizedBox(height: 32),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Read the quick start',
                      url: '/docs/quick-start',
                      trailingIcon: Icons.arrow_forward_rounded,
                    ),
                    AppButton.secondary(
                      label: 'Installation guide',
                      url: '/docs/installation',
                    ),
                  ],
                ),
              ],
            ),
            end: const CodeBlock(code: _quickStart, title: 'lib/main.dart'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resources
// ─────────────────────────────────────────────────────────────────────────────

class _Resources extends StatelessWidget {
  const _Resources();

  static const items = [
    (
      Icons.menu_book_outlined,
      'Documentation',
      'Guides for every subsystem, written for 2.0.',
      '/docs/introduction',
    ),
    (
      Icons.data_object_rounded,
      'API reference',
      'Every public class and member, on pub.dev.',
      Links.apiReference,
    ),
    (
      Icons.code_rounded,
      'Source code',
      'The engine, editor and CLI repositories on GitHub.',
      Links.org,
    ),
    (
      Icons.play_circle_outline_rounded,
      'Live examples',
      'Runnable demos in the browser, still written for 1.x.',
      Links.examples,
    ),
    (
      Icons.forum_outlined,
      'Discord',
      'Ask questions and share what you build.',
      Links.discord,
    ),
    (
      Icons.inventory_2_outlined,
      'pub.dev',
      'The engine and the rest of the just_* packages.',
      Links.publisher,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Resources',
            title: 'Docs, API reference and source.',
          ),
          const SizedBox(height: 36),
          CardGrid(
            minItemWidth: 300,
            spacing: 16,
            children: [
              for (final (icon, title, body, url) in items)
                HoverCard(
                  url: url,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(icon, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(title, style: t.h4)),
                                const SizedBox(width: 6),
                                Icon(
                                  isExternal(url)
                                      ? Icons.north_east_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: p.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(body, style: t.bodySmall),
                          ],
                        ),
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
