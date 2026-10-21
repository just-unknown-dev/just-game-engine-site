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
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/screenshot.dart';

@RoutePage()
class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'editor'},
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      children: [
        _Hero(),
        _Gallery(),
        _Features(),
        _Setup(),
        _NeverShips(),
        _Shortcuts(),
        _PluginsAndKits(),
      ],
    );
  }
}

const _shots = [
  (
    '2D scene',
    Shot(
      'assets/screenshots/editor_2d_scene.webp',
      'The editor over a 2D level: scene tree, inspector, gizmo, game camera '
          'preview and the Assets dock.',
    ),
  ),
  (
    '3D scene',
    Shot(
      'assets/screenshots/editor_3d_scene.webp',
      'A 3D scene: orbit view, 3D gizmo, level aids, game camera preview and '
          'materials in the Assets dock.',
    ),
  ),
  (
    'Level Designer',
    Shot(
      'assets/screenshots/editor_2d_level_designer.webp',
      'The Level Designer: a tile stamp over the Level Map, its layers, the '
          'tileset palette and the tool strip.',
    ),
  ),
  (
    '3D Level Designer',
    Shot(
      'assets/screenshots/editor_3d_level_designer.webp',
      'The 3D Level Designer in four views, with the World Builder kit.',
    ),
  ),
  (
    '2D materials',
    Shot(
      'assets/screenshots/editor_2d_material.webp',
      'The 2D Material window: a normal-mapped wall under a light, its effect '
          'cards and the light\'s settings.',
    ),
  ),
  (
    '3D materials',
    Shot(
      'assets/screenshots/editor_3d_material.webp',
      'The 3D Material window: a material variant on a ball, lit by the '
          'scene\'s sky.',
    ),
  ),
  (
    'Timeline',
    Shot(
      'assets/screenshots/editor_timeline.webp',
      'The Timeline dock\'s curves and a motion path drawn in the level.',
    ),
  ),
  (
    'Physics',
    Shot(
      'assets/screenshots/editor_physics.webp',
      'A collider edited with handles, the rigid body\'s card and the Physics '
          'Layers dock.',
    ),
  ),
  (
    'Play-testing',
    Shot(
      'assets/screenshots/editor_play_test.webp',
      'A play-test running in the editor, with the Profiler dock.',
    ),
  ),
  (
    'Settings',
    Shot(
      'assets/screenshots/editor_settings.webp',
      'Settings on the Accessibility page.',
    ),
  ),
];

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
          startFlex: 5,
          endFlex: 6,
          gap: 48,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill(label: 'just_game_engine_editor ${Versions.editor}'),
              const SizedBox(height: 22),
              Text('A level editor that runs inside your game.', style: t.h1),
              const SizedBox(height: 18),
              Text(
                'Start your game\'s editor entry point in a debug build, and '
                'the running game becomes the scene you edit. Scenes, levels, '
                'physics, cameras, timelines, materials and play-testing share '
                'one undo stack, and a release build holds none of it.',
                style: t.lead,
              ),
              const SizedBox(height: 30),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Set it up',
                    url: '/docs/editor',
                    trailingIcon: Icons.arrow_forward_rounded,
                  ),
                  AppButton.secondary(label: 'GitHub', url: Links.editorRepo),
                  AppButton.secondary(label: 'pub.dev', url: Links.editorPub),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Edits on Windows, macOS and Linux  ·  Press F1 to show or hide',
                style: t.caption,
              ),
            ],
          ),
          end: ScreenshotFrame(shot: _shots.first.$2, glow: true),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Gallery extends StatefulWidget {
  const _Gallery();

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final (_, shot) = _shots[_index];
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Tour',
            title: 'Everything in one window.',
            subtitle:
                'The levels are the templates\' showcase scenes; the extra '
                'toolbar buttons come from modules the templates install.',
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _shots.length; i++)
                ChoiceChip(
                  label: Text(_shots[i].$1),
                  selected: i == _index,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _index = i),
                  labelStyle: t.label.copyWith(
                    fontSize: 13.5,
                    color: i == _index ? p.accentText : p.textSecondary,
                  ),
                  backgroundColor: p.surface,
                  selectedColor: p.accentSoft,
                  side: BorderSide(
                    color: i == _index
                        ? p.accent.withValues(alpha: 0.5)
                        : p.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: ScreenshotFrame(key: ValueKey(_index), shot: shot),
          ),
          const SizedBox(height: 14),
          Text(shot.caption, style: t.caption),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Features extends StatelessWidget {
  const _Features();

  static const items = [
    (
      Icons.view_in_ar_outlined,
      '2D and 3D scenes',
      'Orbit-and-fly views, a 3D gizmo, picking by ray and placement on '
          'surfaces. Your game\'s own renderer draws the scene.',
    ),
    (
      Icons.data_object_rounded,
      'Scenes are JSON',
      'Saved in assets/scenes/ with the play order in scenes.json. The game '
          'loads the same files, and autosave keeps backups.',
    ),
    (
      Icons.play_circle_outline_rounded,
      'Play-testing in place',
      'Play, Pause, Step, Restart and speed, a game-camera preview, and the '
          'level put back exactly as authored on Stop.',
    ),
    (
      Icons.grid_on_rounded,
      'Level Designer',
      'Tiles on square, isometric, staggered and hexagonal grids, a Tileset '
          'Editor, Tiled import and export, and a 3D designer.',
    ),
    (
      Icons.tune_rounded,
      'Inspector',
      'Built from each component\'s runtime definition: an editor for every '
          'field type, with colour, tag and entity pickers.',
    ),
    (
      Icons.sports_basketball_outlined,
      'Physics',
      '2D and 3D bodies that look and work alike, collider handles in the '
          'viewport and named collision layers.',
    ),
    (
      Icons.videocam_outlined,
      'Cameras',
      'Virtual cameras previewed while you work, with their frames, zones '
          'and bounds drawn over the level.',
    ),
    (
      Icons.palette_outlined,
      'Materials',
      '2D and 3D materials edited in a window with a live preview, presets '
          'and variants.',
    ),
    (
      Icons.view_timeline_outlined,
      'Timeline',
      'Animate any component field with a dope sheet, curve editor, record '
          'mode and motion paths in the viewport.',
    ),
    (
      Icons.dashboard_outlined,
      'Docks',
      'Console, Assets, Timeline, Profiler, World, Problems, Tags, Physics '
          'Layers, History, Animator and Search.',
    ),
    (
      Icons.accessibility_new_rounded,
      'Accessibility',
      'Text size, high contrast, colour-blind safe colours, reduced motion, '
          'bigger targets and a visible focus ring.',
    ),
    (
      Icons.bolt_rounded,
      'Hot reload and modules',
      'Hot reload brings registries, modules and component definitions up to '
          'the code. Games and kits extend it with EditorModule.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Features',
            title: 'Made for building levels, not only placing sprites.',
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

class _Setup extends StatelessWidget {
  const _Setup();

  static const _entryPoint =
      '''// lib/main_editor.dart: the editor's own entry point.
// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine_editor/just_game_engine_editor.dart';

import 'main.dart' show MyGame;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kDebugMode is a constant: release builds keep only the else branch.
  if (kDebugMode) {
    await _runEditor();
  } else {
    runApp(const MyGame());
  }
}

Future<void> _runEditor() async {
  final engine = Engine();
  await engine.initialize();
  final plugin = await JustGameEditorPlugin.register(
    engine: engine,
    modules: [MyGameModule()],
  );
  engine.start();
  runApp(MaterialApp(
    home: JustGameEngineEditor(engine: engine, plugin: plugin),
  ));
}''';

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;

    Widget step(int n, String title, String body, Widget content) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
              border: Border.all(color: p.accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$n',
              style: t.label.copyWith(color: p.accentText, fontSize: 14),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(title, style: t.h4),
                const SizedBox(height: 6),
                Text(body, style: t.bodySmall),
                const SizedBox(height: 14),
                content,
              ],
            ),
          ),
        ],
      );
    }

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Set up',
            title: 'Three steps to your first level.',
            subtitle:
                'A game made with just create has all of this already. To add '
                'the editor to a game you already have:',
          ),
          const SizedBox(height: 40),
          step(
            1,
            'Add it as a dev dependency',
            'Only the editor entry point imports it, so it never ships.',
            const CommandLine('flutter pub add --dev just_game_engine_editor'),
          ),
          const SizedBox(height: 32),
          step(
            2,
            'Give the editor an entry point of its own',
            'Keep lib/main.dart free of the editor. Branching on kDebugMode '
                'lets the compiler drop the editor from profile and release '
                'builds.',
            const CodeBlock(code: _entryPoint, title: 'lib/main_editor.dart'),
          ),
          const SizedBox(height: 32),
          step(
            3,
            'Run it from the project folder',
            'The editor reads and saves the project\'s files, so start it from '
                'the project root. Press F1 to show or hide it.',
            const CommandLine('flutter run -t lib/main_editor.dart -d windows'),
          ),
          const SizedBox(height: 36),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                label: 'Full setup guide',
                url: '/docs/editor',
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              AppButton.secondary(
                label: 'Start with the CLI',
                url: '/cli',
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NeverShips extends StatelessWidget {
  const _NeverShips();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return PageSection(
      child: SplitRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Release safety'),
            const SizedBox(height: 14),
            Text('Never part of a release build.', style: t.h2),
            const SizedBox(height: 14),
            Text(
              'A profile or release build of your game holds no editor code, '
              'and the CLI can prove it.',
              style: t.lead,
            ),
          ],
        ),
        end: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckList([
              'The game\'s entry point, lib/main.dart, never imports the '
                  'editor.',
              'The editor entry point branches on kDebugMode, so the compiler '
                  'drops the editor outside debug builds.',
              'Editor packages are dev dependencies, so Windows and Linux '
                  'release builds leave out the native plugins only they '
                  'bring.',
              'just game build <platform> builds, then checks the build holds '
                  'no editor.',
            ]),
            SizedBox(height: 12),
            CommandLine('just game build windows'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  static const keys = [
    (['F1'], 'Show or hide the editor'),
    (['F2'], 'Open or shut the dock panel'),
    (['F3'], 'Open or close the Level Designer'),
    (['F4'], 'The game camera preview'),
    (['F5'], 'Play or stop'),
    (['Shift', 'F5'], 'Restart the play-test'),
    (['F6'], 'Pause or resume'),
    (['F10'], 'Step one frame'),
    (['Q', 'W', 'E', 'R'], 'All, Move, Scale, Rotate'),
    (['Ctrl', 'S'], 'Save the scene'),
    (['Ctrl', 'Z'], 'Undo'),
    (['Ctrl', ','], 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Shortcuts',
            title: 'The keys to learn first.',
            subtitle:
                'Every command\'s keys can be changed in Settings → Keyboard. '
                'On macOS, Cmd stands in for Ctrl.',
          ),
          const SizedBox(height: 32),
          CardGrid(
            maxColumns: 2,
            minItemWidth: 320,
            spacing: 10,
            children: [
              for (final (combo, action) in keys)
                HoverCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(action, style: t.bodySmall)),
                      const SizedBox(width: 12),
                      for (final (i, key) in combo.indexed) ...[
                        if (i > 0) const SizedBox(width: 6),
                        _KeyCap(key),
                      ],
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

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          top: BorderSide(color: p.border),
          left: BorderSide(color: p.border),
          right: BorderSide(color: p.border),
          bottom: BorderSide(color: p.borderStrong, width: 2),
        ),
      ),
      child: Text(
        label,
        style: context.type.code.copyWith(
          fontSize: 12.5,
          color: p.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PluginsAndKits extends StatelessWidget {
  const _PluginsAndKits();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;

    Widget kind(
      IconData icon,
      String title,
      String body,
      String where,
      List<String> examples,
    ) {
      return HoverCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon),
            const SizedBox(height: 18),
            Text(title, style: t.h3),
            const SizedBox(height: 8),
            Text(body, style: t.bodySmall),
            const SizedBox(height: 16),
            Text(
              where,
              style: t.code.copyWith(fontSize: 13, color: p.accentText),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in examples)
                  Pill(label: e, dot: false, color: p.textSecondary),
              ],
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
            eyebrow: 'Extend it',
            title: 'Plugins and kits from the Asset Store.',
            subtitle:
                'Press Ctrl+Shift+G in the editor to browse, install, update '
                'and remove items, or use the same store from a terminal.',
          ),
          const SizedBox(height: 36),
          CardGrid(
            maxColumns: 2,
            minItemWidth: 320,
            children: [
              kind(
                Icons.extension_outlined,
                'Plugin',
                'Tools for the editor only: a window, a dock, an asset '
                    'editor. Nothing of it ships.',
                'dev_dependencies',
                ['just_sprite_editor', 'just_input_editor'],
              ),
              kind(
                Icons.inventory_2_outlined,
                'Kit',
                'Game code and its editor half: components and systems the '
                    'game runs, plus the prefabs, tools and fields to place '
                    'them.',
                'dependencies',
                [
                  'just_platformer_kit',
                  'just_third_person_kit',
                  'just_world_builder_kit',
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const CodeBlock(
            language: 'bash',
            title: 'terminal',
            code:
                'just add just_sprite_editor      # just store install\n'
                'just remove just_sprite_editor   # just store uninstall\n'
                'just store list',
          ),
          const SizedBox(height: 28),
          _PlatformNote(),
        ],
      ),
    );
  }
}

class _PlatformNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: p.info, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: p.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Editing runs in debug builds on Windows, macOS and Linux, '
              'started from the project folder. On a phone, a tablet or the '
              'web the game runs without the editor. On macOS, set '
              'com.apple.security.app-sandbox to false in '
              'DebugProfile.entitlements so the editor can write the project.',
              style: t.bodySmall.copyWith(
                color: p.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
