import 'doc_models.dart';

/// The "Core" pages: the engine object, the ECS, and scenes.
const List<DocPage> coreDocs = [
  DocPage(
    id: 'engine',
    title: 'Engine & lifecycle',
    group: DocGroups.core,
    summary:
        'Create an Engine, configure it with EngineConfig, take it through initialize, start and dispose, and reach its subsystems, game loop and context.',
    keywords: [
      'Engine',
      'EngineConfig',
      'EngineState',
      'EngineInitException',
      'EngineNotReadyError',
      'DefaultSystems',
      'DefaultSystem',
      'registerDefaultSystems',
      'GameLoop',
      'TimeManager',
      'SystemManager',
      'FrameSystem',
      'EngineContext',
      'ContextExtension',
    ],
    body: r'''
An `Engine` is an ordinary Dart object. You make one per game session, give it an `EngineConfig`, await `initialize()`, call `start()`, and dispose it when the game is over. It owns the world, the subsystems (rendering, physics, input, audio, storage, cameras) and the game loop.

## Create an engine

Build and initialize the engine before `runApp`, so the first frame already has a game to draw:

```dart lib/main.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize(); // builds the subsystems and the world
  engine.start(); // starts the game loop

  runApp(MaterialApp(home: Scaffold(body: GameWidget(engine: engine))));
}
```

When the game is one screen of a larger app, let that screen's `State` own the engine. `dispose()` returns a `Future`, but it tears the engine down before its first `await`, so not awaiting it in `State.dispose` is safe:

```dart lib/game_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );

  @override
  void initState() {
    super.initState();
    engine.initialize().then((_) => engine.start());
  }

  @override
  void dispose() {
    unawaited(engine.dispose()); // final: this engine cannot start again
    super.dispose();
  }

  // GameWidget may be built before initialize() finishes: it starts
  // drawing and ticking the engine as soon as it is ready.
  @override
  Widget build(BuildContext context) => GameWidget(engine: engine);
}
```

## EngineConfig

Everything that shapes an engine is set once, in the `EngineConfig` you pass to the constructor.

| Field | What it does |
|---|---|
| `defaultSystems` | The engine's standard systems to add while it initializes. Empty by default, so a world starts with no systems. |
| `extensions` | `ContextExtension`s to install: a package's component definitions, migrations and registries. |
| `services` | `EngineService`s started with the engine and stopped with it. |
| `createRendering` | Builds your own `RenderingEngine` subclass instead of the standard one. |
| `createAudio` | Builds the `AudioEngine`, for example with `AudioEngine.withBackend(...)`. |
| `createPhysics` | Builds the 2-D `PhysicsEngine`. Null gives Box2D on native platforms and the pure-Dart engine on the web. |
| `graphics3D` | A `Graphics3D` turns on 3-D drawing; see [3D graphics](/docs/graphics-3d). |
| `physics3D` | A `Physics3D` turns on 3-D bodies on Jolt; see [3D physics](/docs/physics-3d). |
| `deferAudioUntilInput` | Starts audio at the first key or pointer press. Null means on the web only. |

`initialize(config: ...)` still accepts a config and replaces the constructor's, for code written for 1.x. Prefer `Engine(config: ...)`.

## The lifecycle

`engine.state` is an `EngineState`: `uninitialized`, `initializing`, `initialized`, `running`, `paused`, `failed`, `disposing` or `disposed`. `engine.stateListenable` notifies on every change, and `isInitialized` (true while initialized, running or paused), `isRunning`, `isPaused` and `isDisposed` answer the common questions.

| Call | Works in | Anywhere else |
|---|---|---|
| `initialize()` | `uninitialized`, `failed` | Returns the running Future while `initializing`; throws a `StateError` on a ready or disposed engine. |
| `start()` | `initialized` | Throws a `StateError`. |
| `pause()` | `running` | Does nothing. |
| `resume()` | `paused` | Does nothing. |
| `stop()` | `running`, `paused` (back to `initialized`) | Does nothing. |
| `dispose()` | any state | A second call returns the same Future. |

`initialize()` builds the engine in stages: core, cache, input, audio, physics, rendering, world, subsystems and services. If a stage throws, everything built so far is undone, the state becomes `failed`, and an `EngineInitException` is thrown and kept in `engine.lastError`. Its `stage` names the stage (`service:<Type>` for a service) and `cause` holds the original error. You may then call `initialize()` again.

```dart
try {
  await engine.initialize();
} on EngineInitException catch (e) {
  debugPrint('The engine failed at ${e.stage}: ${e.cause}');
}
```

The subsystem getters throw `EngineNotReadyError` (a `StateError` naming the member and the state) before `initialize()` has built them and after `dispose()`. Disposal is final: to play again, make a new `Engine()`.

> **Note:** An audio failure during initialization is logged, not fatal: the game runs without sound. This is what happens in tests and on platforms without the audio plugin.

## Default systems

`EngineConfig.defaultSystems` takes a set of `DefaultSystem` values. Each adds:

| `DefaultSystem` | Systems |
|---|---|
| `input` | `InputSystem` (the `player` map's actions onto each `InputComponent`) |
| `physics` | `PhysicsSystem`, `PhysicsJointBindingSystem` |
| `movement` | `MovementSystem` |
| `audio` | `AudioSystem` |
| `rendering` | `RenderSystem`, `ParallaxRenderSystem` |
| `sprites` | `SpriteLoadSystem`, `AnimatorSystem`, `SpriteAnimationSystem`, `TimelineTriggerSystem`, `TimelineSystem` |
| `levelMaps` | `LevelMapSystem` |
| `mapCollision` | `MapCollisionSystem` |
| `cameras` | `CameraTargetGroupSystem`, `CameraTriggerSystem`, `CameraBrainSystem` |

`DefaultSystems.all` is every one. `DefaultSystems.headless` leaves out `rendering` and `audio`, for a server, a simulation or a test.

`registerDefaultSystems(world, engine, include: ...)` adds the same systems to any world. It skips a system type the world already has, so you can add your own configured instance first. Add these yourself when you use them: `ParticleSystemECS`, `EffectSystemECS`, `PostProcessSystem`, `HealthSystem`, `LifetimeSystem`, `CheckpointSystem`, `RaycastSystem`, `DialogueSystem` and `ViewCullingSystem`.

## Subsystems

These exist between `initialize()` and `dispose()`:

| Getter | Type | What it is |
|---|---|---|
| `engine.world` | `World` | Entities, components and systems; see [World, entities & systems](/docs/ecs). |
| `engine.rendering` | `RenderingEngine` | Draws the frame: background colour, render hooks, post-processing, `stats`. |
| `engine.physics` | `PhysicsEngine` | 2-D physics, stepped by `PhysicsSystem`; see [2D physics](/docs/physics-2d). |
| `engine.input` | `InputService` | Actions, devices and players; see [Input](/docs/input). |
| `engine.audio`, `engine.music`, `engine.sfx` | `AudioEngine`, `MusicManager`, `SoundEffectManager` | Sound; see [Audio](/docs/audio). |
| `engine.cache` | `CacheManager` | Strings, JSON and binary data kept between runs. |
| `engine.cameraSystem` | `CameraSystem` | The `mainCamera` and the camera `brain`; see [Cameras](/docs/cameras). |
| `engine.time` | `TimeManager` | Frame time, total time and `timeScale`. |
| `engine.gameLoop` | `GameLoop` | The fixed-step loop: `currentFPS`, `interpolation`, `fixedDeltaTime`. |
| `engine.systemManager` | `SystemManager` | Update tasks and their timings. |

These work in every state: `engine.config`, `engine.context`, `engine.assets` (the `AssetManager`), `engine.services`, `engine.plugins`, `engine.layers`, `engine.terminal`, `engine.cursor` and `engine.performanceStats`. `engine.graphics3D` and `engine.physics3D` are the objects you put in the config, or null for a 2-D game. `engine.subsystem<T>()` finds a subsystem by type, and returns null when there is none.

## The game loop

`GameWidget` calls `engine.gameLoop.tick()` once per display frame. The world then updates in fixed steps of 1/60 s (`engine.gameLoop.fixedDeltaTime`): none, one or several per frame. At most three steps' worth of time is carried over, so a stall does not snowball. The rate is fixed at 60 steps a second; `EngineConfig` has no setting for it.

- Every `System.update(deltaTime)` receives the fixed step times `engine.time.timeScale`. At a time scale of 0 the steps still run, with a `deltaTime` of 0. `engine.time.slowMotion()` and `fastForward()` set the scale for you.
- Move things by `deltaTime` in `update`. Don't read the wall clock.
- `engine.pause()` stops the steps. The screen still draws and input still updates every frame, so a pause menu keeps working. `resume()` drops the time that passed while paused instead of catching up.
- Drawing happens once per display frame, between steps. Moving physics bodies are drawn between their last two steps (`engine.gameLoop.interpolation`), so they stay smooth on a 120 Hz screen.

Each step runs the engine's update tasks in order: `input`, `parallax`, `particles` and `ecs`. The `ecs` task is `world.update(deltaTime)`, and `PhysicsSystem` steps the physics inside it, so a velocity your system sets reaches the same step's simulation. Add a task of your own with `engine.systemManager.registerUpdateTask('autosave', (dt) { ... })`; it runs after the engine's, task names must be unique, and `unregisterUpdateTask` removes it.

After a frame's steps, systems that also implement `FrameSystem` run their `frame(deltaTime, alpha)` once per rendered frame, for things that must move at the display's rate rather than the simulation's.

## EngineContext and extensions

`engine.context` is an `EngineContext`: everything one engine knows that is not a subsystem. It holds the component `definitions` and `fieldTypes` scenes are read with, the scene `migrations`, registries such as `animatorBindings`, `trackKinds`, `easings`, `collisionKinds` and `effectTypes`, the project's `physicsLayers`, the timeline `signals`, the game's `localization`, the asset `bundle` and the `assets` manager. The engine makes it in its constructor, so you can fill it before `initialize()`.

`engine.world.context` is the same object. A second world that must read the engine's scenes is made with `World(context: engine.context)`; a bare `World()` makes a fresh context of its own.

A package, or your game, teaches an engine through a `ContextExtension`:

```dart
final class MyGameExtension implements ContextExtension {
  const MyGameExtension();

  @override
  String get id => 'my_game';

  @override
  void install(EngineContext context) {
    // An animator parameter can now be bound to "grounded".
    context.animatorBindings.register(
      'grounded',
      (entity) => entity.getComponent<RigidBody2D>()?.isGrounded,
    );
  }
}

final engine = Engine(
  config: const EngineConfig(
    extensions: [MyGameExtension()],
    defaultSystems: DefaultSystems.all,
  ),
);
```

Extensions in the config are installed in the engine's constructor. `install` runs once per context for each `id`; a second install of the same id is ignored. `context.install(extension)` and `context.isInstalled(id)` work at any time. To register your own components for scenes, see [Scenes & saving](/docs/scenes).

State a package keeps per engine goes in a slot: `context.slot<T>(key, create)` makes it on first use, and a value that implements `ContextResource` is disposed with the context. Nothing is process-wide, so two engines in one process never see each other's registrations.

## Services and plugins

An `EngineService` is something that starts as the engine initializes and stops when it is disposed: achievements, a wallet, your own telemetry. An `EnginePlugin` attaches to a running engine to observe it, like an editor or a profiler, and is called every frame even while the game is paused. Both are covered in [Services & plugins](/docs/services).
''',
  ),
  DocPage(
    id: 'ecs',
    title: 'World, entities & systems',
    group: DocGroups.core,
    summary:
        'Model a game as entities that carry components, and its rules as systems that query them every fixed step.',
    keywords: [
      'World',
      'Entity',
      'Component',
      'System',
      'SystemPriorities',
      'EventBus',
      'GameEvent',
      'CommandBuffer',
      'EntityPrefab',
      'ParentComponent',
      'ChildrenComponent',
      'isActiveInHierarchy',
      'ComponentSignal',
      'ReactiveSystem',
    ],
    body: r'''
A game is a `World` of entities. An entity is an id with components; a component is plain data; a system is the logic that runs over every entity with the components it needs. `engine.world` is the engine's world.

## Entities and components

A component is any class that extends `Component`. Give it fields and leave the logic to a system:

```dart
import 'package:just_game_engine/just_game_engine.dart';

/// Data: how fast an entity turns, in radians per second.
class SpinComponent extends Component {
  SpinComponent({this.speed = 1.0});

  double speed;
}

/// Logic: turns every entity that has a transform and a spin.
class SpinSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, SpinComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final transform = entity.getComponent<TransformComponent>()!;
      final spin = entity.getComponent<SpinComponent>()!;
      transform.angle += spin.speed * deltaTime;
    });
  }
}

void addSpinner(World world) {
  world.addSystem(SpinSystem());
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 0, 0)),
    RectangleComponent(width: 80, height: 80),
    SpinComponent(speed: 2),
  ], name: 'Spinner');
}
```

- `world.createEntityWithComponents(components, name: ...)` places the entity with all its components in one go. `world.createEntity(name: ...)` makes an empty one.
- `entity.addComponent(c)`, `removeComponent<T>()`, `getComponent<T>()`, `hasComponent<T>()` and `components` work on one entity. Override `onAttach` and `onDetach` on a component to hear when it is added or removed.
- An entity holds one component of each type: adding a second of a type replaces the first. Every shape and sprite is stored as a `RenderableComponent`, so one entity draws one thing; put a second drawing on a child entity. See [Rendering](/docs/rendering).
- `world.destroyEntity(entity)` removes an entity and everything under it. `destroyAllEntities()` clears the world. Entity ids count up for the life of the world and are never reused; `entity.isAlive` tells you whether a handle you kept still points at a live entity.

## Systems

A system declares `requiredComponents`, implements `update(deltaTime)`, and reads its entities through `entities` or `forEach`. It also has `initialize`, `onAddedToWorld`, `onRemovedFromWorld`, `dispose` and `render(canvas, size)` to override, and an `isActive` switch.

Add one with `world.addSystem(system)`, take it out with `removeSystem`, and find one with `getSystem<T>()` or `hasSystem<T>()`. Adding a system that is already in the world does nothing, and systems may add or remove systems while the world updates.

Systems run by priority, highest first, not in the order you add them; systems of equal priority run in the order they were added. The world places a system by its priority when it is added, so set the priority before adding it (overriding the getter is simplest). The constants are in `SystemPriorities`:

| Priority | Constant | What runs |
|---:|---|---|
| 110 | `levelMap` | level maps load and update |
| 108 | `mapCollision` | bodies for map tiles |
| 100 | `input` | actions copied onto `InputComponent`s |
| 95 | `playerControl` | your character controller: reads input, sets velocity |
| 90 | `physics` | the physics step |
| 80 | `movement` | velocity onto transform, for entities without a body |
| 70 | `animation` | animators, sprite clips, timelines |
| 65 | `effects` | deterministic effects |
| 60 | `gameplay` | health, lifetime, your game rules |
| 50 | `hierarchy` | children follow their parents |
| 48 | `particles` | particle emitters |
| 45 | `camera` | the camera brain frames the finished positions |
| 40 | `render` | `RenderSystem`, which draws once per display frame |
| −10 | `audio` | sounds follow their entities |

A system that sets no priority runs at 0. If you change a priority after adding the system, call `world.sortSystems()`. An exception thrown by a system ends that update; the engine does not catch it.

## Queries

`world.query([TransformComponent, VelocityComponent])` returns the entities that have every listed type and are active in the hierarchy. A system's `entities` is exactly this query for its `requiredComponents`.

- Results are cached per set of types and rebuilt only when an entity that could match is added, removed, changes components, or is switched on or off. Asking again in the same frame is a lookup.
- A returned list never changes; a later change makes a new one.
- Results come in storage order, not creation order. Set draw order with `LayerComponent`, never by creation order.
- `world.queryVersion(types)` moves on whenever that query's result may have changed, for a system that caches something per entity.

To find one entity, use the indexed lookups instead of scanning `world.entities` every frame: `world.findEntityByName(name)`, and `world.findTagged(tag)` and `world.allTagged(tag)` for tags (see [Tags & spawners](/docs/tags-spawners)). For an entity you touch every frame, look it up once and keep the reference.

## Events and deferred changes

`world.events` is a typed `EventBus`. Subclass `GameEvent`, subscribe with `on<T>()`, and `fire` an event; subscribers of its exact runtime type are called at once. `on` returns an `EventSubscription` to `cancel()`. The engine fires its own events here, such as `CollisionEnter2DEvent` from physics and `TileChangedEvent` from level maps.

`world.commands` is a `CommandBuffer` for structural changes made while a system walks its entities: `create`, `destroy`, `addComponent` and `removeComponent<T>()`. The world applies the queue in order after each system that left commands in it, so the next system sees the change. A command on an entity that is gone by then is skipped.

```dart
class CoinCollected extends GameEvent {
  CoinCollected(this.value);

  final int value;
}

class CoinSystem extends System {
  @override
  List<Type> get requiredComponents => [TagComponent];

  @override
  void update(double deltaTime) {
    for (final coin in world.allTagged('coin')) {
      if (isTouchingPlayer(coin)) {
        world.events.fire(CoinCollected(10));
        world.commands.destroy(coin); // applied after this system
      }
    }
  }

  bool isTouchingPlayer(Entity coin) => false; // your game's test
}

// Somewhere in your game's setup:
// final sub = world.events.on<CoinCollected>((e) => score += e.value);
// sub.cancel(); // when you no longer need it
```

The bus is cleared with the world, so subscriptions do not outlive it.

## Prefabs in code

An `EntityPrefab` is a name and a list of component factories. `world.instantiate(prefab)` calls every factory and creates the entity in one step, so each copy gets fresh components:

```dart
final bullet = EntityPrefab(
  name: 'Bullet',
  factories: [
    () => TransformComponent(),
    () => VelocityComponent(velocity: Vector3(500, 0, 0)),
    () => CircleComponent(radius: 4),
  ],
);

Entity fire(World world, Vector3 muzzle) {
  final shot = world.instantiate(bullet);
  shot.getComponent<TransformComponent>()!.position.setFrom(muzzle);
  return shot;
}
```

Prefabs made in the editor are saved as `.prefab.json` files instead; those are covered in [Scenes & saving](/docs/scenes).

## Parents and children

`TransformComponent` is always the world transform: physics, cameras, timelines and your code read and write it in world space. A child's offset from its parent lives in its `ParentComponent` (`localPosition`, `localRotation`, `localScale`), and the world keeps the two in step every update.

```dart
/// Hangs a turret on [tank], 30 units above its centre. From the next
/// update on it moves and turns with the tank.
Entity addTurret(World world, Entity tank) => world.createEntityWithComponents([
  TransformComponent(),
  ParentComponent(parentId: tank.id, localPosition: Vector3(0, -30, 0)),
  RectangleComponent(width: 50, height: 12),
], name: 'Turret');
```

- The world keeps the other end of the link: the tank gets a `ChildrenComponent` listing the turret.
- A `ParentComponent` with no local values leaves the child where its `TransformComponent` puts it and works its offset out from there. Scenes load their links this way.
- To move the turret on the tank later, change `localPosition`. If you write a child's `TransformComponent` directly, its offset is worked out again from where you put it.
- Destroying the tank destroys the turret. Pass `withChildren: false` to `world.destroyEntity` to keep the children where they are.

`entity.isActive` switches one entity on or off. `entity.isActiveInHierarchy` is true only when the entity and every parent above it are switched on. Queries, tag lookups, targets, drawing and simulation all go by `isActiveInHierarchy`, so switching a parent off takes its whole subtree out of the game, while each child keeps its own `isActive`.

## The reactive layer

For Flutter UI that follows game data, the engine wraps the ECS in `just_signals` signals:

- `ComponentSignal<C, T>` is a `Signal` over one component field, with a getter and a setter. `TransformSignals`, `VelocitySignals` and `HealthSignals` are ready-made sets. Writing through the signal updates the component and notifies listeners; when a system changes the component directly, call `sync()`.
- `EntitySignal` (`entity.toSignal()`) follows an entity's components; `WorldSignal` (`world.toSignal()`) exposes `entityCount`, `systemCount`, `entities` and `query(types)`.
- `ReactiveSystem` processes only entities marked dirty (`markDirty`), in `processEntity`. `AutoSyncSystem` and `SignalSyncMixin` sync signals after a system's update, and the `ReactiveComponent` mixin gives a component its own property signals.

The layer is optional; nothing else in the engine depends on it. Only `Signal` and `Computed` are re-exported by `package:just_game_engine/just_game_engine.dart`. For `SignalBuilder` and the rest, add `just_signals` to your pubspec and import it. For a suggested way to connect systems, signals and widgets, see [UI over the game](/docs/game-widget).
''',
  ),
  DocPage(
    id: 'scenes',
    title: 'Scenes & saving',
    group: DocGroups.core,
    summary:
        'Load levels from JSON scene files, describe your own components so scenes can hold them, and handle format versions and loading errors.',
    keywords: [
      'SceneLoader',
      'SceneAssets',
      'SceneFormat',
      'scenes.json',
      'ComponentDefinition',
      'SchemaField',
      'FieldTypes',
      'ContextExtension',
      'MigrationHooks',
      'MigrationResult',
      'UnknownComponentTypeException',
      'UnsupportedFormatVersionException',
      'PrefabLibrary',
      'LevelMaps',
    ],
    body: r'''
A level is a scene: a JSON file listing entities and their components. The [editor](/editor) writes these files, and they are plain JSON, so you can also write them by hand. Your game loads them at run time with `SceneLoader`.

## Scene files and the manifest

Scenes live in `assets/scenes/` as `<name>.scene.json`. `assets/scenes/scenes.json` lists them in play order, for example `{ "scenes": ["level_01", "level_02"] }`. Declare the folder under `flutter: assets:` in your `pubspec.yaml`; a folder entry does not include its subfolders.

```json assets/scenes/level_01.scene.json
{
  "version": 9,
  "name": "level_01",
  "mode": "2d",
  "entities": [
    {
      "name": "Ground",
      "components": [
        { "type": "TransformComponent", "fields": { "position": { "x": 0, "y": 300, "z": 0 } } },
        { "type": "RectangleComponent", "fields": { "width": 1200, "height": 40 } },
        { "type": "Collider2D", "fields": { "shape": "matchShape" } }
      ]
    },
    {
      "name": "PlayerSpawn",
      "components": [
        { "type": "TransformComponent", "fields": { "position": { "x": 0, "y": 200, "z": 0 } } },
        { "type": "SpawnComponent", "fields": { "spawner": "player" } }
      ]
    }
  ]
}
```

- Each component is `{"type": ..., "fields": {...}}`. A field left out keeps the component's default.
- A child names its parent with `"parentName"`, listed after the parent. `"enabled": false` loads an entity switched off.
- `"mode"` is `2d` or `3d`. It tells the editor which view to show; the runtime treats both alike.

## Loading scenes

`SceneLoader` loads a scene into a world and returns the entities it created, in file order:

- `SceneLoader.loadAsset(world, path)` reads an asset through `world.context.bundle`, without caching.
- `SceneLoader.loadString(world, json)` takes JSON text, and `SceneLoader.load(world, map)` a decoded map.

`SceneLoader.loadManifest()` reads `scenes.json` and returns the scene names, and `SceneAssets.pathFor(name)` turns a name into `assets/scenes/<name>.scene.json`.

```dart
import 'package:just_game_engine/just_game_engine.dart';

/// Loads [name], or the first scene in scenes.json, into the world.
Future<void> startLevel(
  Engine engine,
  List<Spawner> spawners, {
  String? name,
}) async {
  final world = engine.world;
  final scene = name ?? (await SceneLoader.loadManifest()).first;
  await SceneLoader.loadAsset(world, SceneAssets.pathFor(scene));

  // Maps and their tile collision, before the first frame: otherwise the
  // player can fall through ground that is still loading.
  await LevelMaps.preload(world);

  // Spawn points name what to create; the game says how.
  SpawnPoints.spawnAll(world, spawners);
}

/// Replaces the current level with [name].
Future<void> changeLevel(
  Engine engine,
  List<Spawner> spawners,
  String name,
) async {
  engine.world.destroyAllEntities();
  engine.cameraSystem.brain.reset(); // forget the old level's cameras
  await startLevel(engine, spawners, name: name);
  LevelMaps.evictUnused(engine.world); // drop tilesets no map uses now
}
```

`LevelMaps.preload` returns the maps that failed to load as a list of `LevelMapLoadFailure`s. Spawners are covered in [Tags & spawners](/docs/tags-spawners) and maps in [Level maps](/docs/level-maps).

Loading decodes every component before it creates anything, so a scene that fails to load leaves the world untouched.

## Your own components in scenes

A scene can only hold components the engine has a `ComponentDefinition` for. The engine's own are always known. For your own component, write a definition and install it through an extension:

```dart
import 'package:just_game_engine/just_game_engine.dart';

class SpeedBoostComponent extends Component {
  SpeedBoostComponent({this.factor = 1.5});

  double factor;
}

final speedBoostDefinition = ComponentDefinition<SpeedBoostComponent>(
  type: 'SpeedBoostComponent', // the saved type: keep it stable
  create: SpeedBoostComponent.new,
  fields: [
    SchemaField(
      name: 'factor',
      kind: FieldTypes.decimal,
      read: (c) => (c as SpeedBoostComponent).factor,
      write: (c, v) =>
          (c as SpeedBoostComponent).factor = (v as num).toDouble(),
      min: 1,
    ),
  ],
);

final class MyGameExtension implements ContextExtension {
  const MyGameExtension();

  @override
  String get id => 'my_game';

  @override
  void install(EngineContext context) {
    context.definitions.register(speedBoostDefinition);
  }
}

final engine = Engine(
  config: const EngineConfig(
    extensions: [MyGameExtension()],
    defaultSystems: DefaultSystems.all,
  ),
);
```

- `type` is the string written to scenes. Renaming it orphans saved levels; list old names in `aliases` instead.
- `create` makes a component with default values, which loading then overwrites field by field.
- Each `SchemaField` has a `name` (the JSON key, also stable), a `kind`, a `read` and a `write`. `min` and `max` clamp numbers as they load. A field with no `write` is saved but never restored.
- `FieldTypes` holds the kinds: `boolean`, `integer`, `decimal`, `text`, `assetRef`, `entityRef`, `tagRef`, `tagList`, `spawnerRef`, `target`, `enumeration`, `list`, `map`, `vector2`, `vector3`, `euler`, `color`, `offset`, `shapePaintStyle` and more.
- `ComponentDefinition.extend(base, ...)` defines a subclass of an engine component, keeping the base's fields and adding yours.
- `hints` (`ComponentHints`, `FieldHint`) only shape how an editor's inspector shows the component.

`context.definitions.registerAll(list)` registers several at once. The same definition is what an editor uses to save and inspect the component, so the game and the editor always agree on the format.

## Format versions and migrations

Every scene carries a `version`. `SceneFormat.current` is the newest format the engine knows: 10 in 2.0.0-dev.2, which added prefab instances, and 9 in 2.0.0-dev.1. A file at an older version, such as the version 9 used on this page, is migrated in memory as it loads; the file on disk is never rewritten. Pass `onMigrated` to hear about it: the `MigrationResult` has `fromVersion` and `notes` worth showing a developer.

A package adds its own rules to the engine's migration steps through `context.migrations` (a `MigrationHooks`), usually from its extension. Those rules run as part of the engine's steps, so they only apply to files saved at an older format.

## When a scene does not load

| Exception | Cause |
|---|---|
| `UnknownComponentTypeException` | A component `type` nobody registered. Its `type` and `entityName` say which; install the extension that defines it. 3-D components need `graphics3D` or `physics3D` in the config. |
| `UnsupportedFormatVersionException` | The file was saved by a newer engine. `found` and `supported` give both versions. |
| `FormatException` | A value has the wrong type. The message names the entity, the component and the field. |

`UnsupportedFormatVersionException` is itself a `FormatException`, so catch it first:

```dart
Future<bool> tryLoad(World world, String name) async {
  try {
    await SceneLoader.loadAsset(world, SceneAssets.pathFor(name));
    return true;
  } on UnknownComponentTypeException catch (e) {
    debugPrint('No definition for ${e.type} (entity ${e.entityName})');
  } on UnsupportedFormatVersionException catch (e) {
    debugPrint('Saved by a newer engine: ${e.found} > ${e.supported}');
  } on FormatException catch (e) {
    debugPrint('Broken scene: ${e.message}');
  }
  return false;
}
```

## Prefab files

2.0.0-dev.2 adds prefab files (`.prefab.json`): a scene entry can place an instance of one, with its own changes kept as overrides, and prefabs can nest. `SceneLoader.loadAsset` reads the prefabs a scene uses before it loads the scene. To make one at run time, load it with `PrefabLibrary.of(engine.context).load(path)` and then call `instantiate(world, path, position: ...)`; `Spawner.prefab(id: ..., path: ...)` places one at every matching spawn point. For prefabs built in code, see [EntityPrefab](/docs/ecs).

## Saving

The engine reads scenes; it has no API that writes a world back to a scene file. The editor is what saves levels.

For save games, keep your own state, and store it with `engine.cache.setJson(key, data)` and read it back with `getJson(key)`. If you want to reuse the scene format for a component, `engine.context.definitions.encode(component)` returns its `{"type", "fields"}` map (or null when nothing defines it), and `decode(json)` turns such a map back into a component.
''',
  ),
];
