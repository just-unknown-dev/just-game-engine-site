import 'package:flutter/material.dart';

/// One area of the engine, as the Features page and the home page show it.
class FeatureArea {
  const FeatureArea({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.summary,
    required this.highlights,
    this.optIn = false,
  });

  /// Also the id of its docs page (`/docs/<id>`).
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final String summary;
  final List<String> highlights;

  /// True for parts a game turns on explicitly (3D).
  final bool optIn;

  String get docsPath => '/docs/$id';
}

abstract final class FeatureCategory {
  static const core = 'Core';
  static const graphics = 'Graphics';
  static const gameplay = 'Gameplay';
  static const audioContent = 'Audio & content';
  static const tooling = 'Tooling';

  static const all = [core, graphics, gameplay, audioContent, tooling];
}

/// What Just Game Engine 2.0 brings, from its README and changelog.
abstract final class FeaturesData {
  static const areas = <FeatureArea>[
    // ── Core ─────────────────────────────────────────────────────
    FeatureArea(
      id: 'ecs',
      name: 'ECS world',
      icon: Icons.hub_outlined,
      category: FeatureCategory.core,
      summary:
          'Entities, components and systems in a World, with archetype '
          'storage, cached queries and a typed event bus.',
      highlights: [
        'Archetype storage and cached queries',
        'Typed EventBus and a deferred command buffer',
        'Prefabs stamped out with world.instantiate',
        'Parent/child transform hierarchy',
        'Signal-based views of the ECS',
      ],
    ),
    FeatureArea(
      id: 'engine',
      name: 'Engine lifecycle',
      icon: Icons.power_settings_new_rounded,
      category: FeatureCategory.core,
      summary:
          'Engines you create, initialize, start and dispose. Standard '
          'systems are opt-in through EngineConfig.',
      highlights: [
        'Engine() and await initialize(), no singletons',
        'DefaultSystems.all, or headless for servers and tests',
        'Per-engine context, registries and extensions',
        'Fixed 1/60 s simulation step',
        'Services and plugins that start and stop with the engine',
      ],
    ),
    FeatureArea(
      id: 'scenes',
      name: 'Scenes',
      icon: Icons.account_tree_outlined,
      category: FeatureCategory.core,
      summary:
          'Levels are JSON scenes loaded at runtime: the same files the '
          'editor saves.',
      highlights: [
        'SceneLoader and a scenes.json play order',
        'ComponentDefinition describes each component once',
        'Older scene files migrate as they load',
        'Your own components through engine extensions',
      ],
    ),
    // ── Graphics ─────────────────────────────────────────────────
    FeatureArea(
      id: 'rendering',
      name: 'Rendering & layers',
      icon: Icons.layers_outlined,
      category: FeatureCategory.graphics,
      summary:
          'Self-drawing shapes, layers for draw order, batching, view '
          'culling, render hooks and parallax.',
      highlights: [
        'Rectangle, circle, capsule, polygon and line shapes',
        'Gradients and paint styles',
        'LayerComponent sets the draw order',
        'Parallax backgrounds',
        'Render statistics every frame',
      ],
    ),
    FeatureArea(
      id: 'sprites',
      name: 'Sprites & animation',
      icon: Icons.movie_filter_outlined,
      category: FeatureCategory.graphics,
      summary:
          'Sprites, clips from atlases, and animator state machines with '
          'blend trees.',
      highlights: [
        'TexturePacker and Aseprite atlases',
        'SpriteBatch draws a whole atlas in one call',
        'AnimatorGraph state machines driven by parameters',
        'Shared easing functions',
      ],
    ),
    FeatureArea(
      id: 'timelines',
      name: 'Timelines',
      icon: Icons.view_timeline_outlined,
      category: FeatureCategory.graphics,
      summary:
          'Keyframe any saved component field, and sequence sprite clips, '
          'camera shots, audio and events.',
      highlights: [
        'Keyframes and curves on any saved field',
        'Sprite, camera, audio, activation and event tracks',
        'Nested timelines',
        'Start one when something enters an area',
      ],
    ),
    FeatureArea(
      id: 'cameras',
      name: 'Virtual cameras',
      icon: Icons.videocam_outlined,
      category: FeatureCategory.graphics,
      summary:
          'Shots with priorities and blends, framing, confiners, noise, '
          'impulses and target groups.',
      highlights: [
        'A camera brain that blends between shots',
        'Dead and soft zones with lookahead',
        'Confiners, noise and impulse shakes',
        'Target groups, trigger areas and dolly paths',
      ],
    ),
    FeatureArea(
      id: 'particles',
      name: 'Particles & effects',
      icon: Icons.auto_awesome_outlined,
      category: FeatureCategory.graphics,
      summary:
          'Particle emitters with presets, deterministic tick-based '
          'effects, and fragment-shader post-processing.',
      highlights: [
        'Presets: explosion, fire, smoke, rain, snow and more',
        'Effects that serialize for networking and rollback',
        'Full-frame and per-entity shader passes',
      ],
    ),
    FeatureArea(
      id: 'graphics-3d',
      name: '3D graphics',
      icon: Icons.view_in_ar_outlined,
      category: FeatureCategory.graphics,
      optIn: true,
      summary:
          'glTF models, PBR materials, lights and environments on Flutter '
          'GPU, turned on when a game asks for them.',
      highlights: [
        'glTF and GLB models with skeletal animation',
        'Eleven primitive shapes with materials',
        'Directional, point and spot lights; sky and fog',
        'A 2D game ships none of the 3D code',
      ],
    ),
    // ── Gameplay ─────────────────────────────────────────────────
    FeatureArea(
      id: 'physics-2d',
      name: '2D physics',
      icon: Icons.sports_basketball_outlined,
      category: FeatureCategory.gameplay,
      summary:
          'Box2D v3 through FFI with a pure-Dart engine on the web: bodies, '
          'colliders, characters, joints and queries.',
      highlights: [
        'RigidBody2D and Collider2D, or a collider alone',
        'CharacterBody2D for slopes, steps and platforms',
        'Raycasts, circle casts and overlaps',
        'Collision and sensor events in the ECS',
      ],
    ),
    FeatureArea(
      id: 'physics-3d',
      name: '3D physics',
      icon: Icons.category_outlined,
      category: FeatureCategory.gameplay,
      optIn: true,
      summary:
          'Jolt Physics with the same names, fields and events as 2D, '
          'turned on when a game asks for it.',
      highlights: [
        'RigidBody3D, Collider3D and CharacterBody3D',
        'Box, sphere, capsule, cylinder, hull, mesh and height field',
        'Six joint types',
      ],
    ),
    FeatureArea(
      id: 'input',
      name: 'Input',
      icon: Icons.sports_esports_outlined,
      category: FeatureCategory.gameplay,
      summary:
          'Named actions over keyboard, mouse, gamepads and touch, with '
          'rebinding and local multiplayer.',
      highlights: [
        'Actions and bindings in an .input.json asset',
        'Saved rebinding overrides',
        'Local multiplayer with PlayerInputManager',
        'On-screen touch controls',
      ],
    ),
    FeatureArea(
      id: 'level-maps',
      name: 'Level maps',
      icon: Icons.grid_on_rounded,
      category: FeatureCategory.gameplay,
      summary:
          'Tile maps on four grid types, Tiled import and export, tile '
          'collision and editing while the game runs.',
      highlights: [
        'Orthogonal, isometric, staggered and hexagonal',
        'Collision from the tiles, with one-way platforms',
        'Terrain painting with Wang sets',
        'A built-in tileset for blocking out levels',
      ],
    ),
    FeatureArea(
      id: 'tags-spawners',
      name: 'Tags & spawners',
      icon: Icons.sell_outlined,
      category: FeatureCategory.gameplay,
      summary:
          'Indexed tags, entity targets by name or tag, and spawn points '
          'your game fills in.',
      highlights: [
        'findTagged and allTagged read an index',
        'EntityTarget names an entity spawned later',
        'Spawn points and spawners',
      ],
    ),
    // ── Audio & content ──────────────────────────────────────────
    FeatureArea(
      id: 'audio',
      name: 'Audio',
      icon: Icons.graphic_eq_rounded,
      category: FeatureCategory.audioContent,
      summary:
          'Channels, buses, effects, streams and 3D sound with distance '
          'fading, doppler and muffling.',
      highlights: [
        'Sound from entities with AudioSourceComponent',
        '3D sources heard relative to a listener',
        'On the web, audio starts at the first input',
      ],
    ),
    FeatureArea(
      id: 'assets',
      name: 'Assets & storage',
      icon: Icons.inventory_2_outlined,
      category: FeatureCategory.audioContent,
      summary:
          'An asset manager and a cache, with the engine keeping its data '
          'in a store of its own.',
      highlights: [
        'engine.assets loads and caches',
        'engine.cache for saved data',
        'GameAssetBundle loads a group in parallel',
      ],
    ),
    FeatureArea(
      id: 'localization',
      name: 'Localization',
      icon: Icons.translate_rounded,
      category: FeatureCategory.audioContent,
      summary:
          'Translations with namespaces, fallbacks, plurals and selects, '
          'and a localized-text widget.',
      highlights: [
        'One LocalizationManager per engine',
        'Plural and select forms',
        'Fallback chains between locales',
      ],
    ),
    FeatureArea(
      id: 'dialogue',
      name: 'Dialogue & subtitles',
      icon: Icons.forum_outlined,
      category: FeatureCategory.audioContent,
      summary:
          'Yarn Spinner 2.x scripts and timed subtitles, with ready-made '
          'dialogue widgets.',
      highlights: [
        'DialogueRunner and DialogueSystem',
        'Timed subtitles with SubtitleController',
        'Dialogue box widgets',
      ],
    ),
    // ── Tooling ──────────────────────────────────────────────────
    FeatureArea(
      id: 'game-widget',
      name: 'Flutter integration',
      icon: Icons.flutter_dash,
      category: FeatureCategory.tooling,
      summary:
          'The game draws inside GameWidget, with real Flutter widgets '
          'layered over it.',
      highlights: [
        'FPS counter, ECS debugger and developer terminal',
        'Overlays and widget layers with focus',
        'Ready-made widgets in widgets.dart',
      ],
    ),
    FeatureArea(
      id: 'debugging',
      name: 'Debugging & stats',
      icon: Icons.speed_rounded,
      category: FeatureCategory.tooling,
      summary:
          'Stats for the engine, world, physics and renderer, cheap enough '
          'to read every frame.',
      highlights: [
        'engine.performanceStats and frame budget',
        'Per-system timings',
        'Physics and render counters',
      ],
    ),
  ];

  /// The areas the home page shows.
  static const homeIds = [
    'ecs',
    'scenes',
    'physics-2d',
    'graphics-3d',
    'cameras',
    'sprites',
    'level-maps',
    'input',
    'audio',
  ];

  static List<FeatureArea> get home => [
    for (final id in homeIds) areas.firstWhere((a) => a.id == id),
  ];
}
