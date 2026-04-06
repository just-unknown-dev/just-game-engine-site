import 'package:flutter/material.dart';

import 'engine_models.dart';

/// All engine subsystems data.
abstract final class SubsystemsData {
  static const List<EngineSubsystem> subsystems = [
    // ── 1. Core Engine ──────────────────────────────────────
    EngineSubsystem(
      id: 'core',
      name: 'Core Engine',
      icon: Icons.memory,
      category: SubsystemCategory.core,
      shortDescription:
          'Fixed timestep game loop with full lifecycle management, delta time tracking, and centralized system coordination.',
      features: [
        'Game Loop: Fixed timestep (60 UPS) with variable rendering',
        'State Management: Full lifecycle (initialize, start, pause, resume, stop)',
        'Time Management: Delta time, time scaling, FPS tracking',
        'System Coordination: Centralized management of all subsystems',
      ],
      apiClasses: [
        ApiClass(
          name: 'Engine',
          description:
              'Main engine orchestrator — entry point for all subsystems',
        ),
        ApiClass(
          name: 'GameLoop',
          description: 'Fixed timestep game loop (60 UPS)',
        ),
        ApiClass(
          name: 'TimeManager',
          description: 'Delta time tracking and time scaling',
        ),
        ApiClass(
          name: 'SystemManager',
          description: 'Centralized subsystem coordination',
        ),
      ],
      codeTitle: 'Basic Engine Setup',
      codeExample: '''import 'package:flutter/material.dart';
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
''',
      docsContent:
          '''The Core Engine is the heart of Just Game Engine. It provides a fixed-timestep game loop running at 60 updates per second, ensuring consistent and deterministic gameplay regardless of frame rate.

**Key Concepts:**
• The `Engine` class is the main orchestrator — it holds references to all subsystems (rendering, physics, input, audio, etc.).
• The `GameLoop` uses a fixed timestep to prevent the "spiral of death" common in variable delta-time loops.
• `TimeManager` provides delta time, total elapsed time, and time scaling for slow-motion or fast-forward effects.
• `SystemManager` coordinates initialization and shutdown of all subsystems in the correct order.

**Lifecycle:**
1. Create an `Engine()` instance
2. Call `engine.initialize()` to set up all subsystems
3. Configure your game (add renderables, entities, etc.)
4. Call `engine.start()` to begin the loop
5. Use `engine.pause()` / `engine.resume()` as needed
6. Call `engine.stop()` to clean up''',
    ),

    // ── 2. Rendering ────────────────────────────────────────
    EngineSubsystem(
      id: 'rendering',
      name: 'Rendering Engine',
      icon: Icons.brush,
      category: SubsystemCategory.visual,
      shortDescription:
          'High-performance 2D canvas rendering with camera controls, renderable objects, layer management, and debug visualization.',
      features: [
        '2D Canvas-Based Rendering with Flutter\'s Canvas API',
        'Renderable Objects: Circles, rectangles, lines, text, rays, and custom',
        'Ray Renderable: Glowing beam/laser visuals with configurable fade lifetime',
        'Camera System: Pan, zoom, and rotation with smooth transforms',
        'Layer Management: Z-order sorting for proper depth rendering',
        'Debug Visualization: Bounding boxes, coordinate grids, and performance metrics',
        'ECS Integration: GameWidget renders ECS entities via RenderSystem',
      ],
      apiClasses: [
        ApiClass(
          name: 'RenderingEngine',
          description: '2D rendering system manager',
        ),
        ApiClass(
          name: 'Camera',
          description: 'Camera transformation and controls',
        ),
        ApiClass(
          name: 'Renderable',
          description: 'Base class for all renderable objects',
        ),
        ApiClass(
          name: 'CircleRenderable',
          description: 'Renders circles with fill/stroke',
        ),
        ApiClass(
          name: 'RectangleRenderable',
          description: 'Renders rectangles with fill/stroke',
        ),
        ApiClass(
          name: 'LineRenderable',
          description: 'Renders lines between two points',
        ),
        ApiClass(
          name: 'TextRenderable',
          description: 'Renders text on the canvas',
        ),
        ApiClass(
          name: 'RayRenderable',
          description: 'Glowing beam/laser visual with fade lifetime',
        ),
        ApiClass(
          name: 'CustomRenderable',
          description: 'Custom draw callback for advanced rendering',
        ),
        ApiClass(
          name: 'GameWidget',
          description: 'Flutter widget for embedding the engine',
        ),
      ],
      codeTitle: 'Rendering & Camera',
      codeExample: '''// Add renderables
engine.rendering.addRenderable(
  CircleRenderable(
    radius: 50,
    fillColor: Colors.blue,
    position: Offset.zero,
  ),
);

engine.rendering.addRenderable(
  RectangleRenderable(
    size: Size(100, 60),
    fillColor: Colors.red,
    position: Offset(200, 100),
  ),
);

// Camera controls
engine.rendering.camera.moveBy(Offset(10, 0));
engine.rendering.camera.zoomBy(1.1);
engine.rendering.camera.lookAt(Offset(100, 100));
engine.rendering.camera.reset();''',
      docsContent:
          '''The Rendering Engine provides high-performance 2D drawing using Flutter's raw Canvas API for maximum performance.

**Renderable Objects:**
The engine comes with several built-in renderable types: `CircleRenderable`, `RectangleRenderable`, `LineRenderable`, `TextRenderable`, and `CustomRenderable`. Each supports position, rotation, scale, opacity, and z-order.

**Camera System:**
The `Camera` class provides pan, zoom, and rotation transforms. Use `screenToWorld()` and `worldToScreen()` to convert between coordinate spaces. The camera supports smooth interpolation for cinematic effects.

**GameWidget:**
`GameWidget` is the Flutter widget that hosts the engine's rendering. It handles the Flutter ↔ Engine bridge, including input event forwarding and frame scheduling.

**Layer Management:**
Renderables are sorted by their z-order value for proper depth rendering. Higher z-order values render on top.''',
    ),

    // ── 3. Parallax ─────────────────────────────────────────
    EngineSubsystem(
      id: 'parallax',
      name: 'Parallax Background System',
      icon: Icons.layers,
      category: SubsystemCategory.visual,
      shortDescription:
          'Multi-layer parallax backgrounds with camera-relative depth scrolling and optional auto-scroll per layer.',
      features: [
        'Layered Parallax: Ordered back-to-front depth layers',
        'Scroll Factors: Independent scrollFactorX / scrollFactorY per layer',
        'Auto-Scroll: velocityX / velocityY for ambient background motion',
        'Layer Styling: scale, repeat, offset, opacity, and tint controls',
        'Runtime Control: addBackground(), removeBackground(), and clear()',
        'Render Integration: Drawn in screen space before world rendering',
      ],
      apiClasses: [
        ApiClass(
          name: 'ParallaxLayer',
          description: 'Single parallax layer with depth and visual controls',
        ),
        ApiClass(
          name: 'ParallaxBackground',
          description: 'Ordered container managing multiple parallax layers',
        ),
        ApiClass(
          name: 'ParallaxSystem',
          description: 'Engine subsystem that updates and renders backgrounds',
        ),
      ],
      codeTitle: 'Parallax Setup',
      codeExample: '''final background = ParallaxBackground(
  layers: [
    ParallaxLayer.uniform(
      image: backTrees,
      scrollFactor: 0.15,
      repeat: true,
    ),
    ParallaxLayer.uniform(
      image: frontTrees,
      scrollFactor: 0.7,
      velocityX: -4,
      repeat: true,
    ),
  ],
);

engine.parallax.addBackground(background);

// In your update loop
engine.parallax.update(deltaTime, engine.rendering.camera.position);''',
      docsContent:
          '''The Parallax Background System adds cinematic depth to 2D scenes by compositing multiple image layers that move at different relative speeds.

**ParallaxLayer:**
Each layer supports camera-relative scroll factors (`scrollFactorX`, `scrollFactorY`) and optional independent motion (`velocityX`, `velocityY`). You can also control `scale`, `repeat`, `offset`, `opacity`, and `tint`.

**ParallaxBackground:**
Groups multiple layers in draw order (index 0 = furthest back). Use `addLayer()`, `insertLayer()`, and `removeLayer()` to change the stack at runtime.

**ParallaxSystem:**
Managed through `Engine.parallax`. Call `update(deltaTime, cameraPosition)` each frame; rendering is integrated with the engine background pass before camera-transformed world content.''',
    ),

    // ── 4. Sprites ──────────────────────────────────────────
    EngineSubsystem(
      id: 'sprites',
      name: 'Sprite System',
      icon: Icons.image,
      category: SubsystemCategory.visual,
      shortDescription:
          'Image rendering with sprite sheets, nine-slice scaling, and horizontal/vertical flipping.',
      features: [
        'Image Rendering: Load and display images with easy asset management',
        'Sprite Sheets: Manage multiple sprites in a single texture',
        'Nine-Slice Scaling: Scalable UI elements that maintain corner details',
        'Flipping: Horizontal and vertical sprite flipping',
      ],
      apiClasses: [
        ApiClass(
          name: 'Sprite',
          description: 'Single image rendering with position, rotation, scale',
        ),
        ApiClass(
          name: 'SpriteSheet',
          description: 'Texture atlas for efficient multi-sprite rendering',
        ),
        ApiClass(
          name: 'NineSliceSprite',
          description: 'Scalable sprite that preserves corner details',
        ),
      ],
      codeTitle: 'Sprite Setup',
      codeExample: '''// Create a sprite
final sprite = Sprite();
sprite.image = spriteSheetImage;
sprite.renderSize = const Size(64, 64);
sprite.position = const Offset(100, 100);

// Flip sprites
sprite.flipHorizontal = true;
sprite.flipVertical = false;

// Nine-slice for UI elements
final panel = NineSliceSprite(
  image: panelImage,
  centerSlice: Rect.fromLTRB(16, 16, 48, 48),
  size: Size(200, 100),
);''',
      docsContent:
          '''The Sprite System handles image-based rendering efficiently.

**Sprite:**
The `Sprite` class renders a single image with support for position, rotation, scale, opacity, and source rectangle (for selecting a region of a larger texture). Use `flipHorizontal` and `flipVertical` to mirror sprites.

**Sprite Sheets:**
`SpriteSheet` manages a texture atlas — a single image containing multiple sprite frames. Define frame dimensions and access individual frames by index for efficient rendering with minimal texture swaps.

**Nine-Slice Sprites:**
`NineSliceSprite` is ideal for UI elements like panels and buttons. It divides the image into 9 regions and scales only the center, preserving crisp corners and edges at any size.''',
    ),

    // ── 5. Animation ────────────────────────────────────────
    EngineSubsystem(
      id: 'animation',
      name: 'Animation System',
      icon: Icons.animation,
      category: SubsystemCategory.visual,
      shortDescription:
          'Frame-based sprite animations, property tweening with 15+ easing curves, sequences, and groups.',
      features: [
        'Sprite Animations: Frame-based playback from sprite sheets',
        'Property Tweening: Position, rotation, scale, opacity, and color',
        'Easing Functions: 15+ built-in curves (linear, quad, cubic, elastic, bounce)',
        'Animation Sequences: Chain animations to play in order',
        'Animation Groups: Run multiple animations in parallel',
        'Loop and Ping-Pong: Repeat or bounce back and forth',
        'Speed Control: Adjust playback speed dynamically (0.1x – 5.0x)',
      ],
      apiClasses: [
        ApiClass(
          name: 'SpriteAnimation',
          description: 'Frame-based sprite animation',
        ),
        ApiClass(
          name: 'PositionTween',
          description: 'Animate position between two points',
        ),
        ApiClass(name: 'RotationTween', description: 'Animate rotation angle'),
        ApiClass(
          name: 'ScaleTween',
          description: 'Animate uniform or non-uniform scale',
        ),
        ApiClass(name: 'OpacityTween', description: 'Animate opacity / alpha'),
        ApiClass(
          name: 'ColorTween',
          description: 'Animate color interpolation',
        ),
        ApiClass(
          name: 'AnimationSequence',
          description: 'Chain animations sequentially',
        ),
        ApiClass(
          name: 'AnimationGroup',
          description: 'Run animations in parallel',
        ),
        ApiClass(name: 'Easings', description: 'Library of 15+ easing curves'),
      ],
      codeTitle: 'Animations',
      codeExample: '''// Sprite animation from sprite sheet
final spriteAnim = SpriteAnimation.fromSpriteSheet(
  sprite: sprite,
  frameCount: 8,
  frameWidth: 64,
  frameHeight: 64,
  duration: 1.0,
  loop: true,
);
engine.animation.addAnimation(spriteAnim);
spriteAnim.play();

// Position tween
final moveAnim = PositionTween(
  target: myRenderable,
  start: Offset(-100, 0),
  end: Offset(100, 0),
  duration: 2.0,
  easing: Easings.easeInOutQuad,
  loop: true,
);
moveAnim.play();

// Animation sequence
final sequence = AnimationSequence(
  animations: [anim1, anim2, anim3],
  loop: true,
);
sequence.play();

// Control speed
moveAnim.speed = 2.0;  // 2x speed''',
      docsContent:
          '''The Animation System supports both frame-based sprite animations and property tweening.

**Sprite Animations:**
Use `SpriteAnimation.fromSpriteSheet()` to create frame-based animations. Specify the sprite, frame count, frame dimensions, and duration. Animations can loop, ping-pong, or play once.

**Property Tweens:**
Tween any visual property: `PositionTween`, `RotationTween`, `ScaleTween`, `OpacityTween`, and `ColorTween`. Each tween supports start/end values, duration, easing curves, looping, and speed control.

**Easing Functions:**
The `Easings` class provides 15+ curves: `linear`, `easeIn/Out/InOut` variants for quad, cubic, quart, quint, sine, expo, circ, elastic, bounce, and back.

**Composition:**
`AnimationSequence` chains animations to play one after another. `AnimationGroup` runs multiple animations simultaneously. Both support looping.''',
    ),

    // ── 6. Particles ────────────────────────────────────────
    EngineSubsystem(
      id: 'particles',
      name: 'Particle Effects',
      icon: Icons.auto_awesome,
      category: SubsystemCategory.visual,
      shortDescription:
          'Configurable particle emitters with built-in presets for fire, smoke, explosion, sparkle, rain, and snow.',
      features: [
        'Particle Emitters: Configurable emission rate, lifetime, and spawning',
        'Visual Properties: Size gradients, color gradients, velocity, and gravity',
        'Particle Shapes: Circles, squares, and stars',
        'Built-in Presets: Explosion, fire, smoke, sparkle, rain, and snow',
        'Custom Particles: Create your own particle systems',
      ],
      apiClasses: [
        ApiClass(
          name: 'ParticleEmitter',
          description: 'Configurable particle emission controller',
        ),
        ApiClass(
          name: 'Particle',
          description: 'Individual particle with position, velocity, lifetime',
        ),
        ApiClass(
          name: 'ParticleEffects',
          description: 'Built-in preset effects (fire, smoke, explosion, etc.)',
        ),
      ],
      codeTitle: 'Particle Effects',
      codeExample: '''// Create a fire effect
final fireEmitter = ParticleEffects.fire(
  position: Offset(100, 200),
)..emissionRate = 30;

particles.add(fireEmitter);

// Create an explosion
final explosion = ParticleEffects.explosion(
  position: Offset(0, 0),
);
particles.add(explosion);

// Render particles
rendering.addRenderable(
  CustomRenderable(
    onRender: (canvas, size) {
      for (final emitter in particles) {
        emitter.update(deltaTime);
        emitter.render(canvas, size);
      }
    },
  ),
);''',
      docsContent:
          '''The Particle System provides visually rich effects with minimal setup.

**ParticleEmitter:**
The core class that spawns and manages particles. Configure emission rate, particle lifetime, spawn area, initial velocity range, gravity, and visual properties (color gradient, size gradient, shape).

**Built-in Presets:**
`ParticleEffects` provides ready-to-use effects:
• `ParticleEffects.fire()` — upward flames with orange→red gradient
• `ParticleEffects.smoke()` — soft grey billowing smoke
• `ParticleEffects.explosion()` — radial burst (one-shot)
• `ParticleEffects.sparkle()` — twinkling star particles
• `ParticleEffects.rain()` — downward streaks
• `ParticleEffects.snow()` — drifting snowflakes

**Custom Particles:**
Create a `ParticleEmitter` directly and configure every property: emission rate, velocity range, gravity, color/size gradients, shape, lifetime, and more.''',
    ),

    // ── 7. Physics ──────────────────────────────────────────
    EngineSubsystem(
      id: 'physics',
      name: 'Physics Engine',
      icon: Icons.science,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Rigid body dynamics with SAT collision detection, impulse resolution, spatial grid broad-phase, and object sleeping.',
      features: [
        'Rigid Body Dynamics: Semi-implicit Euler integration',
        'Advanced Collision Shapes: Circles, Rectangles, and arbitrary Polygons via SAT',
        'True Impulse Resolution: Elastic collisions with Coulomb friction',
        'Broad-Phase Optimization: O(n) Spatial Grid with Object Sleeping',
        'Physics Caching: Triangulation and geometry caching to disk',
        'Debug Rendering: Visualize bodies and velocity vectors',
      ],
      apiClasses: [
        ApiClass(
          name: 'PhysicsEngine',
          description: 'Main physics simulation manager',
        ),
        ApiClass(
          name: 'PhysicsBody',
          description:
              'Rigid body with position, velocity, mass, collision shape',
        ),
      ],
      codeTitle: 'Physics Simulation',
      codeExample: '''// Create physics bodies
final body1 = PhysicsBody(
  position: Offset(-100, 0),
  velocity: Offset(50, 0),
  shape: CircleShape(30),
  mass: 1.0,
  restitution: 0.8,
  friction: 0.2,
);

engine.physics.addBody(body1);

// Enable debug rendering
rendering.addRenderable(
  CustomRenderable(
    onRender: (canvas, size) {
      engine.physics.renderDebug(canvas, size);
    },
  ),
);''',
      docsContent:
          '''The Physics Engine provides lightweight, custom-built 2D physics — no Forge2D/Box2D dependency.

**Rigid Body Dynamics:**
Each `PhysicsBody` has position, velocity, angular velocity, mass, drag, restitution (bounciness), and friction. The engine uses semi-implicit Euler integration for reliable simulation.

**Collision Detection:**
Uses the Separating Axis Theorem (SAT) for accurate collision detection between circles, rectangles, and arbitrary convex polygons. Broad-phase spatial grid optimization reduces complexity to O(n).

**Collision Resolution:**
Impulse-based resolution handles elastic collisions with proper restitution and Coulomb surface friction. Objects that come to rest enter a "sleeping" state to save CPU.

**Debug Rendering:**
Call `physics.renderDebug(canvas, size)` to visualize all physics bodies, velocity vectors, and collision shapes.''',
    ),

    // ── 8. Scene Graph ──────────────────────────────────────
    EngineSubsystem(
      id: 'scene-graph',
      name: 'Scene Graph',
      icon: Icons.account_tree,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Hierarchical parent-child node relationships with automatic world-space transform propagation.',
      features: [
        'Hierarchical Structure: Parent-child node relationships',
        'Transform Propagation: Automatic world-space transform calculation',
        'Scene Management: Create, load, and manage multiple scenes',
        'Node Queries: Find nodes by name or traverse the tree',
        'Attachable Renderables: Link visual objects to scene nodes',
      ],
      apiClasses: [
        ApiClass(
          name: 'SceneEditor',
          description: 'Scene management — create, load, switch scenes',
        ),
        ApiClass(
          name: 'Scene',
          description: 'Container for a tree of SceneNodes',
        ),
        ApiClass(
          name: 'SceneNode',
          description: 'Transform hierarchy node with optional renderable',
        ),
      ],
      codeTitle: 'Scene Graph',
      codeExample: '''// Create a scene
final scene = engine.sceneEditor.createScene('Level1');

// Create parent node
final parentNode = SceneNode('parent')
  ..localPosition = Offset(100, 100);
scene.addNode(parentNode);

// Create child node — inherits parent transform
final childNode = SceneNode('child')
  ..localPosition = Offset(50, 0)
  ..renderable = myCircle;
parentNode.addChild(childNode);

// Find nodes
final node = scene.findNode('child');''',
      docsContent:
          '''The Scene Graph provides a hierarchical structure for organizing game objects.

**SceneNode:**
Each node has a local position, rotation, and scale. World-space transforms are automatically computed by combining parent and child transforms. Attach a `Renderable` to a node to make it visible.

**Hierarchy:**
Use `addChild()` to build parent-child relationships. Moving a parent automatically moves all its children. This is ideal for complex game objects like a tank (body + turret + barrel).

**Scene Management:**
`SceneEditor` manages multiple scenes. Create scenes with `createScene()`, switch between them, and query nodes by name with `findNode()`.''',
    ),

    // ── 9. ECS ──────────────────────────────────────────────
    EngineSubsystem(
      id: 'ecs',
      name: 'Entity-Component System',
      icon: Icons.widgets,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Data-oriented ECS architecture with 15+ built-in components, 9 systems, reactive signals, entity queries, and hierarchy support.',
      features: [
        'Data-Oriented Architecture: Composition over inheritance',
        'Entity Management: Create and destroy entities with unique IDs',
        'Component System: 15+ built-in components (Transform, Velocity, Physics, Health, RaycastCollider, JoystickInput, etc.)',
        'System Processing: 9 built-in systems for movement, rendering, physics, ray casting, and more',
        'Query System: Find entities by component types',
        'World Management: Centralized entity and system coordination',
        'Hierarchy Support: Parent-child entity relationships',
        'Reactive ECS: Signal-driven wrappers via just_signals for surgical UI updates',
      ],
      apiClasses: [
        ApiClass(name: 'World', description: 'Entity and system manager'),
        ApiClass(
          name: 'Entity',
          description: 'Component container with unique ID and name',
        ),
        ApiClass(
          name: 'Component',
          description: 'Base class for data components',
        ),
        ApiClass(
          name: 'System',
          description: 'Base class for processing systems',
        ),
        ApiClass(
          name: 'TransformComponent',
          description: 'Position, rotation, scale',
        ),
        ApiClass(
          name: 'VelocityComponent',
          description: 'Velocity vector with max speed',
        ),
        ApiClass(
          name: 'RenderableComponent',
          description: 'Attachable visual renderable',
        ),
        ApiClass(
          name: 'PhysicsBodyComponent',
          description: 'Physics body properties',
        ),
        ApiClass(
          name: 'RaycastColliderComponent',
          description: 'Marks entity as hittable by raycasts',
        ),
        ApiClass(
          name: 'HealthComponent',
          description: 'Health, damage, and healing',
        ),
        ApiClass(
          name: 'JoystickInputComponent',
          description: 'Virtual joystick state for ECS-driven mobile control',
        ),
        ApiClass(
          name: 'ComponentSignal',
          description: 'Signal wrapper for component properties',
        ),
        ApiClass(
          name: 'EntitySignal',
          description: 'Observe entity-level component changes',
        ),
        ApiClass(
          name: 'WorldSignal',
          description: 'Track world-level entity counts',
        ),
        ApiClass(
          name: 'ReactiveSystem',
          description: 'Dirty-only entity processing system',
        ),
        ApiClass(
          name: 'MovementSystem',
          description: 'Applies velocity to transform',
        ),
        ApiClass(
          name: 'RenderSystem',
          description: 'Draws renderable components',
        ),
        ApiClass(
          name: 'PhysicsSystemECS',
          description: 'ECS-integrated physics processing',
        ),
      ],
      codeTitle: 'Entity-Component System',
      codeExample: '''// Access the ECS World
final world = engine.world;

// Add systems
world.addSystem(MovementSystem());
world.addSystem(RenderSystem());
world.addSystem(PhysicsSystemECS()..gravity = const Offset(0, 100));

// Create an entity
final player = world.createEntity(name: 'Player');

// Add components
player.addComponent(TransformComponent(
  position: const Offset(0, 0),
));
player.addComponent(VelocityComponent(
  velocity: const Offset(100, 0),
  maxSpeed: 200,
));
player.addComponent(RenderableComponent(
  renderable: CircleRenderable(
    radius: 30,
    fillColor: Colors.blue,
  ),
));
player.addComponent(HealthComponent(maxHealth: 100));

// Query entities
final movers = world.query([TransformComponent, VelocityComponent]);''',
      docsContent:
          '''The Entity-Component System (ECS) is the recommended way to structure game logic in Just Game Engine.

**Data-Oriented Design:**
Instead of complex inheritance hierarchies, entities are composed of small data components. Systems process entities that have specific component combinations. This makes it easy to add new behaviors without modifying existing code.

**Built-in Components (15+):**
`TransformComponent`, `VelocityComponent`, `RenderableComponent`, `PhysicsBodyComponent`, `RaycastColliderComponent`, `HealthComponent`, `LifetimeComponent`, `TagComponent`, `ParentComponent`, `ChildrenComponent`, `InputComponent`, `JoystickInputComponent`, `AnimationStateComponent`, `SpriteComponent`, and more.

**Built-in Systems (9):**
`MovementSystem`, `RenderSystem`, `PhysicsSystemECS`, `RaycastSystem`, `LifetimeSystem`, `HierarchySystem`, `HealthSystem`, `AnimationSystemECS`, `BoundarySystem`, and more.

**Queries:**
Use `world.query([ComponentA, ComponentB])` to efficiently find all entities with specific component combinations. Use `world.findEntityByName('Player')` for named lookups.

**Reactive ECS:**
The `src/reactive/` layer wraps ECS types with `just_signals` primitives so Flutter widgets can rebuild surgically when game state changes — no polling, no full-tree rebuilds. Use `ComponentSignal`, `EntitySignal`, `WorldSignal`, `ReactiveSystem`, and `ReactiveComponent`.''',
    ),

    // ── 10. Input ───────────────────────────────────────────
    EngineSubsystem(
      id: 'input',
      name: 'Input Management',
      icon: Icons.gamepad,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Unified polling-based input system for keyboard, mouse, touch, gamepad, and virtual joystick controls.',
      features: [
        'Keyboard Input: Key press, hold, and release with axis support',
        'Mouse Input: Position tracking, button states, scroll wheel, delta movement',
        'Touch Input: Multi-touch with pressure and size tracking',
        'Controller/Gamepad: Analog sticks, triggers, buttons, D-pad',
        'Virtual Joystick: Fixed and floating touch joystick variants',
        'Joystick Axis Lock: both, horizontal, or vertical constraints',
        'Event System: Callbacks for custom input handling',
        'Dead Zone: Configurable dead zones for analog inputs',
        'Integrated: Auto event capture through GameWidget',
      ],
      apiClasses: [
        ApiClass(name: 'InputManager', description: 'Main input coordinator'),
        ApiClass(
          name: 'KeyboardInput',
          description: 'Key press/hold/release with WASD axis',
        ),
        ApiClass(
          name: 'MouseInput',
          description: 'Mouse position, buttons, scroll, delta',
        ),
        ApiClass(name: 'TouchInput', description: 'Multi-touch support'),
        ApiClass(
          name: 'ControllerInput',
          description: 'Gamepad sticks, triggers, buttons',
        ),
        ApiClass(
          name: 'VirtualJoystick',
          description: 'Flutter widget for touch-based directional control',
        ),
        ApiClass(
          name: 'JoystickInputComponent',
          description: 'ECS component that stores joystick direction state',
        ),
        ApiClass(name: 'MouseButton', description: 'Mouse button constants'),
        ApiClass(
          name: 'GamepadButton',
          description: 'Gamepad button constants',
        ),
        ApiClass(name: 'GamepadAxis', description: 'Gamepad axis identifiers'),
      ],
      codeTitle: 'Input Handling',
      codeExample: '''final input = engine.input;

// Keyboard
if (input.keyboard.isKeyDown(LogicalKeyboardKey.keyW)) {
  player.moveUp();
}
if (input.keyboard.isKeyPressed(LogicalKeyboardKey.space)) {
  player.jump();
}

// Axis input for smooth movement
final horizontal = input.keyboard.horizontal; // -1, 0, or 1
final vertical = input.keyboard.vertical;
player.move(Offset(horizontal, vertical) * speed);

// Mouse
final mousePos = input.mouse.position;
if (input.mouse.isLeftButtonDown) {
  player.shootAt(mousePos);
}

// Touch
for (final touch in input.touch.touches) {
  print('Touch at \${touch.position}');
}

// Gamepad
final leftStick = input.controller.leftStick;
player.move(leftStick * speed);

// Mobile virtual joystick
VirtualJoystick(
  variant: JoystickVariant.floating,
  axis: JoystickAxis.both,
  onDirectionChanged: (direction) {
    joystickComponent.direction = direction;
  },
);''',
      docsContent:
          '''The Input Management system provides unified, polling-based input across all device types.

**Polling vs Events:**
Unlike event-driven systems, Just Game Engine uses a polling model — check input state each frame in your update loop. This ensures consistent behavior and avoids missed inputs.

**Keyboard:**
`input.keyboard.isKeyDown(key)` checks if a key is currently held. `isKeyPressed(key)` checks if it was pressed this frame. `horizontal` and `vertical` provide axis values (-1, 0, 1) for WASD/Arrow movement.

**Mouse:**
`input.mouse.position` gives the current cursor position. Check `isLeftButtonDown`, `isRightButtonDown`, or use `isButtonPressed(MouseButton)` for click detection. `scrollDelta` provides scroll wheel input.

**Touch:**
`input.touch.touches` returns all active touch points with position, pressure, and size. Supports multi-touch natively.

**Virtual Joystick (v1.4.0):**
Use `VirtualJoystick` for mobile-friendly movement controls. Choose `JoystickVariant.fixed` (always visible) or `JoystickVariant.floating` (spawns at touch-down), and constrain motion with `JoystickAxis.both`, `horizontal`, or `vertical`.

**Joystick ECS Integration:**
`JoystickInputComponent` stores current joystick direction and helper state so movement systems can consume mobile input exactly like keyboard/gamepad input.

**Gamepad:**
`input.controller.leftStick` and `rightStick` return `Offset` values. `isButtonPressed(GamepadButton)` handles button input. Configurable dead zones prevent stick drift.''',
    ),

    // ── 11. Assets ──────────────────────────────────────────
    EngineSubsystem(
      id: 'assets',
      name: 'Asset Management',
      icon: Icons.folder_open,
      category: SubsystemCategory.utilities,
      shortDescription:
          'Efficient asset loading and caching for images, audio, text, JSON, and binary files with bundle support.',
      features: [
        'Image Assets: Load PNG/JPG with memory tracking',
        'Audio Assets: Load MP3/WAV/OGG/FLAC as binary data',
        'Text Assets: Load plain text files',
        'JSON Assets: Load and parse JSON configuration files',
        'Binary Assets: Load raw binary data for custom formats',
        'Caching: Automatic asset caching with memory statistics',
        'Asset Bundles: Group assets for batch loading/unloading',
      ],
      apiClasses: [
        ApiClass(
          name: 'AssetManager',
          description: 'Asset loading and caching coordinator',
        ),
        ApiClass(name: 'Asset', description: 'Base class for all asset types'),
        ApiClass(
          name: 'ImageAsset',
          description: 'Image file loader (PNG/JPG)',
        ),
        ApiClass(
          name: 'AudioAsset',
          description: 'Audio file loader (MP3/WAV/OGG)',
        ),
        ApiClass(name: 'TextAsset', description: 'Plain text file loader'),
        ApiClass(name: 'JsonAsset', description: 'JSON configuration loader'),
        ApiClass(name: 'BinaryAsset', description: 'Raw binary data loader'),
        ApiClass(
          name: 'AssetBundle',
          description: 'Grouped asset loading/unloading',
        ),
      ],
      codeTitle: 'Loading Assets',
      codeExample: '''final assetManager = AssetManager();

// Load different asset types
final playerImage = await assetManager.loadImage(
  'assets/images/player.png',
);
final bgMusic = await assetManager.loadAudio(
  'assets/audio/music.mp3',
);
final config = await assetManager.loadJson(
  'assets/data/config.json',
);

// Access loaded data
final sprite = Sprite();
sprite.image = playerImage.image;

// Check cache stats
final stats = assetManager.getCacheStats();
print('Loaded \${stats["totalAssets"]} assets');

// Asset bundles for batch loading
final bundle = AssetBundle(
  name: 'Level1',
  assets: [
    ImageAsset(path: 'assets/level1/bg.png'),
    AudioAsset(path: 'assets/level1/music.mp3'),
  ],
);
await bundle.load(assetManager);
bundle.unload(assetManager);''',
      docsContent:
          '''The Asset Management system handles loading, caching, and unloading of game resources.

**Asset Types:**
• `ImageAsset` — loads PNG/JPG images into `dart:ui` Images
• `AudioAsset` — loads audio files as binary data for the AudioEngine
• `TextAsset` — loads plain text files
• `JsonAsset` — loads and parses JSON into `Map<String, dynamic>`
• `BinaryAsset` — loads raw bytes for custom formats

**Caching:**
All loaded assets are automatically cached by the `AssetManager`. Use `getCacheStats()` to monitor memory usage. Call `unload()` to free resources when they're no longer needed.

**Asset Bundles:**
Group related assets into an `AssetBundle` for batch loading and unloading — ideal for level-based games where you load all assets for a level at once and free them when transitioning.''',
    ),

    // ── 12. Audio ───────────────────────────────────────────
    EngineSubsystem(
      id: 'audio',
      name: 'Audio Engine',
      icon: Icons.music_note,
      category: SubsystemCategory.utilities,
      shortDescription:
          'Multi-channel audio with master/music/SFX/voice/ambient channels, unlimited concurrent SFX, and fade effects.',
      features: [
        'Multi-Channel: Master, Music, SFX, Voice, and Ambient channels',
        'Sound Effects: Unlimited concurrent SFX via SoLoud native voice management',
        'Music: Background music with fade in/out and looping',
        'Audio Mixer: Per-channel volume control, mute/unmute',
        'Integration: Built on flutter_soloud (SoLoud C++ engine) for low-latency audio',
      ],
      apiClasses: [
        ApiClass(
          name: 'AudioEngine',
          description: 'Multi-channel audio coordinator',
        ),
        ApiClass(
          name: 'AudioClip',
          description: 'Individual audio source controller',
        ),
        ApiClass(
          name: 'SoundEffectManager',
          description: 'SFX playback with pooling',
        ),
        ApiClass(
          name: 'MusicManager',
          description: 'Background music with fade effects',
        ),
        ApiClass(
          name: 'AudioMixer',
          description: 'Volume and mute control interface',
        ),
        ApiClass(
          name: 'AudioChannel',
          description: 'Channel enum (master, music, sfx, voice, ambient)',
        ),
        ApiClass(name: 'AudioState', description: 'Playback state enum'),
      ],
      codeTitle: 'Audio Playback',
      codeExample: '''final audioEngine = AudioEngine();
await audioEngine.initialize();

// Play background music with fade in
await audioEngine.playMusic(
  'assets/audio/background.mp3',
  volume: 0.7,
  loop: true,
  fadeInDuration: 2.0,
);

// Play sound effects
audioEngine.playSfx('assets/audio/jump.wav', volume: 0.8);
audioEngine.playSfx('assets/audio/explosion.wav', volume: 1.0);

// Control volume
audioEngine.setMasterVolume(0.8);
audioEngine.setChannelVolume(AudioChannel.music, 0.5);
audioEngine.setChannelVolume(AudioChannel.sfx, 1.0);

// Mute/unmute
audioEngine.muteChannel(AudioChannel.music);
audioEngine.toggleMute();

// Stop music with fade out
audioEngine.stopMusic(fadeOutDuration: 1.5);''',
      docsContent:
          '''The Audio Engine provides a complete multi-channel audio system built on `flutter_soloud` (SoLoud C++ engine) for low-latency, game-grade audio.

**Channels:**
Audio is organized into 5 independent channels: Master, Music, SFX, Voice, and Ambient. Each channel has its own volume control and mute state. The master channel controls the overall volume.

**Sound Effects:**
The `SoundEffectManager` provides unlimited concurrent SFX via SoLoud's native voice management with automatic cleanup. Fire-and-forget: just call `playSfx()` and it handles the rest.

**Background Music:**
`MusicManager` handles music playback with fade-in/out, seamless looping, pause/resume, and crossfade support. Only one music track plays at a time.

**Audio Mixer:**
`AudioMixer` provides per-channel volume control via `setChannelVolume()`, `muteChannel()`, and `toggleMute()`. Volumes multiply: effective SFX volume = masterVolume × sfxVolume.''',
    ),

    // ── 13. Ray Casting & Tracing ───────────────────────────
    EngineSubsystem(
      id: 'raycasting',
      name: 'Ray Casting & Tracing',
      icon: Icons.linear_scale_rounded,
      category: SubsystemCategory.gameplay,
      shortDescription:
          '2D raycasting with ECS integration, line-of-sight checks, and multi-bounce reflective ray tracing.',
      features: [
        'Ray Descriptor: 2D ray with origin, direction, and max-distance',
        'ECS Integration: RaycastColliderComponent marks entities as hittable',
        'Query System: castRay (closest hit), castRayAll (all hits sorted)',
        'Line of Sight: hasLineOfSight() for visibility checks',
        'Multi-Bounce Tracing: RayTracer for reflective surfaces',
        'Ray Visuals: RayRenderable with glowing beam effects',
      ],
      apiClasses: [
        ApiClass(
          name: 'Ray',
          description: '2D ray descriptor (origin, direction, maxDistance)',
        ),
        ApiClass(
          name: 'RaycastColliderComponent',
          description: 'Marks entity as hittable with radius, tag, isBlocker',
        ),
        ApiClass(
          name: 'RaycastHit',
          description: 'Intersection result (entity, point, distance, normal)',
        ),
        ApiClass(
          name: 'RaycastSystem',
          description: 'Query system (castRay, castRayAll, hasLineOfSight)',
        ),
        ApiClass(
          name: 'RayTracer',
          description: 'Multi-bounce reflective ray tracing',
        ),
        ApiClass(
          name: 'RayTrace',
          description: 'Complete trace result with path segments',
        ),
        ApiClass(
          name: 'RayRenderable',
          description: 'Glowing beam visual with fade lifetime',
        ),
      ],
      codeTitle: 'Ray Casting',
      codeExample: '''final world = engine.world;

// Add raycast system
world.addSystem(RaycastSystem());

// Create hittable entity
final target = world.createEntity(name: 'Target');
target.addComponent(TransformComponent(
  position: const Offset(200, 0),
));
target.addComponent(RaycastColliderComponent(
  radius: 30,
  tag: 'enemy',
  isBlocker: true,
  isReflective: false,
));

// Cast a ray
final ray = Ray(
  origin: Offset.zero,
  direction: const Offset(1, 0),
  maxDistance: 500,
);

final raycastSystem = world.getSystem<RaycastSystem>();

// Get closest hit
final hit = raycastSystem?.castRay(ray);
if (hit != null) {
  print('Hit \${hit.entity.name} at \${hit.point}');
}

// Get all hits sorted by distance
final hits = raycastSystem?.castRayAll(ray) ?? [];

// Line of sight check
final canSee = raycastSystem?.hasLineOfSight(
  Offset.zero,
  const Offset(200, 0),
) ?? false;''',
      docsContent:
          '''The Ray Casting & Tracing system provides 2D raycasting with full ECS integration for shooting mechanics, line-of-sight checks, and visibility calculations.

**Ray:**
A 2D ray descriptor with `origin`, normalized `direction`, and `maxDistance`. Use `Ray.fromPoints()` for convenience when you have start and end points.

**RaycastColliderComponent:**
An ECS component that marks an entity as hittable by raycasts. Configure `radius` (hit area), `tag` (for filtering), `isBlocker` (stops rays), `isReflective`, and `reflectivity`.

**RaycastSystem:**
A query-only ECS system with three main methods:
• `castRay(ray)` — returns the closest hit
• `castRayAll(ray)` — returns all hits sorted nearest-first
• `hasLineOfSight(from, to)` — quick visibility check

**RayTracer:**
For multi-bounce ray tracing against reflective surfaces. Configure `maxBounces` and `minReflectivity`. Returns a `RayTrace` containing every path segment for laser/light reflection effects.

**RayRenderable:**
Visual representation of a ray with two-layer glow effect and configurable fade lifetime — perfect for lasers, bullet trails, and beam weapons.''',
    ),

    // ── 14. Tiled Map Support ───────────────────────────────
    EngineSubsystem(
      id: 'tiledmap',
      name: 'Tiled Map Support',
      icon: Icons.grid_on,
      category: SubsystemCategory.utilities,
      shortDescription:
          'Native Tiled editor support with TMX/TSX parsing, GPU-batched rendering, texture atlases, and spatial queries.',
      features: [
        'TMX/TSX Parsing: Full Tiled map editor file support',
        'Map Types: Orthogonal, isometric, staggered, and hexagonal',
        'Layer Support: Tile, Object, Image, and Group layers with properties',
        'GPU-Batched Rendering: Canvas.drawRawAtlas for maximum throughput',
        'Texture Atlas: Automatic packed atlas from tilesets',
        'Animated Tiles: Per-tile animation sequences',
        'Spatial Hash Grid: O(1) AABB, point, and radius queries',
        'Compression: CSV, Base64, XML; GZIP, Zlib, Zstandard',
      ],
      apiClasses: [
        ApiClass(
          name: 'TileMapParser',
          description: 'Async parser for .tmx/.tsx files',
        ),
        ApiClass(
          name: 'TileMap',
          description: 'Parsed map data with layers, tilesets, properties',
        ),
        ApiClass(
          name: 'TileLayer',
          description: 'Tile layer with tile IDs and properties',
        ),
        ApiClass(
          name: 'ObjectLayer',
          description: 'Object layer with MapObject instances',
        ),
        ApiClass(name: 'ImageLayer', description: 'Background image layer'),
        ApiClass(name: 'GroupLayer', description: 'Nested layer container'),
        ApiClass(
          name: 'TileMapRenderer',
          description: 'GPU-batched renderer using drawRawAtlas',
        ),
        ApiClass(
          name: 'TextureAtlas',
          description: 'Packed texture atlas from tilesets',
        ),
        ApiClass(
          name: 'SpatialHashGrid',
          description: 'O(1) spatial queries for map objects',
        ),
        ApiClass(
          name: 'MapObject',
          description: 'Tiled object with geometry and properties',
        ),
      ],
      codeTitle: 'Loading Tiled Maps',
      codeExample: '''import 'package:just_tiled/just_tiled.dart';

// Parse a .tmx map from assets
final tileMap = await TileMapParser.parseAsset(
  'assets/maps/level1.tmx',
);

// Build a packed texture atlas
final atlas = await TextureAtlas.fromTileMap(tileMap);

// Create renderers for tile layers
final renderers = tileMap.layers
    .whereType<TileLayer>()
    .map((layer) => TileMapRenderer(
          tileMap: tileMap,
          layer: layer,
          atlas: atlas,
        ))
    .toList();

// Render in a CustomRenderable
engine.rendering.addRenderable(
  CustomRenderable(
    onRender: (canvas, size) {
      for (final renderer in renderers) {
        renderer.render(canvas);
      }
    },
  ),
);

// Use SpatialHashGrid for fast object queries
final grid = SpatialHashGrid<MapObject>(cellSize: 128);
for (final layer in tileMap.layers.whereType<ObjectLayer>()) {
  for (final obj in layer.objects) {
    grid.insert(obj, obj.bounds);
  }
}

// Query objects near player
final nearby = grid.queryAABB(playerBounds);''',
      docsContent:
          '''The Tiled Map Support system (via `just_tiled` package) provides native integration with the Tiled map editor for level design.

**TileMapParser:**
Async parser for `.tmx` and `.tsx` files supporting CSV, Base64, and XML tile data. Handles GZIP, Zlib, and Zstandard compression (via `just_zstd`).

**Map Orientations:**
Full support for orthogonal, isometric, staggered, and hexagonal map orientations with proper coordinate transforms.

**Layer Hierarchy:**
Complete layer support including `TileLayer`, `ObjectLayer`, `ImageLayer`, and `GroupLayer` with nested hierarchies and custom properties.

**GPU-Batched Rendering:**
`TileMapRenderer` uses `Canvas.drawRawAtlas` to submit all tiles in a single draw call for maximum throughput — essential for large maps.

**TextureAtlas:**
`TextureAtlas.fromTileMap()` builds a packed atlas from all tilesets in the map, minimizing texture swaps during rendering.

**SpatialHashGrid:**
Generic spatial hash with O(1) complexity for AABB, point, and radius queries against map objects — perfect for collision detection and trigger zones.

**Animated Tiles:**
Per-tile animation sequences are automatically driven by the engine game loop, supporting Tiled's native tile animation format.''',
    ),
  ];
}
