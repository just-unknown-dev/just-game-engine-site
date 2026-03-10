import 'package:flutter/material.dart';

import 'engine_models.dart';

/// Roadmap data for the Roadmap page.
abstract final class RoadmapData {
  static const List<RoadmapItem> roadmapItems = [
    // Q1 2026 - All 11 Engine Subsystems Completed
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
          'Data-oriented ECS with 13 built-in components, 9 systems, entity queries, and hierarchy support.',
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

    // Q2 2026
    RoadmapItem(
      title: 'Physics Engine v2.0',
      description:
          'Enhanced SAT collision detection with improved performance and new collision shapes.',
      status: 'In Progress',
      quarter: 'Q2 2026',
      icon: Icons.science,
      tags: ['Physics', 'Performance'],
    ),
    RoadmapItem(
      title: 'Raycasting v1.0',
      description:
          '2D raycasting system for line-of-sight, shooting mechanics, and visibility checks.',
      status: 'In Progress',
      quarter: 'Q2 2026',
      icon: Icons.linear_scale_rounded,
      tags: ['Physics', 'Performance'],
    ),
    RoadmapItem(
      title: 'Tilemap Editor Integration',
      description:
          'Native support for Tiled and LDtk map formats with auto-collision generation.',
      status: 'In Progress',
      quarter: 'Q2 2026',
      icon: Icons.grid_on,
      tags: ['Tilemaps', 'Tools'],
    ),
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
