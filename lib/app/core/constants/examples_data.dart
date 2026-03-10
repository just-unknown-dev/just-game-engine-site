import 'engine_models.dart';

/// Code examples data for the Examples page.
abstract final class ExamplesData {
  static const List<EngineExample> examples = [
    EngineExample(
      id: 'basic-setup',
      title: 'Basic Engine Setup',
      subsystemId: 'core',
      description:
          'Minimal setup to get the engine running with a single renderable. This is the foundation for every Just Game Engine project.',
      code: '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine();
  await engine.initialize();

  // Add a blue circle at the center
  engine.rendering.addRenderable(
    CircleRenderable(
      radius: 50,
      fillColor: Colors.blue,
      position: Offset.zero,
    ),
  );

  // Add a red rectangle
  engine.rendering.addRenderable(
    RectangleRenderable(
      size: Size(100, 60),
      fillColor: Colors.red,
      position: Offset(200, 100),
    ),
  );

  engine.start();

  runApp(MaterialApp(
    home: Scaffold(
      body: GameWidget(engine: engine),
    ),
  ));
}''',
    ),
    EngineExample(
      id: 'ecs-demo',
      title: 'ECS with Physics',
      subsystemId: 'ecs',
      description:
          'Create entities with components and systems for a physics-driven simulation using the Entity-Component System.',
      code: '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void setupECS(Engine engine) {
  final world = engine.world;

  // Add systems
  world.addSystem(MovementSystem());
  world.addSystem(RenderSystem());
  world.addSystem(PhysicsSystemECS()
    ..gravity = const Offset(0, 100));

  // Create a player entity
  final player = world.createEntity(name: 'Player');
  player.addComponent(TransformComponent(
    position: const Offset(0, -100),
  ));
  player.addComponent(VelocityComponent(
    velocity: const Offset(50, 0),
    maxSpeed: 200,
  ));
  player.addComponent(RenderableComponent(
    renderable: CircleRenderable(
      radius: 30,
      fillColor: Colors.blue,
    ),
  ));
  player.addComponent(PhysicsBodyComponent(
    radius: 30,
    mass: 1.0,
    restitution: 0.8,
  ));
  player.addComponent(HealthComponent(maxHealth: 100));

  // Create obstacles
  for (int i = 0; i < 5; i++) {
    final obstacle = world.createEntity(name: 'Obstacle_\$i');
    obstacle.addComponent(TransformComponent(
      position: Offset(i * 120.0 - 240, 200),
    ));
    obstacle.addComponent(RenderableComponent(
      renderable: RectangleRenderable(
        size: const Size(40, 40),
        fillColor: Colors.red,
      ),
    ));
    obstacle.addComponent(PhysicsBodyComponent(
      radius: 20,
      mass: 2.0,
      restitution: 0.6,
    ));
  }

  // Query entities with physics
  final bodies = world.query([
    TransformComponent,
    PhysicsBodyComponent,
  ]);
  print('Physics entities: \${bodies.length}');
}''',
    ),
    EngineExample(
      id: 'animation-demo',
      title: 'Animation Showcase',
      subsystemId: 'animation',
      description:
          'Demonstrates property tweening with various easing curves, animation sequences, and parallel animation groups.',
      code: '''import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void setupAnimations(Engine engine) {
  // Create a renderable to animate
  final circle = CircleRenderable(
    radius: 30,
    fillColor: Colors.blue,
    position: Offset(-200, 0),
  );
  engine.rendering.addRenderable(circle);

  // Position tween with easing
  final moveAnim = PositionTween(
    target: circle,
    start: Offset(-200, 0),
    end: Offset(200, 0),
    duration: 2.0,
    easing: Easings.easeInOutQuad,
    loop: true,
  );

  // Rotation tween
  final rotateAnim = RotationTween(
    target: circle,
    start: 0,
    end: math.pi * 2,
    duration: 3.0,
    easing: Easings.linear,
    loop: true,
  );

  // Scale tween
  final scaleAnim = ScaleTween(
    target: circle,
    start: 1.0,
    end: 1.5,
    duration: 1.0,
    easing: Easings.easeInOutElastic,
    loop: true,
    pingPong: true,
  );

  // Run rotation and scale in parallel
  final group = AnimationGroup(
    animations: [rotateAnim, scaleAnim],
    loop: true,
  );

  // Play a sequence: move then group
  final sequence = AnimationSequence(
    animations: [moveAnim, group],
    loop: true,
  );
  sequence.play();
}''',
    ),
    EngineExample(
      id: 'particles-demo',
      title: 'Particle Effects Gallery',
      subsystemId: 'particles',
      description:
          'Showcases all built-in particle presets: fire, smoke, explosion, sparkle, rain, and snow.',
      code: '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void setupParticles(Engine engine) {
  final particles = <ParticleEmitter>[];

  // Fire effect
  particles.add(ParticleEffects.fire(
    position: Offset(-300, 100),
  )..emissionRate = 30);

  // Smoke effect
  particles.add(ParticleEffects.smoke(
    position: Offset(-100, 100),
  )..emissionRate = 15);

  // Sparkle effect
  particles.add(ParticleEffects.sparkle(
    position: Offset(100, 0),
  )..emissionRate = 20);

  // Rain effect
  particles.add(ParticleEffects.rain(
    position: Offset(0, -200),
  )..emissionRate = 50);

  // Snow effect
  particles.add(ParticleEffects.snow(
    position: Offset(300, -200),
  )..emissionRate = 25);

  // Render all particle systems
  engine.rendering.addRenderable(
    CustomRenderable(
      onRender: (canvas, size) {
        for (final emitter in particles) {
          emitter.update(engine.time.deltaTime);
          emitter.render(canvas, size);
        }
      },
    ),
  );

  // One-shot explosion (trigger on demand)
  void triggerExplosion(Offset position) {
    final explosion = ParticleEffects.explosion(
      position: position,
    );
    particles.add(explosion);
  }
}''',
    ),
    EngineExample(
      id: 'input-demo',
      title: 'Input System Demo',
      subsystemId: 'input',
      description:
          'Complete input handling: keyboard movement, mouse aiming, touch support, and gamepad control.',
      code: '''import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void handleInput(Engine engine, double speed) {
  final input = engine.input;

  // Keyboard — WASD / Arrow keys
  if (input.keyboard.isKeyDown(LogicalKeyboardKey.keyW)) {
    // W key held — move up
  }
  if (input.keyboard.isKeyPressed(LogicalKeyboardKey.space)) {
    // Space just pressed — jump
  }

  // Smooth axis-based movement
  final horizontal = input.keyboard.horizontal;
  final vertical = input.keyboard.vertical;
  final moveDir = Offset(horizontal.toDouble(),
    vertical.toDouble());
  // Apply: playerPos += moveDir * speed * dt;

  // Mouse
  final mousePos = input.mouse.position;
  final worldPos = engine.rendering.camera
      .screenToWorld(mousePos, engine.rendering.screenSize);

  if (input.mouse.isLeftButtonDown) {
    // Left mouse held — shoot at worldPos
  }
  if (input.mouse.isButtonPressed(MouseButton.right)) {
    // Right click — spawn object
  }

  // Mouse wheel zoom
  if (input.mouse.scrollDelta.dy != 0) {
    engine.rendering.camera.zoomBy(
      1.0 - input.mouse.scrollDelta.dy * 0.001,
    );
  }

  // Touch input
  for (final touch in input.touch.touches) {
    // Handle each active touch point
  }

  // Gamepad
  final stick = input.controller.leftStick;
  // Apply: playerPos += stick * speed * dt;
  if (input.controller.isButtonPressed(GamepadButton.a)) {
    // A button — jump
  }
}''',
    ),
    EngineExample(
      id: 'audio-demo',
      title: 'Audio & Music',
      subsystemId: 'audio',
      description:
          'Multi-channel audio setup with background music, sound effects, volume control, and fade transitions.',
      code: '''import 'package:just_game_engine/just_game_engine.dart';

Future<void> setupAudio() async {
  final audio = AudioEngine();
  await audio.initialize();

  // Play background music with fade in
  await audio.playMusic(
    'assets/audio/background.mp3',
    volume: 0.7,
    loop: true,
    fadeInDuration: 2.0,
  );

  // Play sound effects (fire-and-forget)
  audio.playSfx('assets/audio/jump.wav', volume: 0.8);
  audio.playSfx('assets/audio/shoot.wav');
  audio.playSfx('assets/audio/explosion.wav', volume: 1.0);

  // Volume control per channel
  audio.setMasterVolume(0.8);
  audio.setChannelVolume(AudioChannel.music, 0.5);
  audio.setChannelVolume(AudioChannel.sfx, 1.0);
  audio.setChannelVolume(AudioChannel.ambient, 0.3);

  // Mute/unmute
  audio.muteChannel(AudioChannel.music);
  audio.toggleMute(); // Toggle master

  // Stop music with fade out
  audio.stopMusic(fadeOutDuration: 1.5);

  // Pause and resume
  audio.pauseMusic();
  audio.resumeMusic();
}''',
    ),
  ];
}
