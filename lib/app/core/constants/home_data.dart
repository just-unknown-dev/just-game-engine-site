import 'package:flutter/material.dart';

import 'engine_models.dart';

/// Comparison and getting started data for the Home page.
abstract final class HomeData {
  /// Flame comparison highlights (used on Home page).
  static const List<ComparisonPoint> flameComparison = [
    ComparisonPoint(
      title: 'Pure ECS + Scene Graph',
      description:
          'Data-oriented architecture vs Flame\'s OOP-heavy component tree.',
      icon: Icons.widgets,
    ),
    ComparisonPoint(
      title: 'Fixed-Timestep Loop',
      description: 'Deterministic 60 UPS preventing the "spiral of death".',
      icon: Icons.timer,
    ),
    ComparisonPoint(
      title: 'Custom SAT Physics',
      description: 'Lightweight impulse-based physics vs heavy Forge2D.',
      icon: Icons.science,
    ),
    ComparisonPoint(
      title: 'Polling-Based Input',
      description: 'Unified input.keyboard.isKeyDown() in the update loop.',
      icon: Icons.gamepad,
    ),
    ComparisonPoint(
      title: 'Minimal Dependencies',
      description: 'Raw dart:ui Canvas draws - no bloated dependency tree.',
      icon: Icons.speed,
    ),
    ComparisonPoint(
      title: 'Explicit Control',
      description:
          'Linear data flows. No magic. Full understanding of internals.',
      icon: Icons.code,
    ),
    ComparisonPoint(
      title: 'Reactive ECS',
      description:
          'Signal-driven wrappers for surgical UI updates without polling.',
      icon: Icons.bolt,
    ),
    ComparisonPoint(
      title: 'Parallax Background System',
      description:
          'First-class multi-layer parallax via Engine.parallax for depth-rich scenes.',
      icon: Icons.layers,
    ),
    ComparisonPoint(
      title: 'Virtual Joystick',
      description:
          'Built-in mobile joystick widget and ECS joystick component support.',
      icon: Icons.touch_app,
    ),
    ComparisonPoint(
      title: 'Native Tiled Support',
      description:
          'GPU-batched TMX rendering via just_tiled with spatial queries.',
      icon: Icons.grid_on,
    ),
  ];

  /// Getting Started docs content.
  static const String gettingStartedContent =
      '''Just Game Engine is a lightweight, data-oriented 2D game engine for Flutter. It combines Entity-Component-System (ECS) architecture with a fixed-timestep game loop (60 UPS) to deliver deterministic, high-performance games.

**Prerequisites:**
• Flutter SDK 3.24.0 or higher
• Dart 3.24.0 or higher

**Installation:**
Add to your pubspec.yaml:

```
dependencies:
  just_game_engine: ^1.4.0
```

Then run:
```
flutter pub get
```

**Quick Start:**
1. Create and initialize an Engine
2. Set up the ECS World with Systems
3. Create Entities with Components
4. Embed GameWidget in your Flutter app
5. Run the engine

Check the code example for a complete minimal setup.''';

  /// Getting started code example.
  static const String gettingStartedCode =
      '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: MyGame()));
}

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  late final Engine _engine;
  late final World _world;
  final GlobalKey _gameWidgetKey = GlobalKey();

  Size _readViewportSize() {
    final renderObject = _gameWidgetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size;
    }
    return MediaQuery.sizeOf(context);
  }

  @override
  void initState() {
    super.initState();
    _engine = Engine();
    _init();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _engine.initialize();
    _world = _engine.world;

    // Add core ECS systems
    _world.addSystem(RenderSystem());

    // Create a player entity with ECS components
    _world.createEntityWithComponents([
      TransformComponent(
        position: Offset(
          _readViewportSize().width / 2,
          _readViewportSize().height / 2,
        ),
      ),
      VelocityComponent(velocity: const Offset(100, 0)),
      RenderableComponent(
        renderable: CircleRenderable(radius: 30, fillColor: Colors.blue),
      ),
    ], name: 'Player');

    _engine.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(key: _gameWidgetKey, engine: _engine),
    );
  }
}
''';
}
