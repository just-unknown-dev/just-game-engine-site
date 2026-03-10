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
      description: 'Raw dart:ui Canvas draws — no bloated dependency tree.',
      icon: Icons.speed,
    ),
    ComparisonPoint(
      title: 'Explicit Control',
      description:
          'Linear data flows. No magic. Full understanding of internals.',
      icon: Icons.code,
    ),
  ];

  /// Getting Started docs content.
  static const String gettingStartedContent =
      '''Just Game Engine is a comprehensive 2D game engine built for Flutter. It provides everything you need to create high-performance games with rich visual effects, animations, and physics.

**Prerequisites:**
• Flutter SDK 3.11.0 or higher
• Dart 3.0.0 or higher

**Installation:**
Add the package to your pubspec.yaml:

```
dependencies:
  just_game_engine: ^1.1.0
```

Then run:
```
flutter pub get
```

**Quick Start:**
1. Create an Engine instance and initialize it
2. Configure rendering, physics, and input
3. Add entities or renderables
4. Start the engine loop
5. Embed with GameWidget in your Flutter app

See the code example on the right for a complete minimal setup.''';

  /// Getting started code example.
  static const String gettingStartedCode =
      '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine();
  await engine.initialize();

  // Add a simple renderable
  engine.rendering.addRenderable(
    CircleRenderable(
      radius: 50,
      fillColor: Colors.blue,
      position: Offset.zero,
    ),
  );

  engine.start();

  runApp(MaterialApp(
    home: Scaffold(
      body: GameWidget(engine: engine),
    ),
  ));
}''';
}
