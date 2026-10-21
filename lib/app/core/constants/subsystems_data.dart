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
          'Image rendering with sprite sheets, nine-slice scaling, sprite batching for draw-call reduction, and horizontal/vertical flipping.',
      features: [
        'Image Rendering: Load and display images with easy asset management',
        'Sprite Sheets: Manage multiple sprites in a single texture',
        'Sprite Batching: SpriteBatch submits all sprites sharing an atlas in a single Canvas.drawAtlas() call',
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
          name: 'SpriteBatch',
          description:
              'Batches sprites sharing an atlas into a single draw call',
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
          'Data-oriented ECS architecture with 26+ built-in components, 17+ systems, reactive signals, command buffer, event bus, entity prefabs, and hierarchy support.',
      features: [
        'Data-Oriented Architecture: Composition over inheritance',
        'Entity Management: Create and destroy entities with generational IDs',
        'Component System: 26+ built-in components (Transform, Velocity, Physics, Health, RaycastCollider, Shader, Parallax, Particle, etc.)',
        'System Processing: 17+ built-in systems with standardized priorities',
        'Command Buffer: Deferred entity mutations via world.commands — safe inside system updates',
        'Event Bus: Typed inter-system messaging via world.events (on<T>() / fire())',
        'Entity Prefabs: Reusable blueprints via EntityPrefab with batch-spawn support',
        'Query System: Find entities by component types with integer-based cache hashing',
        'World Management: Centralized entity and system coordination with O(1) removal',
        'Hierarchy Support: Parent-child entity relationships',
        'Reactive ECS: Signal-driven wrappers via just_signals for surgical UI updates',
      ],
      apiClasses: [
        ApiClass(
          name: 'World',
          description:
              'Entity and system manager with CommandBuffer and EventBus',
        ),
        ApiClass(
          name: 'Entity',
          description: 'Component container with generational ID and name',
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
          name: 'EntityPrefab',
          description: 'Reusable entity blueprint for batch spawning',
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
          name: 'SpriteComponent',
          description: 'Sprite rendering component',
        ),
        ApiClass(
          name: 'ShaderComponent',
          description: 'Per-entity or post-process shader',
        ),
        ApiClass(
          name: 'ParallaxComponent',
          description: 'Attaches a ParallaxBackground to an entity',
        ),
        ApiClass(
          name: 'ParticleEmitterComponent',
          description: 'ECS particle emitter attachment',
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
          name: 'EffectComponent',
          description:
              'Stores entity EffectPlayer queue for deterministic effects',
        ),
        ApiClass(
          name: 'JoystickInputComponent',
          description: 'Virtual joystick state for ECS-driven mobile control',
        ),
        ApiClass(name: 'UIComponent', description: 'Base UI entity component'),
        ApiClass(
          name: 'ButtonComponent',
          description: 'Clickable button entity',
        ),
        ApiClass(
          name: 'LinearProgressComponent',
          description: 'Linear progress bar entity',
        ),
        ApiClass(
          name: 'CircularProgressComponent',
          description: 'Circular progress indicator entity',
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
          description: 'Applies velocity to transform (priority 80)',
        ),
        ApiClass(
          name: 'RenderSystem',
          description: 'Draws renderable components (priority 40)',
        ),
        ApiClass(
          name: 'PhysicsSystem',
          description: 'ECS-integrated physics processing (priority 90)',
        ),
        ApiClass(
          name: 'InputSystem',
          description:
              'Maps InputManager state to InputComponent (priority 100)',
        ),
        ApiClass(
          name: 'AnimationSystemECS',
          description: 'Advances animations in ECS (priority 70)',
        ),
        ApiClass(
          name: 'EffectSystemECS',
          description: 'Manages per-entity EffectPlayer queues (priority 65)',
        ),
        ApiClass(
          name: 'PostProcessSystem',
          description:
              'Bridges ShaderComponent to RenderingEngine (priority 35)',
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

**Built-in Components (26+):**
`TransformComponent`, `VelocityComponent`, `RenderableComponent`, `SpriteComponent`, `ShaderComponent`, `ParallaxComponent`, `ParticleEmitterComponent`, `PhysicsBodyComponent`, `PhysicsBodyRefComponent`, `RaycastColliderComponent`, `HealthComponent`, `LifetimeComponent`, `TagComponent`, `ParentComponent`, `ChildrenComponent`, `InputComponent`, `JoystickInputComponent`, `CameraFollowComponent`, `AnimationStateComponent`, `AudioSourceComponent`, `AudioPlayComponent`, `TileMapLayerComponent`, `TiledObjectComponent`, `EffectComponent`, `UIComponent`, `TextComponent`, `ButtonComponent`, `LinearProgressComponent`, `CircularProgressComponent`.

**Built-in Systems (17+):**
`InputSystem` (100), `PhysicsSystem` (90), `PhysicsBridgeSystem` (89), `MovementSystem` (80), `AnimationSystemECS` (70), `EffectSystemECS` (65), `HealthSystem` (60), `HierarchySystem` (50), `RenderSystem` (40), `PostProcessSystem` (35), `BoundarySystem` (30), `ParticleSystemECS`, `CameraFollowSystem`, `RaycastSystem`, `LifetimeSystem`, `AudioSystem`, `TileMapRenderSystem`, `TiledCollisionSystem`.

**Command Buffer:**
`world.commands` accepts deferred entity mutations (create, destroy, addComponent, removeComponent) that are safe to call from within system updates — no concurrent-modification exceptions.

**Event Bus:**
`world.events` provides typed inter-system messaging. Subscribe with `on<T>()` and dispatch with `fire()`. Great for decoupled physics callbacks, damage events, and more.

**Entity Prefabs:**
`EntityPrefab` is a reusable entity blueprint. Call `world.instantiate(prefab)` for fast batch-spawning without manually repeating component setup.

**Queries:**
Use `world.query([ComponentA, ComponentB])` to efficiently find all entities with specific component combinations. The query cache uses integer-based hashing with selective invalidation.

**Reactive ECS:**
The `src/reactive/` layer wraps ECS types with `just_signals` primitives so Flutter widgets can rebuild surgically when game state changes — no polling, no full-tree rebuilds.''',
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
        'ECS Integration: TileMapLayerComponent, TiledObjectComponent, TileMapRenderSystem, TiledCollisionSystem',
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

    // ── 15. Post-Processing ─────────────────────────────────
    EngineSubsystem(
      id: 'post-processing',
      name: 'Post-Processing',
      icon: Icons.filter,
      category: SubsystemCategory.visual,
      shortDescription:
          'Full-screen FragmentShader passes, per-entity shader layers, and ECS-driven post-process pipeline.',
      features: [
        'Full-Screen Passes: PostProcessPass wraps the scene through a custom FragmentShader',
        'Pass Ordering: Multiple passes chained by passOrder (lower = innermost)',
        'Per-Entity Shaders: ShaderComponent wraps individual entities via canvas.saveLayer',
        'ECS Integration: PostProcessSystem bridges ShaderComponent to RenderingEngine (priority 35)',
        'Time Uniform: elapsedSeconds supplied to setUniforms for animated shader effects',
      ],
      apiClasses: [
        ApiClass(
          name: 'PostProcessPass',
          description:
              'Full-screen FragmentShader pass with passOrder and setUniforms callback',
        ),
        ApiClass(
          name: 'ShaderComponent',
          description: 'ECS component for per-entity or post-process shaders',
        ),
        ApiClass(
          name: 'PostProcessSystem',
          description:
              'Bridges ShaderComponent entities to RenderingEngine (priority 35)',
        ),
      ],
      codeTitle: 'Post-Processing Shader',
      codeExample: '''// Add a full-screen pass via ECS
final shaderEntity = world.createEntity(name: 'VignettePass');
shaderEntity.addComponent(ShaderComponent(
  shader: myFragmentShader,
  isPostProcess: true,
  passOrder: 10,
  setUniforms: (shader) {
    shader.setFloat(0, engine.rendering.elapsedSeconds);
  },
));

// The PostProcessSystem (priority 35) picks it up automatically.
// Per-entity shader (wraps only that entity's draw calls):
playerEntity.addComponent(ShaderComponent(
  shader: glowShader,
  isPostProcess: false,
));''',
      docsContent:
          '''The Post-Processing system adds full-screen or per-entity shader effects without writing any pipeline boilerplate.

**PostProcessPass:**
A full-screen pass that composites the rendered scene through a custom `FragmentShader`. Multiple passes are ordered by `passOrder` — lower values are innermost (closest to the scene), higher values are outermost.

**Per-Entity Shaders:**
`ShaderComponent(isPostProcess: false)` wraps only that entity's draw calls inside a `canvas.saveLayer`, allowing effects like glow, outline, or dissolve on individual game objects.

**ECS Integration:**
`PostProcessSystem` (priority 35) reads `ShaderComponent` entries each frame and calls `RenderingEngine.addPostProcessPass` / `removePostProcessPass` automatically.

**Animated Effects:**
`RenderingEngine.elapsedSeconds` supplies a time value to the `setUniforms` callback so shaders can animate over time (e.g., scanlines, wave distortion).''',
    ),

    // ── 16. Sprite Atlas ────────────────────────────────────
    EngineSubsystem(
      id: 'sprite-atlas',
      name: 'Sprite Atlas',
      icon: Icons.view_comfy,
      category: SubsystemCategory.visual,
      shortDescription:
          'Auto-detecting TexturePacker/Aseprite atlas parser with named regions, animation clips, and draw-call reduction.',
      features: [
        'Multi-Format Parsing: Auto-detects TexturePacker JSON Array, JSON Hash, multi-page, and Aseprite',
        'Named Regions: Look up any frame by name via atlas.createSprite()',
        'Animation Clips: Define named AtlasAnimationClip objects with variable-duration frames',
        'Draw-Call Reduction: All sprites from the same atlas share a single GPU texture',
        'SpriteBatch Integration: Combine with SpriteBatch for maximum throughput',
        'Quick Start: SpriteAtlas.fromAsset() loads and caches the atlas via AssetManager',
      ],
      apiClasses: [
        ApiClass(
          name: 'SpriteAtlas',
          description:
              'Named-region lookup, clip registration, and sprite/animation creation',
        ),
        ApiClass(
          name: 'AtlasParser',
          description:
              'Auto-detecting parser for TexturePacker JSON Array/Hash, multi-page, and Aseprite formats',
        ),
        ApiClass(
          name: 'AtlasAnimationClip',
          description:
              'Named animation clip with a list of AtlasFrame entries (region + duration)',
        ),
        ApiClass(
          name: 'AtlasSpriteAnimation',
          description:
              'Frame-by-frame animation driving a Sprite through an AtlasAnimationClip',
        ),
      ],
      codeTitle: 'Sprite Atlas Setup',
      codeExample: '''// Load and cache atlas
final atlas = await SpriteAtlas.fromAsset(
  'assets/heroes.json',
);

// Create a sprite from a named region
final heroSprite = atlas.createSprite('hero_idle_0');

// Register an animation clip
atlas.registerClip(AtlasAnimationClip(
  name: 'hero_run',
  frames: [
    AtlasFrame(regionName: 'hero_run_0', duration: 0.1),
    AtlasFrame(regionName: 'hero_run_1', duration: 0.1),
    AtlasFrame(regionName: 'hero_run_2', duration: 0.1),
    AtlasFrame(regionName: 'hero_run_3', duration: 0.1),
  ],
));

// Drive animation
final animation = AtlasSpriteAnimation(
  atlas: atlas,
  clipName: 'hero_run',
  sprite: heroSprite,
  loop: true,
);
animation.play();''',
      docsContent:
          '''The Sprite Atlas system provides efficient named-frame access and animation from packed texture atlases.

**AtlasParser:**
Automatically detects the format (TexturePacker JSON Array, JSON Hash, multi-page, or Aseprite export) — no manual format selection needed.

**Named Regions:**
Every frame is accessible by name via `atlas.createSprite('frame_name')`, making it easy to assemble entities from descriptive identifiers rather than integer indices.

**AtlasAnimationClip:**
Define named animation sequences with per-frame durations. Register clips on the atlas and drive a `Sprite` through them using `AtlasSpriteAnimation`.

**Performance:**
All sprites from the same atlas share a single GPU texture. Combine with `SpriteBatch` to submit all draw calls in a single `Canvas.drawAtlas()` call for dramatic draw-call reduction.''',
    ),

    // ── 17. Deterministic Effects ───────────────────────────
    EngineSubsystem(
      id: 'deterministic-effects',
      name: 'Deterministic Effects',
      icon: Icons.replay,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Tick-based effects that reproduce identically from integer ticks, with rollback support, JSON/binary serialization, and ECS integration.',
      features: [
        'Multiplayer-Ready: 11 tick-based effects reproduce identically from integer ticks',
        'Effect Types: MoveEffect, ScaleEffect, RotateEffect, FadeEffect, ColorTintEffect',
        'Composite Effects: SequenceEffect, ParallelEffect, DelayEffect, RepeatEffect',
        'Gameplay Effects: ShakeEffect, PathEffect',
        'Pure-Delta Contract: applyTick(ctx, prevElapsed, currElapsed) is additive and stack-safe',
        'Serialization: EffectSerializer (JSON) and EffectBinaryCodec (little-endian wire format)',
        'Rollback Support: EffectSnapshot captures mid-flight state for late-join reconnect',
        'ECS Integration: EffectSystemECS manages per-entity EffectPlayer queues (priority 65)',
      ],
      apiClasses: [
        ApiClass(
          name: 'DeterministicEffect',
          description:
              'Abstract base; implements applyTick(ctx, prevElapsed, currElapsed)',
        ),
        ApiClass(
          name: 'MoveEffect',
          description: 'Moves entity along a path deterministically',
        ),
        ApiClass(
          name: 'ScaleEffect',
          description: 'Scales entity deterministically',
        ),
        ApiClass(
          name: 'RotateEffect',
          description: 'Rotates entity deterministically',
        ),
        ApiClass(name: 'FadeEffect', description: 'Fades entity opacity'),
        ApiClass(name: 'ColorTintEffect', description: 'Tints entity color'),
        ApiClass(
          name: 'SequenceEffect',
          description: 'Chains effects sequentially',
        ),
        ApiClass(
          name: 'ParallelEffect',
          description: 'Runs effects simultaneously',
        ),
        ApiClass(name: 'ShakeEffect', description: 'Shakes entity position'),
        ApiClass(
          name: 'PathEffect',
          description: 'Moves entity along a custom path',
        ),
        ApiClass(
          name: 'EffectComponent',
          description: 'ECS component storing an entity EffectPlayer queue',
        ),
        ApiClass(
          name: 'EffectSystemECS',
          description: 'Advances all in-flight effects each tick (priority 65)',
        ),
        ApiClass(
          name: 'EffectSerializer',
          description: 'JSON factory registry for effects',
        ),
        ApiClass(
          name: 'EffectBinaryCodec',
          description: 'Little-endian v1 binary wire format',
        ),
        ApiClass(
          name: 'EffectSnapshot',
          description: 'Mid-flight state capture for rollback',
        ),
      ],
      codeTitle: 'Deterministic Effects',
      codeExample: '''// Get the EffectSystem
final effectSystem = world.getSystem<EffectSystemECS>();

// Schedule a move effect on an entity
effectSystem?.scheduleEffect(
  entity: playerEntity,
  effect: SequenceEffect(effects: [
    MoveEffect(
      targetOffset: const Offset(200, 0),
      duration: 60, // ticks
    ),
    ShakeEffect(intensity: 5.0, duration: 30),
    FadeEffect(targetOpacity: 0.0, duration: 30),
  ]),
);

// Serialize to JSON for network send
final json = EffectSerializer.toJson(effect);

// Serialize to binary wire format
final bytes = EffectBinaryCodec.encode(effect);

// Capture snapshot for rollback
final snapshot = EffectSnapshot.capture(effectPlayer);''',
      docsContent:
          '''The Deterministic Effects system provides tick-based visual effects that reproduce identically from integer ticks alone, making them ideal for multiplayer games.

**Pure-Delta Contract:**
`applyTick(ctx, prevElapsed, currElapsed)` is additive — two effects on the same entity stack correctly. Fast-forward via `applyTick(ctx, 0, N)` for late-join reconnect.

**Effect Types (11):**
`MoveEffect`, `ScaleEffect`, `RotateEffect`, `FadeEffect`, `ColorTintEffect`, `SequenceEffect`, `ParallelEffect`, `DelayEffect`, `RepeatEffect`, `ShakeEffect`, `PathEffect`.

**ECS Integration:**
`EffectSystemECS` (priority 65) manages per-entity `EffectPlayer` queues. Schedule effects via `effectSystem.scheduleEffect(entity: e, effect: ...)`.

**Serialization:**
`EffectSerializer` provides a JSON factory registry. `EffectBinaryCodec` encodes effects in a compact little-endian v1 wire format suitable for network transmission.

**Rollback Support:**
`EffectSnapshot` captures mid-flight effect state for lock-step or rollback networking scenarios.''',
    ),

    // ── 18. Localization ────────────────────────────────────
    EngineSubsystem(
      id: 'localization',
      name: 'Localization',
      icon: Icons.language,
      category: SubsystemCategory.utilities,
      shortDescription:
          'Engine-wide i18n with namespace support, ICU-lite templating, fallback chains, and signal-driven Flutter widgets.',
      features: [
        'Engine-Wide i18n: LocalizationManager serves string lookups to all subsystems',
        'Namespaces: Organize strings by domain (ui, game, dialogue)',
        'Fallback Chain: fr_CA → fr → en → raw key (configurable fallbackLocale)',
        'ICU-lite Templating: {var} substitutions, plural, and gender select',
        'Signal-Driven: localeSignal lets widgets rebuild only when locale changes',
        'Flutter Widgets: LocalizationScope, LocalizationBuilder, LocalizedText, LocaleSelector',
      ],
      apiClasses: [
        ApiClass(
          name: 'LocalizationManager',
          description:
              'Central i18n service with namespace support, fallback chain, and localeSignal',
        ),
        ApiClass(
          name: 'LocaleStringTable',
          description: 'Immutable per-locale flat string map',
        ),
        ApiClass(
          name: 'StringInterpolator',
          description: 'ICU-lite engine: {var}, plural, select',
        ),
        ApiClass(
          name: 'LocalizationScope',
          description: 'InheritedWidget exposing LocalizationManager',
        ),
        ApiClass(
          name: 'LocalizationBuilder',
          description: 'Rebuilds on locale change, exposes t() helper',
        ),
        ApiClass(
          name: 'LocalizedText',
          description: 'Drop-in Text replacement resolving keys',
        ),
        ApiClass(
          name: 'LocaleSelector',
          description: 'Ready-made locale-switching UI widget',
        ),
      ],
      codeTitle: 'Localization Setup',
      codeExample: '''// Initialize LocalizationManager
final l10n = LocalizationManager(fallbackLocale: const Locale('en'));

// Load namespaced JSON files
await l10n.loadNamespace(
  locale: const Locale('en'),
  namespace: 'ui',
  json: {'welcome': 'Welcome, {name}!', 'score': '{count, plural, =1{1 point} other{{count} points}}'},
);

// Change locale (signal notifies all widgets)
l10n.setLocale(const Locale('fr'));

// Lookup with substitution
final greeting = l10n.translate('welcome', ns: 'ui', vars: {'name': 'Alice'});

// Flutter widget integration
LocalizationScope(
  manager: l10n,
  child: LocalizationBuilder(
    builder: (context, t) => Text(t('ui.welcome', vars: {'name': 'Player'})),
  ),
);''',
      docsContent:
          '''The Localization system provides engine-wide internationalization for all subsystems including Narrative/Dialogue.

**Namespaces:**
Organize strings by domain — load separate JSON files per namespace and locale. For example, `ns: 'ui'` and `ns: 'game'` can be loaded independently, keeping translation files manageable.

**Fallback Chain:**
For locale `fr_CA`, lookups cascade `fr_CA → fr → en` (configurable `fallbackLocale`) before returning the raw key. This ensures no missing string errors.

**ICU-lite Templating:**
`StringInterpolator` handles `{var}` substitutions, `{count, plural, =0{…} =1{…} other{…}}` plurals, and `{gender, select, …}` selects.

**Signal-Driven:**
`LocalizationManager.localeSignal` is a `Signal<Locale>` from `just_signals`. Only widgets subscribed to the signal rebuild on locale change — no expensive full-tree rebuilds.

**Flutter Widgets:**
`LocalizationScope` exposes the manager as an `InheritedWidget`. `LocalizationBuilder` rebuilds on locale change. `LocalizedText` is a drop-in `Text` replacement. `LocaleSelector` is a ready-to-use locale-switching widget.''',
    ),

    // ── 19. Narrative / Dialogue ────────────────────────────
    EngineSubsystem(
      id: 'narrative',
      name: 'Narrative & Dialogue',
      icon: Icons.chat_bubble_outline,
      category: SubsystemCategory.gameplay,
      shortDescription:
          'Full Yarn Spinner 2.x parser and runtime with ECS integration, condition/command registries, and ready-made UI widgets.',
      features: [
        'Yarn Spinner 2.x: Full parser and runtime for .yarn script files',
        'Dialogue Patterns: Linear, branching choices, hub-and-spoke, cutscene',
        'Condition Registry: Register Dart callbacks for <<if>> conditions',
        'Command Registry: Register Dart callbacks for <<command>> blocks',
        'Expression Evaluator: Variables, comparisons, and arithmetic in Yarn if-conditions',
        'Localization Bridge: DialogueLocalizer delegates to LocalizationManager under namespace "dialogue"',
        'ECS Integration: DialogueComponent + TriggerComponent + DialogueSystem',
        'UI Widgets: DialogueBoxWidget and DialogueChoicesWidget for in-game dialogue UI',
      ],
      apiClasses: [
        ApiClass(
          name: 'DialogueManager',
          description:
              'High-level facade for loading and running .yarn scripts',
        ),
        ApiClass(
          name: 'YarnTokenizer',
          description: 'Full Yarn Spinner 2.x tokenizer',
        ),
        ApiClass(
          name: 'YarnParser',
          description: 'Full Yarn Spinner 2.x parser',
        ),
        ApiClass(
          name: 'DialogueRunner',
          description:
              'Executes parsed dialogue graph; exposes condition and command registries',
        ),
        ApiClass(
          name: 'DialogueGraph',
          description: 'Parsed Yarn script data model',
        ),
        ApiClass(
          name: 'DialogueLocalizer',
          description: 'Bridges dialogue keys to LocalizationManager',
        ),
        ApiClass(
          name: 'DialogueComponent',
          description: 'ECS component for in-world dialogue ownership',
        ),
        ApiClass(
          name: 'TriggerComponent',
          description: 'ECS component for trigger conditions',
        ),
        ApiClass(
          name: 'DialogueSystem',
          description: 'ECS system processing trigger conditions each frame',
        ),
        ApiClass(
          name: 'DialogueBoxWidget',
          description: 'Ready-made Flutter widget for in-game dialogue display',
        ),
        ApiClass(
          name: 'DialogueChoicesWidget',
          description: 'Ready-made Flutter widget for dialogue choices',
        ),
      ],
      codeTitle: 'Yarn Dialogue Setup',
      codeExample: r'''// Load and run a .yarn script
final manager = DialogueManager();
await manager.loadScript('assets/story/intro.yarn');

// Register condition callbacks
manager.runner.registerCondition('hasKey', (args) {
  return player.inventory.hasItem('key');
});

// Register command callbacks
manager.runner.registerCommand('giveItem', (args) {
  player.inventory.addItem(args[0]);
});

// Start a dialogue node
manager.runner.startNode('Intro');

// ECS-driven dialogue triggering
final npcEntity = world.createEntity(name: 'NPC');
npcEntity.addComponent(DialogueComponent(nodeName: 'NPC_Greeting'));
npcEntity.addComponent(TriggerComponent(
  condition: () => player.isNearNPC,
));

// Flutter UI
DialogueBoxWidget(runner: manager.runner);
DialogueChoicesWidget(runner: manager.runner);''',
      docsContent:
          '''The Narrative & Dialogue system provides a full Yarn Spinner 2.x runtime for story-driven games.

**Yarn Spinner 2.x:**
Full support for `.yarn` script files including linear dialogue, branching choices, hub-and-spoke patterns, and cutscenes. The `YarnTokenizer` and `YarnParser` handle the complete language spec.

**Condition & Command Registries:**
Register Dart callbacks for `<<if>>` conditions and `<<command>>` blocks at runtime. The expression evaluator handles variables, comparisons, and arithmetic in Yarn if-conditions.

**Localization Bridge:**
`DialogueLocalizer` delegates all string storage and signal handling to `LocalizationManager` under namespace `'dialogue'`, giving you automatic locale switching for dialogue texts.

**ECS Integration:**
`DialogueComponent` attaches a script node name to any entity. `TriggerComponent` holds a condition function. `DialogueSystem` evaluates triggers each frame and starts the appropriate dialogue node.

**Flutter UI:**
`DialogueBoxWidget` and `DialogueChoicesWidget` are fully composable ready-made widgets for in-game dialogue display, designed to be easy to style and extend.''',
    ),

    // ── 20. Math Module ─────────────────────────────────────
    EngineSubsystem(
      id: 'math',
      name: 'Math Module',
      icon: Icons.calculate,
      category: SubsystemCategory.core,
      shortDescription:
          'Mutable zero-allocation 2D vector type for hot-path physics and quadtree spatial indexing for viewport culling.',
      features: [
        'Vec2: Mutable 2D vector for zero-allocation hot-path physics',
        'Vec2 Operations: in-place add(), sub(), addScaled(), scale(), setZero()',
        'Offset Interop: Seamless conversion between Vec2 and Flutter Offset',
        'Quadtree: Spatial indexing for viewport culling and broad-phase queries',
        'Quadtree Config: Configurable maxItems and maxDepth for tuning performance',
      ],
      apiClasses: [
        ApiClass(
          name: 'Vec2',
          description:
              'Mutable 2D vector for zero-allocation hot-path use with Offset interop',
        ),
        ApiClass(
          name: 'Quadtree',
          description:
              'Spatial indexing tree with configurable maxItems and maxDepth',
        ),
      ],
      codeTitle: 'Vec2 & Quadtree',
      codeExample: '''// Vec2 for zero-allocation physics
final velocity = Vec2(100.0, 0.0);
final acceleration = Vec2(0.0, 9.8);

// In-place operations (no allocation)
velocity.addScaled(acceleration, deltaTime);
velocity.scale(0.98); // damping

// Convert to/from Flutter Offset
final offset = velocity.toOffset();
final fromOffset = Vec2.fromOffset(const Offset(100, 200));

// Quadtree for spatial queries
final tree = Quadtree<Entity>(
  bounds: Rect.fromLTWH(0, 0, 1920, 1080),
  maxItems: 4,
  maxDepth: 6,
);

tree.insert(entity, entity.bounds);

// Query visible entities
final visible = tree.queryRect(cameraViewport);''',
      docsContent:
          '''The Math Module provides performance-critical primitives for the engine's hot paths.

**Vec2:**
A mutable 2D vector type designed for zero-allocation use in physics loops. Unlike Flutter's `Offset` (immutable), `Vec2` supports in-place operations: `add()`, `sub()`, `addScaled()`, `scale()`, `setZero()`. The physics engine uses `Vec2` internally for rigid body state. Use `toOffset()` and `Vec2.fromOffset()` for Flutter interop.

**Quadtree:**
A space-partitioning tree for efficient spatial queries. Configure `maxItems` (max entities per node before subdivision) and `maxDepth` (max tree depth). Use `insert()` to add objects with their bounding rect, and `queryRect()` or `queryPoint()` for fast lookups — ideal for viewport culling and broad-phase collision.''',
    ),

    // ── 21. Memory Management ───────────────────────────────
    EngineSubsystem(
      id: 'memory',
      name: 'Memory Management',
      icon: Icons.memory,
      category: SubsystemCategory.core,
      shortDescription:
          'Generic object pool for GC-friendly recycling and multi-tier cache manager with LRU eviction.',
      features: [
        'Object Pool: Generic ObjectPool<T> with configurable maxSize',
        'Pool Lifecycle: acquire() / release() with totalAcquired and peakAvailable stats',
        'Cache Manager: Multi-tier caching via just_storage (key-value) and just_database (binary)',
        'LRU Eviction: Automatic eviction with configurable maxBinaryEntries',
        'SQL-safe Keys: Automatic key validation for safe storage',
        'Memory Fallback: In-memory fallback when persistent storage is unavailable',
      ],
      apiClasses: [
        ApiClass(
          name: 'ObjectPool',
          description:
              'Generic pool with maxSize, acquire()/release(), and stats',
        ),
        ApiClass(
          name: 'CacheManager',
          description:
              'Multi-tier LRU cache via just_storage and just_database',
        ),
      ],
      codeTitle: 'Object Pool & Cache',
      codeExample: '''// Object Pool for bullets (avoid GC pressure)
final bulletPool = ObjectPool<Bullet>(
  factory: () => Bullet(),
  reset: (b) => b.reset(),
  maxSize: 200,
);

// Acquire from pool
final bullet = bulletPool.acquire();
bullet.position = playerPosition;
bullet.velocity = aimDirection * 500;

// Return to pool when done
bulletPool.release(bullet);

// Pool statistics
print('Peak available: \${bulletPool.peakAvailable}');
print('Total acquired: \${bulletPool.totalAcquired}');

// CacheManager for binary data (e.g., physics geometry)
final cache = CacheManager(maxBinaryEntries: 50);
await cache.putBinary('level1_physics', geometryBytes);
final cached = await cache.getBinary('level1_physics');''',
      docsContent:
          '''The Memory Management module reduces GC pressure and speeds up expensive resource lookups.

**ObjectPool:**
A generic pool that recycles objects instead of creating new ones. Configure `maxSize` to cap memory usage. Call `acquire()` to get an object (creates a new one if pool is empty) and `release()` to return it. Statistics via `totalAcquired` and `peakAvailable` help you tune the pool size. Ideal for bullets, particles, and any frequently-spawned objects.

**CacheManager:**
A multi-tier cache backed by `just_storage` (key-value) and `just_database` (binary BLOB). Uses LRU eviction with configurable `maxBinaryEntries`. SQL-safe key validation prevents storage errors. An in-memory fallback ensures the cache works even when persistent storage is unavailable — useful for caching triangulated physics geometry that is expensive to recompute.''',
    ),
  ];
}
