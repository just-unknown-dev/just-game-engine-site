import 'package:flutter/material.dart';

import 'engine_models.dart';

/// Roadmap data for the Roadmap page.
abstract final class RoadmapData {
  static const List<RoadmapItem> roadmapItems = [
    // Q1 2026 - Core 1.x foundation and feature expansion
    RoadmapItem(
      title: 'Core Engine v1.0',
      description:
          'Stable release of the core game loop with fixed timestep, lifecycle management, and time scaling.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.memory,
      tags: ['Core', 'Stable'],
    ),
    RoadmapItem(
      title: 'Rendering Engine v1.0',
      description:
          'Direct Canvas rendering with cameras, viewport management, and custom shaders.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.brush,
      tags: ['Rendering', 'Visual'],
    ),
    RoadmapItem(
      title: 'Sprite System v1.0',
      description:
          'Sprite loading, atlas support, 9-slice scaling, and texture batching.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.image,
      tags: ['Sprites', 'Visual'],
    ),
    RoadmapItem(
      title: 'Animation System v1.0',
      description:
          'Frame-based and interpolated animations with state machines, easing curves, and Lottie support.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.animation,
      tags: ['Animation', 'Visual'],
    ),
    RoadmapItem(
      title: 'Particle Effects v1.0',
      description:
          'GPU-accelerated particle system with 8 emitter shapes, blending modes, and emission patterns.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.auto_awesome,
      tags: ['Particles', 'Visual'],
    ),
    RoadmapItem(
      title: 'Physics Engine v1.0',
      description:
          'Rigid body physics with SAT collision detection, elastic response, and collision layers.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.science,
      tags: ['Physics', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Scene Graph v1.0',
      description:
          'Hierarchical scene tree with parent-child transforms, named lookups, and multi-scene management.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.account_tree,
      tags: ['Scene', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Entity-Component System v1.0',
      description:
          'Data-oriented ECS with 14 built-in components, 9 systems, entity queries, and hierarchy support.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.widgets,
      tags: ['ECS', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Input Management v1.0',
      description:
          'Unified polling-based input for keyboard, mouse, touch, and gamepad with dead zone support.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.gamepad,
      tags: ['Input', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Parallax Background System v1.0',
      description:
          'First-class multi-layer parallax backgrounds with camera-relative depth scrolling and auto-scroll.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.layers,
      tags: ['Parallax', 'Visual'],
    ),
    RoadmapItem(
      title: 'Virtual Joystick Widget v1.0',
      description:
          'Reusable touch joystick with fixed/floating layouts and ECS joystick component integration.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.touch_app,
      tags: ['Input', 'Mobile'],
    ),
    RoadmapItem(
      title: 'Asset Management v1.0',
      description:
          'Efficient asset loading and caching for images, audio, text, JSON, and binary files with bundle support.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.folder_open,
      tags: ['Assets', 'Utilities'],
    ),
    RoadmapItem(
      title: 'Audio Engine v1.0',
      description:
          'Multi-channel audio with master/music/SFX/voice/ambient channels, sound pooling, and fade effects.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.music_note,
      tags: ['Audio', 'Utilities'],
    ),

    RoadmapItem(
      title: 'Physics Engine v2.0',
      description:
          'Enhanced SAT collision detection with improved performance and new collision shapes.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.science,
      tags: ['Physics', 'Performance'],
    ),
    RoadmapItem(
      title: 'Raycasting v1.0',
      description:
          '2D raycasting system for line-of-sight, shooting mechanics, and visibility checks.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.linear_scale_rounded,
      tags: ['Raycasting', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Tilemap Editor Integration',
      description:
          'Native support for Tiled map formats via just_tiled with GPU-batched rendering.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.grid_on,
      tags: ['Tilemaps', 'Tools'],
    ),
    RoadmapItem(
      title: 'Reactive ECS v1.0',
      description:
          'Signal-driven ECS wrappers via just_signals for surgical UI updates without polling.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.bolt,
      tags: ['ECS', 'Reactive'],
    ),
    RoadmapItem(
      title: 'Post-Processing v1.0',
      description:
          'Full-screen FragmentShader passes, per-entity shader layers, and ECS PostProcessSystem.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.filter,
      tags: ['Rendering', 'Visual'],
    ),
    RoadmapItem(
      title: 'Sprite Atlas v1.0',
      description:
          'Auto-detecting TexturePacker/Aseprite atlas parser with named regions and animation clips.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.view_comfy,
      tags: ['Sprites', 'Performance'],
    ),
    RoadmapItem(
      title: 'Deterministic Effects v1.0',
      description:
          'Tick-based effects with rollback support, JSON/binary serialization, and ECS integration.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.replay,
      tags: ['Effects', 'Multiplayer'],
    ),
    RoadmapItem(
      title: 'Localization v1.0',
      description:
          'Engine-wide i18n with namespace support, ICU-lite templating, fallback chains, and signal-driven widgets.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.language,
      tags: ['i18n', 'Utilities'],
    ),
    RoadmapItem(
      title: 'Narrative & Dialogue v1.0',
      description:
          'Full Yarn Spinner 2.x parser and runtime with ECS integration and ready-made Flutter UI widgets.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.chat_bubble_outline,
      tags: ['Story', 'Gameplay'],
    ),
    RoadmapItem(
      title: 'Math Module & Memory Management v1.0',
      description:
          'Mutable Vec2 type for zero-allocation physics, Quadtree spatial indexing, ObjectPool, and multi-tier CacheManager.',
      status: 'Completed',
      quarter: 'Q1 2026',
      icon: Icons.calculate,
      tags: ['Performance', 'Core'],
    ),

    // Q2 2026
    RoadmapItem(
      title: 'Documentation Overhaul',
      description:
          'Comprehensive API docs, tutorials, and video guides for all subsystems.',
      status: 'In Progress',
      quarter: 'Q2 2026',
      icon: Icons.menu_book,
      tags: ['Docs', 'Community'],
    ),

    // Q3 2026
    RoadmapItem(
      title: 'Networking Module',
      description:
          'Real-time multiplayer support with WebSocket and UDP backends, client prediction, and lag compensation.',
      status: 'Planned',
      quarter: 'Q3 2026',
      icon: Icons.wifi,
      tags: ['Networking', 'Multiplayer'],
    ),
    RoadmapItem(
      title: 'Visual Scripting',
      description:
          'Node-based visual scripting system for rapid prototyping and non-programmer friendly game logic.',
      status: 'Planned',
      quarter: 'Q3 2026',
      icon: Icons.account_tree,
      tags: ['Tools', 'Scripting'],
    ),
    RoadmapItem(
      title: 'AI & Pathfinding',
      description:
          'Built-in A* pathfinding, behavior trees, and state machines for game AI.',
      status: 'Planned',
      quarter: 'Q3 2026',
      icon: Icons.psychology,
      tags: ['AI', 'Gameplay'],
    ),

    // Q4 2026
    RoadmapItem(
      title: '3D Support (Experimental)',
      description:
          'Basic 3D rendering support with mesh loading, lighting, and perspective cameras.',
      status: 'Planned',
      quarter: 'Q4 2026',
      icon: Icons.view_in_ar,
      tags: ['3D', 'Experimental'],
    ),
    RoadmapItem(
      title: 'Console Export',
      description:
          'Export support for Nintendo Switch, PlayStation, and Xbox platforms.',
      status: 'Planned',
      quarter: 'Q4 2026',
      icon: Icons.sports_esports,
      tags: ['Platform', 'Console'],
    ),
    RoadmapItem(
      title: 'Engine Editor v2.0',
      description:
          'Full-featured visual editor with scene editing, prefab system, and asset management.',
      status: 'Planned',
      quarter: 'Q4 2026',
      icon: Icons.edit,
      tags: ['Tools', 'Editor'],
    ),
  ];
}
