import 'package:flutter/material.dart';

enum RoadmapStatus {
  shipped('Shipped'),
  inProgress('In progress'),
  next('Next');

  const RoadmapStatus(this.label);
  final String label;
}

class RoadmapItem {
  const RoadmapItem({
    required this.title,
    required this.when,
    required this.description,
    required this.status,
    required this.icon,
    this.tags = const [],
    this.url,
  });

  final String title;

  /// A release date, or a rough "when" for work not yet released.
  final String when;
  final String description;
  final RoadmapStatus status;
  final IconData icon;
  final List<String> tags;

  /// Where to read more: a changelog, a docs page.
  final String? url;
}

/// Built from the engine, editor and CLI changelogs. Newest first in each
/// group.
abstract final class RoadmapData {
  static const items = <RoadmapItem>[
    // ── Next ─────────────────────────────────────────────────────
    RoadmapItem(
      title: '3.0: deprecated APIs removed',
      when: 'Later',
      status: RoadmapStatus.next,
      icon: Icons.cleaning_services_outlined,
      description:
          'The APIs deprecated in 2.0 go: Engine.getSystem, the legacy '
          'renderable path, Engine.parallax and ParallaxSystem, '
          'onRenderBackground/onRenderOverlay, TagComponent.tag, '
          'HierarchySystem and Entity.generation.',
      tags: ['Engine', 'Breaking'],
      url: '/docs/migration',
    ),
    RoadmapItem(
      title: '3D renderer: incremental updates',
      when: 'Next',
      status: RoadmapStatus.next,
      icon: Icons.view_in_ar_outlined,
      description:
          'Today the 3D scene renderer re-adds every model instance when '
          'it rebuilds: fine at scene load, not for spawning many entities '
          'each frame. Local-space timeline tracks are also still to come.',
      tags: ['3D', 'Timelines'],
    ),
    RoadmapItem(
      title: 'Live audio controls',
      when: 'Next',
      status: RoadmapStatus.next,
      icon: Icons.graphic_eq_rounded,
      description:
          'Change the pitch, pan, speed and loop of a sound while it plays, '
          'and apply channel volume to streams. Waits on an update to '
          'just_audio_engine.',
      tags: ['Audio'],
    ),
    RoadmapItem(
      title: 'Joint anchors and jointed bodies',
      when: 'Next',
      status: RoadmapStatus.next,
      icon: Icons.link_rounded,
      description:
          'Pass joint anchors to the physics engine, stop the pure-Dart '
          'backend pushing jointed bodies apart, and let native queries see '
          'bodies with mask 0. Waits on an update to just_physics_engine.',
      tags: ['Physics'],
    ),
    // ── In progress ──────────────────────────────────────────────
    RoadmapItem(
      title: 'Just Game Engine 2.0 stable',
      when: 'Now',
      status: RoadmapStatus.inProgress,
      icon: Icons.rocket_launch_outlined,
      description:
          'The 2.0 dev series continues (2.0.0-dev.2 is on pub.dev) '
          'towards a stable release. Until then, 1.6.1 is the latest '
          'stable version.',
      tags: ['Engine', 'Release'],
      url: '/docs/migration',
    ),
    RoadmapItem(
      title: 'Examples for 2.0',
      when: 'Now',
      status: RoadmapStatus.inProgress,
      icon: Icons.play_circle_outline_rounded,
      description:
          'The live examples are still written for 1.x. Meanwhile, the '
          'engine repository\'s example and the templates\' showcase scenes '
          'show 2.0.',
      tags: ['Examples', 'Docs'],
    ),
    // ── Shipped ──────────────────────────────────────────────────
    RoadmapItem(
      title: 'just CLI 0.1',
      when: 'Oct 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.terminal_rounded,
      description:
          'just_core_cli and its game plugin, just_game_engine_cli: create, '
          'run and build games, manage scenes, check that releases hold no '
          'editor, and upgrade the engine\'s packages as one set.',
      tags: ['CLI', 'New'],
      url: '/cli',
    ),
    RoadmapItem(
      title: 'Level editor 0.1 (dev)',
      when: 'Oct 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.design_services_outlined,
      description:
          'just_game_engine_editor: a level editor that runs inside your '
          'game in debug builds. 2D and 3D scenes, Level Designer, '
          'materials, timelines, physics and play-testing on one undo stack.',
      tags: ['Editor', 'New'],
      url: '/editor',
    ),
    RoadmapItem(
      title: 'Just Game Engine 2.0 (dev)',
      when: 'Oct 15, 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.auto_awesome_outlined,
      description:
          'A breaking release: engines you create and dispose, opt-in 3D '
          'graphics and Jolt 3D physics, Box2D v3 2D physics, virtual '
          'cameras, timelines, level maps, action-based input and scene '
          'format 9 with migrations.',
      tags: ['Engine', 'Breaking'],
      url: '/docs/migration',
    ),
    RoadmapItem(
      title: 'Just Game Engine 1.6',
      when: 'May 30, 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.emoji_events_outlined,
      description:
          'A developer terminal, game services (achievements, sign-in, '
          'leaderboards, currency, inventory, ads), subtitles and '
          'checkpoints; physics moved to just_physics_engine. 1.6.1 '
          '(Aug 2) added unified shape styling.',
      tags: ['Engine'],
    ),
    RoadmapItem(
      title: 'Just Game Engine 1.5',
      when: 'Apr 4, 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.movie_filter_outlined,
      description:
          'Post-processing shaders, sprite atlases, deterministic effects, '
          'localization and Yarn Spinner dialogue; audio on '
          'just_audio_engine. Later 1.5 releases added shape components and '
          'just_debugger.',
      tags: ['Engine'],
    ),
    RoadmapItem(
      title: 'Just Game Engine 1.4',
      when: 'Mar 21, 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.speed_rounded,
      description:
          'An architecture and performance overhaul, parallax backgrounds '
          'and a virtual joystick widget.',
      tags: ['Engine'],
    ),
    RoadmapItem(
      title: 'Just Game Engine 1.1 – 1.3',
      when: 'Mar 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.grid_on_rounded,
      description:
          'Rigid-body physics with impulse resolution (1.1), raycasting, '
          'ray tracing and audio components (1.2), and Tiled maps in the '
          'ECS (1.3).',
      tags: ['Engine'],
    ),
    RoadmapItem(
      title: 'Just Game Engine 1.0',
      when: 'Feb 16, 2026',
      status: RoadmapStatus.shipped,
      icon: Icons.flag_outlined,
      description:
          'The first release: the game loop, rendering, sprites, animation, '
          'particles, physics, ECS, input, assets and audio.',
      tags: ['Engine'],
    ),
  ];
}
