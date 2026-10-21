import 'doc_models.dart';

/// The "Getting started" pages: what the engine is, how to install it, a
/// first game, and the move from 1.x.
const List<DocPage> gettingStartedDocs = [
  DocPage(
    id: 'introduction',
    title: 'Introduction',
    group: DocGroups.gettingStarted,
    summary:
        'What Just Game Engine is, the tools that come with it, the platforms '
        'it runs on and where the 2.0 release stands.',
    keywords: [
      'Engine',
      'World',
      'GameWidget',
      'ECS',
      'just_game_engine',
      'just_game_engine_editor',
      'just_core_cli',
      'just_game_engine_cli',
      'just_game_engine_formats',
      'just_game_services',
    ],
    body: r'''
Just Game Engine is a game engine for Flutter. It is 2D, with 3D graphics and 3D physics you can opt into. A game is entities, components and systems (ECS) in a `World`, and its levels are JSON scenes that the game loads at run time. The engine draws inside an ordinary Flutter widget, `GameWidget`, so a game can be a whole app or one screen of a larger one.

It brings level maps, sprites and animator graphs, timelines, virtual cameras, physics, particles, audio and action-based input. The level editor saves the same scene files the game loads, so nothing stands between saving a level and shipping it.

## A first look

This is a whole game: a floor, and a ball that falls onto it.

```dart lib/main.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The engine, with its standard systems.
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  // y points down, and (0, 0) is the middle of the screen until a
  // virtual camera takes over.
  engine.world
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, 200, 0)),
      RectangleComponent(width: 600, height: 24),
      // A collider alone is a static body; this one is the drawn rectangle.
      Collider2D(shape: ColliderShape2D.matchShape),
    ], name: 'Floor')
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, -150, 0)),
      CircleComponent(radius: 24),
      RigidBody2D(),
      Collider2D(shape: ColliderShape2D.matchShape),
    ], name: 'Ball');

  engine.start();
  runApp(MaterialApp(home: GameWidget(engine: engine)));
}
```

- `Engine()` makes a new engine each time. `initialize()` builds its subsystems and world; finish it before you use the engine.
- `engine.start()` starts the game loop. `GameWidget` runs it on Flutter's frame ticker, draws the world, and passes keys and pointers to `engine.input`.
- When you are done, `await engine.dispose()`. Disposal is final: to start over, make a new `Engine()`.

[Your first game](/docs/quick-start) builds on this step by step.

## The toolkit

The engine is one package. These are the others you will meet:

| Package | What it is | Version |
|---|---|---|
| `just_game_engine` | The engine: the ECS world, scenes, rendering, physics, audio, input and the rest. | `2.0.0-dev.2` |
| `just_game_engine_editor` | A level editor that runs inside your game in a desktop debug build. See [Level editor](/docs/editor). | `0.1.0-dev.1` |
| `just_core_cli` | `just`, the command-line tool: it creates projects, checks their setup and upgrades them. | `0.1.1` |
| `just_game_engine_cli` | The `just game` commands: run, build, scenes, release checks and migrations. See [The just CLI](/docs/cli). | `0.1.2` |
| `just_game_engine_formats` | The saved file formats (scenes, timelines, animator graphs) and their migrations, in pure Dart. The engine re-exports it, and the editor and the CLI migrate files with the same code. | comes with the engine |
| `just_game_services` | Achievements, sign-in, leaderboards, currency, inventory and ads, as opt-in engine services. See [Game services](/docs/services). | `0.1.0`, not yet on pub.dev |

Under the engine sit packages of the same family: `just_physics_engine` (Box2D v3 through FFI where its native library loads, a pure-Dart engine with the same API elsewhere, and Jolt Physics for 3D), `just_graphics_engine` (3D on Flutter GPU), `just_inputs`, `just_audio_engine`, `just_tiled` and a few smaller ones. You rarely import them yourself.

## Platforms

- **The engine** runs on Android, iOS, Windows, macOS, Linux and the web, compiled to JavaScript or WebAssembly.
- **3D graphics** draw where Flutter GPU does: not on the web, and not on Android devices without Vulkan. There the game still runs, and the 3D view shows a short note.
- **3D physics** runs where Jolt is built, which is everywhere but the web.
- **On the web**, 2D physics runs on the pure-Dart engine, audio starts at the first key or pointer press, and fragment-shader effects are skipped.
- **The editor** edits on Windows, macOS and Linux, in a debug build. On other platforms, and in any profile or release build, the game runs on its own.
- **The `just` tool** runs on Windows, macOS and Linux.

[Platforms](/docs/platforms) has the details for each one.

## What's included

- [The engine object](/docs/engine): `Engine`, `EngineConfig`, the default systems and the game loop.
- [Entities, components and systems](/docs/ecs): `World`, `Entity`, `System`, queries, events and the transform hierarchy.
- [Scenes](/docs/scenes): levels as JSON, `SceneLoader`, component definitions and format migrations.
- [Rendering](/docs/rendering): `RenderSystem`, shapes, draw order, render hooks and post-processing.
- [Sprites and animation](/docs/sprites): sprites, TexturePacker and Aseprite atlases, and animator graphs.
- [Timelines](/docs/timelines): keyframed component fields, events, camera shots and audio.
- [Cameras](/docs/cameras): virtual cameras, framing, confiners, impulses and blends.
- [Particles and effects](/docs/particles): emitters, presets and deterministic, tick-based effects.
- [3D graphics](/docs/graphics-3d): models, lights, environments and built-in shapes on Flutter GPU.
- [2D physics](/docs/physics-2d): `RigidBody2D`, `Collider2D`, `CharacterBody2D`, joints, queries and events.
- [3D physics](/docs/physics-3d): the same model on Jolt Physics.
- [Input](/docs/input): named actions from `just_inputs`, local multiplayer, rebinding and touch controls.
- [Level maps](/docs/level-maps): tile maps, Tiled import and export, and tile collision.
- [Tags, targets and spawners](/docs/tags-spawners): finding entities by tag, and spawn points.
- [Audio](/docs/audio): music, sound effects and 3D sound.
- [Assets](/docs/assets), [Localization](/docs/localization) and [Dialogue](/docs/dialogue) (Yarn Spinner 2.x scripts).
- [GameWidget and Flutter UI](/docs/game-widget): overlays, widget layers and ready-made widgets.
- [Game services](/docs/services), [Debugging](/docs/debugging) and [Testing](/docs/testing).

## Version status

2.0 is a breaking release, out first as dev releases. The latest is 2.0.0-dev.2, and these docs are written for it. The latest stable release is 1.6.1.

> **Note:** A `^2.0.0` constraint does not pick up dev releases. Depend on `just_game_engine: ^2.0.0-dev.2`, as [Installation](/docs/installation) shows.

- **Coming from 1.x?** Read [Migrating from 1.x](/docs/migration). Scene files saved by earlier versions still load: they are migrated in memory as they are read.
- **Between dev releases**, read the [CHANGELOG](https://github.com/just-unknown-dev/just-game-engine/blob/main/CHANGELOG.md) before you move up.
- **The examples site** at [examples.engine.justunknown.com](https://examples.engine.justunknown.com) was written for 1.x.
- **The editor and the CLI** are first releases: the editor is 0.1.0-dev.1, the `just` tool 0.1.1 and the game plugin 0.1.2.

## License

The engine, the editor and the CLI packages are open source under the BSD 3-Clause license. Each repository has its LICENSE file.

## Getting help

- **Discord:** ask questions and share what you build at [discord.gg/VXFxVj4Y](https://discord.gg/VXFxVj4Y).
- **Issues:** report bugs against the [engine](https://github.com/just-unknown-dev/just-game-engine/issues), the [editor](https://github.com/just-unknown-dev/just-game-engine-editor/issues) or the [CLI](https://github.com/just-unknown-dev/just-game-engine-cli/issues).
- **API reference:** every public class and member is on [pub.dev](https://pub.dev/documentation/just_game_engine/latest/).
- **The repository's own docs:** the [engine on GitHub](https://github.com/just-unknown-dev/just-game-engine) has its README, QUICKSTART, MIGRATION, ARCHITECTURE and an API map by area.
''',
  ),
  DocPage(
    id: 'installation',
    title: 'Installation',
    group: DocGroups.gettingStarted,
    summary:
        'Start a new game with the just CLI, or add the engine to an existing '
        'Flutter app, then opt into 3D where you need it.',
    keywords: [
      'just create',
      'just game run',
      'just_core_cli',
      'pubspec.yaml',
      'flutter: assets',
      'Graphics3D',
      'Physics3D',
      'Flutter GPU',
      'just_jolt',
      'flutter_web_plugins',
    ],
    body: r'''
There are two ways in. A new project made with the `just` command-line tool comes with the engine, the editor and the wiring between them. An existing Flutter app adds the engine like any other package.

## Requirements

- **Flutter 3.47.1 or newer.** It is the first stable release where Flutter GPU can be switched on in Windows and Linux release builds, which the 3D renderer needs. Every app builds the renderer's shaders; a 2D game never loads them.
- **A desktop for the editor.** The editor runs in a debug build on Windows, macOS or Linux.
- **Linux builds** also need what the audio plugin links: OpenAL Soft and libsndfile (`sudo apt install libopenal-dev libsndfile1-dev` on Debian and Ubuntu). Players need `libopenal1` and `libsndfile1`.

## Path 1: a new game with the CLI

Install the `just` tool once, then create and run a game:

```bash
dart pub global activate just_core_cli
just create my_game
cd my_game
just game run            # the game
just game run --editor   # the game with the level editor (desktop, debug)
```

`just create` runs `flutter create`, writes `just.json`, and adds `just_core_cli` and `just_game_engine_cli` to the dev dependencies. It then hands the folder to the game plugin, which lays the game template over it on engine versions that work together, writes the first level (`level_01`), and adds the editor through the Asset Store. If a step fails, `just create` deletes the folder it made (or empties the empty folder you gave it).

| Path | What it holds |
|---|---|
| `lib/main.dart` | The game, as it ships. It never imports the editor. |
| `lib/main_editor.dart` | The game with the editor over it, in debug builds only. |
| `lib/game/` | The game: its boot, systems and spawners. |
| `lib/editor/` | What the editor needs from the game. It never ships. |
| `assets/scenes/` | The levels, as the JSON the editor saves. |
| `just.json` | The project's title and the tool set it is on. |

`just game run` runs `flutter run` on `lib/main.dart`; with `--editor` it runs `lib/main_editor.dart` on this desktop. If `just` is already another program on your machine (such as the `just` command runner), type `ju` instead: it is the same tool. [The just CLI](/docs/cli) covers every command and option.

## Path 2: add the engine to an existing app

Add the engine to `pubspec.yaml`, list the asset folders your game loads from, and run `flutter pub get`:

```yaml pubspec.yaml
environment:
  sdk: ^3.11.0
  flutter: ">=3.47.1"

dependencies:
  flutter:
    sdk: flutter
  # just_audio_engine registers a web plugin without depending on
  # flutter_web_plugins; depending on it here keeps web builds compiling.
  flutter_web_plugins:
    sdk: flutter
  just_game_engine: ^2.0.0-dev.2

flutter:
  assets:
    - assets/scenes/
    - assets/input/
    - assets/sprites/
    - assets/audio/
    - assets/project/physics.json
```

> **Warning:** Write the dev release into the constraint. `^2.0.0` alone does not pick up dev releases, so it will not find 2.0.0-dev.2.

One import gives you the engine: `package:just_game_engine/just_game_engine.dart`. The ready-made widgets (dialogue boxes, on-screen controls, rebinding lists) are in `package:just_game_engine/widgets.dart`; import it only if you use them.

To add the editor to an existing app as well, see [Level editor](/docs/editor).

## Declaring assets

The engine reads scenes, input actions, atlases, maps, timelines and sounds through Flutter's asset bundle, so each file must be listed under `flutter: assets:`, by itself or through its folder.

- **A folder entry does not include its subfolders.** List each folder you load from.
- **Scenes** live in `assets/scenes/` as `<name>.scene.json`, with the play order in `assets/scenes/scenes.json`. List `assets/scenes/`.
- **Collision layers** live in `assets/project/physics.json`, which the editor's Physics Layers dock writes. The engine reads it during `initialize()` when the app bundles it; without it, every body collides with every other.
- **A sprite that does not show** is most often a file missing from this list, or an atlas image that is not beside its JSON.

## Opting into 3D graphics

A game is 2D unless you give the engine a `Graphics3D`, from `package:just_game_engine/graphics_3d.dart`. Without one, the engine makes no GPU device and loads no shaders, and a scene holding 3D components fails to load with a message saying how to turn 3D on.

3D draws with Flutter GPU, which must be switched on in each platform's runner. `just create` does this for you when the template it starts from draws in 3D. Otherwise, add the switch by hand:

| Platform | File | What to add |
|---|---|---|
| Windows | `windows/runner/main.cpp` | `project.set_enable_flutter_gpu(true);` after `project.set_dart_entrypoint_arguments(...)`. Release builds ignore the `--enable-flutter-gpu` flag, so the switch belongs in code. |
| Linux | `linux/runner/my_application.cc` | `fl_dart_project_set_enable_flutter_gpu(project, TRUE);` after the entry-point arguments. |
| Android | `android/app/src/main/AndroidManifest.xml` | `meta-data` entries setting `io.flutter.embedding.android.EnableImpeller` and `io.flutter.embedding.android.EnableFlutterGPU` to `true`, and `io.flutter.embedding.android.ImpellerBackend` to `vulkan`. |
| iOS | `ios/Runner/Info.plist` | `FLTEnableFlutterGPU` set to true. |
| macOS | `macos/Runner/Info.plist` | `FLTEnableImpeller` and `FLTEnableFlutterGPU` set to true. |

The `just_graphics_engine` README (Getting started) is the reference for these switches. Where Flutter GPU cannot draw, the game runs anyway: scenes and models load, the 3D view shows a short note, `unsupportedReason` says why, and `Graphics3D(onUnsupported: ...)` hears about it.

## Opting into 3D physics

3D physics runs on Jolt Physics, which your app's pubspec must build:

```yaml pubspec.yaml
hooks:
  user_defines:
    just_jolt:
      build: true
```

Then give the engine a `Physics3D`, from `package:just_game_engine/physics_3d.dart`. A game without one is 2D only, and its release build holds no 3D physics code and no Jolt. Where 3D physics cannot run (the web, or Jolt not built), `initialize()` throws an `EngineInitException` whose `cause` is a `Physics3DUnsupportedError`. Ask `Physics3D.isSupported` first in a game that also targets the web:

```dart lib/main.dart
import 'package:just_game_engine/graphics_3d.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/physics_3d.dart';

Future<Engine> start3D() async {
  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      graphics3D: Graphics3D(),
      // Jolt does not run on the web: ask before giving the engine 3D physics.
      physics3D: Physics3D.isSupported ? Physics3D() : null,
    ),
  );
  await engine.initialize();
  engine.start();
  return engine;
}
```

[3D graphics](/docs/graphics-3d) and [3D physics](/docs/physics-3d) cover what to do next.

## The web

The engine has no `dart:io` outside one conditional import, so a game builds for the web with JavaScript or WebAssembly (`flutter build web`, or `flutter build web --wasm`). A few things work differently there:

- **2D physics** runs on the pure-Dart engine, with the same API as native Box2D.
- **Audio** starts at the first key or pointer press, because browsers keep audio made before a user gesture silent. `EngineConfig.deferAudioUntilInput` changes this.
- **Shader effects** (`PostProcessPass`, `ShaderComponent`) are skipped, and the content draws unshaded.
- **Gamepads** appear once a button is pressed, because browsers hide them until then.
- **3D** scenes and models load but are not drawn, and 3D physics does not run.
- **`flutter_web_plugins`** must be a dependency, as in the pubspec above. Games made with `just create` have it.
''',
  ),
  DocPage(
    id: 'quick-start',
    title: 'Your first game',
    group: DocGroups.gettingStarted,
    summary:
        'Draw shapes, move one, load a level from scene JSON, and learn the '
        'five things that trip people up.',
    keywords: [
      'Engine',
      'EngineConfig',
      'DefaultSystems',
      'GameWidget',
      'TransformComponent',
      'VelocityComponent',
      'ParentComponent',
      'SystemPriorities',
      'SceneLoader',
      'LevelMaps',
      'SpawnPoints',
      'Spawner',
    ],
    body: r'''
This page takes you from an empty Flutter app to shapes on screen, a box that moves by itself, and a level loaded from JSON. It assumes the engine is in your `pubspec.yaml` ([Installation](/docs/installation)).

## The first game

Put this in `lib/main.dart` and run it:

```dart lib/main.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The engine's standard systems: input, physics, movement, audio,
  // rendering, sprites, level maps, map collision and cameras.
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  // The camera's position is the world point in the middle of the screen.
  engine.cameraSystem.mainCamera
    ..lookAt(Offset.zero)
    ..zoom = 1.0;

  final world = engine.world;
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-150, 0, 0)),
    CircleComponent(
      radius: 40,
      fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
    ),
  ], name: 'Sun');

  // +Y is down: this box drifts towards the bottom of the screen.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(150, -100, 0), angle: 0.3),
    VelocityComponent(velocity: Vector3(0, 40, 0)),
    RectangleComponent(
      width: 120,
      height: 60,
      cornerRadius: 8,
      fillStyle: const ShapePaintStyle(color: Colors.orange),
    ),
  ], name: 'Box');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
```

## What each part does

- **`EngineConfig(defaultSystems: DefaultSystems.all)`** adds the standard systems while the engine initializes. Without it the world starts with no systems, and nothing moves or draws. `DefaultSystems.headless` is the same set without rendering and audio, for servers and tests.
- **`await engine.initialize()`** comes before anything touches `engine.world`, `engine.physics`, `engine.input` or the other subsystems. Before that they throw `EngineNotReadyError`. If a stage fails, `initialize()` throws `EngineInitException` and undoes what it built.
- **An entity** is an id with components. `createEntityWithComponents` adds them in one go. The shape components (`CircleComponent`, `RectangleComponent`, `PolygonComponent`, `LineComponent`, `CapsuleComponent`) draw themselves.
- **`engine.start()`** starts the game loop. `GameWidget` drives it from Flutter's frame ticker, draws the world, and sends keys and pointers to `engine.input`. It shows an FPS counter unless you pass `showFPS: false`.
- **`Engine` is an ordinary object.** Make one per game session. When the game is one screen of a larger app, create it in a `State` and call `engine.dispose()` from `dispose()`. Disposal is final: to play again, make a new `Engine`.

## Five things that trip people up

### The world updates in fixed steps

`GameWidget` calls `engine.gameLoop.tick()` once per display frame. The world then updates in fixed steps of 1/60 s (`engine.gameLoop.fixedDeltaTime`): none, one or several per frame, with at most three steps' worth of time carried over, so a stall does not snowball. Every `System.update(deltaTime)` receives that fixed step times `engine.time.timeScale`.

- Move things in `update`, by `deltaTime`. Do not read the wall clock.
- Drawing happens once per display frame, between steps. Physics bodies and their children are drawn between their last two steps (`engine.gameLoop.interpolation`), so they stay smooth on a 120 Hz screen. Entities your own code moves are drawn where they are.
- `engine.pause()` stops the steps. The screen still draws and input still updates, so a pause menu keeps working.

### +Y is down

The axes are `WorldAxes`: +X right, +Y down, +Z into the screen. Gravity is +Y and a jump is -Y. A positive `angle` turns clockwise.

### TransformComponent is the world transform

Physics, cameras, timelines and your code all read and write `TransformComponent` in world space. A child's offset from its parent lives in its `ParentComponent` (`localPosition`, `localRotation`, `localScale`), and the world keeps the two in step every update. If you write a child's transform directly, its local offset is worked out again from where you put it.

```dart lib/turret.dart
import 'package:just_game_engine/just_game_engine.dart';

/// Hangs a turret on [tank], 30 units above its centre. From the next
/// update on it moves and turns with the tank.
Entity addTurret(World world, Entity tank) => world.createEntityWithComponents([
  TransformComponent(),
  // Where the turret sits in the tank's space. The next update places
  // it there, whatever its TransformComponent says now.
  ParentComponent(parentId: tank.id, localPosition: Vector3(0, -30, 0)),
  RectangleComponent(width: 50, height: 12),
], name: 'Turret');
```

- The world keeps the other end of the link: the tank gets a `ChildrenComponent` listing the turret.
- Give a `ParentComponent` no local values and the child stays where its `TransformComponent` puts it. Scenes load their links this way.
- To move the turret on the tank later, change `localPosition` (for example `localPosition.y = -40`).
- Destroying the tank destroys the turret. Pass `withChildren: false` to `world.destroyEntity` to keep the children.

### Systems run by priority, highest first

Systems run in priority order, not in the order you add them. Set a system's priority before you add it; overriding the `priority` getter is simplest, for example `int get priority => SystemPriorities.playerControl;`. The constants are in `SystemPriorities`:

| Priority | Constant | What runs |
|---|---|---|
| 110 | `levelMap` | Level maps load and update. |
| 108 | `mapCollision` | Bodies for map tiles. |
| 100 | `input` | Actions copied onto `InputComponent`s. |
| 95 | `playerControl` | Your character controller: reads input, sets velocity. |
| 90 | `physics` | The physics step. |
| 80 | `movement` | Velocity onto transform, for entities without a body. |
| 70 | `animation` | Animators, sprite clips, timelines. |
| 60 | `gameplay` | Health, lifetime, your game rules. |
| 50 | `hierarchy` | Children follow their parents. |
| 45 | `camera` | The camera brain frames the finished positions. |
| 40 | `render` | `RenderSystem`, which draws once per display frame. |
| -10 | `audio` | Sounds follow their entities. |

### One component of each type per entity

Adding a second component of a type replaces the first. Every shape and every sprite is stored as a `RenderableComponent`, so one entity draws one thing: put a second drawing on a child entity. Read a shape back with `entity.getComponent<RenderableComponent>()`; `getComponent<CircleComponent>()` finds nothing.

## Load a level from scene JSON

Levels are scene files: `assets/scenes/<name>.scene.json`, listed in play order in `assets/scenes/scenes.json` (for example `{ "scenes": ["level_01"] }`). Declare the folder under `flutter: assets:` in `pubspec.yaml`. The [level editor](/docs/editor) writes these files, but they are plain JSON, so you can write one by hand:

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
    },
    {
      "name": "MainCamera",
      "components": [
        { "type": "TransformComponent", "fields": {} },
        { "type": "VirtualCameraComponent", "fields": { "follow": { "tag": "player" } } },
        { "type": "CameraFramingComponent", "fields": { "screenY": 0.1 } }
      ]
    }
  ]
}
```

A spawn point names what to create; the game says how, with a `Spawner`. Load the level after `initialize()` and before `start()`:

```dart lib/level.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// What the level's spawn points can create.
final spawners = [
  Spawner(
    id: 'player',
    label: 'Player',
    tags: const {'player'}, // the tags the spawned entity carries
    spawn: (world, point) => world.createEntityWithComponents([
      // The spawn point's position; TransformComponent copies it.
      TransformComponent(
        position: point.getComponent<TransformComponent>()?.position,
      ),
      RectangleComponent(
        width: 32,
        height: 48,
        fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
      ),
      TagComponent('player'), // the scene's camera follows this tag
    ], name: 'Player'),
  ),
];

/// Loads the first scene in scenes.json into the engine's world.
Future<void> loadFirstLevel(Engine engine) async {
  final world = engine.world;
  final names = await SceneLoader.loadManifest(); // assets/scenes/scenes.json
  await SceneLoader.loadAsset(world, SceneAssets.pathFor(names.first));
  // Maps and their tile collision before the first frame, so nothing
  // falls through ground that is still loading.
  await LevelMaps.preload(world);
  SpawnPoints.spawnAll(world, spawners);
}
```

- **A field left out** keeps the component's default. A child names its parent with `"parentName"`, and `"enabled": false` loads an entity switched off.
- **Each component** is read through its `ComponentDefinition` in `engine.context`. The engine's own components always load. A package's components load once its `ContextExtension` is listed in `EngineConfig(extensions: [...])`; otherwise the load stops with an `UnknownComponentTypeException` naming the type and the entity.
- **Versions.** The current scene format is 10 in 2.0.0-dev.2, and was 9 in 2.0.0-dev.1 (`SceneFormat.current`). Older files are migrated in memory as they load; a file from a newer engine throws `UnsupportedFormatVersionException`.
- **Without the asset bundle**, `SceneLoader.loadString` and `SceneLoader.load` take JSON text or a decoded map, which is handy in tests.

[Scenes](/docs/scenes) covers changing levels, your own components and migrations.
''',
  ),
  DocPage(
    id: 'migration',
    title: 'Migrating from 1.x',
    group: DocGroups.gettingStarted,
    summary:
        'Upgrade a 1.6 game to 2.0: the checklist first, then each breaking '
        'change with before-and-after code.',
    keywords: [
      'MIGRATION.md',
      'Engine.instance',
      'EngineConfig',
      'DefaultSystems',
      'PhysicsBodyComponent',
      'RigidBody2D',
      'Collider2D',
      'TransformComponent.angle',
      'VirtualCameraComponent',
      'InputService',
      'just_game_services',
      'just game migrate',
    ],
    body: r'''
`just_game_engine` 2.0 is a breaking release. The engine is now an object you create, initialize and dispose yourself. Levels are JSON scenes loaded at run time. Cameras, input, sprites, tile maps and the transform hierarchy were rebuilt, and several built-in parts moved to packages of their own.

This page condenses the [full migration guide](https://github.com/just-unknown-dev/just-game-engine/blob/main/MIGRATION.md) on GitHub, which has every table, the deprecated APIs and the edge cases. Scene files saved by earlier versions still load: they are migrated in memory when they are read.

## Checklist

1. Raise the constraints: `just_game_engine: ^2.0.0-dev.2` and Flutter 3.47.1 or newer. `^2.0.0` alone does not pick up dev releases.
2. Create the engine with `Engine(config: ...)`, `await initialize()` before `runApp`, and dispose it once. Replace `Engine.instance` with a reference you pass around.
3. Add the standard systems through `EngineConfig.defaultSystems`, or give `PhysicsSystem` the engine's physics.
4. Replace `PhysicsBodyComponent` with a `RigidBody2D` and a `Collider2D`, and the collision events with the `...2D` events.
5. Using achievements, sign-in, leaderboards, currency, inventory or ads? Add `just_game_services`.
6. Rename `transform.rotation` to `transform.angle`, drop `HierarchySystem`, and rename `ParentComponent.localOffset` to `localPosition`.
7. Replace camera behaviours and `CameraFollowComponent` with virtual cameras, and read input as actions from `just_inputs`.
8. Replace the in-game UI components, the Tiled components, `engine.animation` and the tweens, and read tags with `hasTag` and `tags`.
9. Move render hooks to the hook chains, and fix imports: `package:just_game_engine/widgets.dart` for the widgets, and the source package for names no longer re-exported.
10. Check the removed and renamed APIs, re-test what behaves differently, and read the known limitations if you use joints or audio streams.

## Engine lifecycle

In 1.6, `Engine()` returned one process-wide engine, also reachable as `Engine.instance`. In 2.0 every call makes a new, independent engine. Build and initialize it before `runApp`, and add the standard systems through its config:

```dart
// 1.6
final engine = Engine(); // the shared engine
engine.initialize().then((ok) {
  engine.world.addSystem(RenderSystem());
  engine.start();
});

// 2.0
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize(); // throws EngineInitException if a stage fails
  engine.start();
  runApp(MaterialApp(home: Scaffold(body: GameWidget(engine: engine))));
}
```

| 1.6 | 2.0 |
|---|---|
| `Engine()` returns the shared engine; `Engine.instance`, `Engine.resetInstance()` | `Engine({config, context})` makes a new engine each time; keep a reference |
| `Future<bool> initialize()` printed errors and returned `false` | `Future<void> initialize()` throws `EngineInitException(stage, cause, stackTrace)` and undoes what it built |
| `void dispose()`; the singleton could be reset and reused | `Future<void> dispose()`, and it is final: make a new `Engine()` to start over |
| `rendering`, `physics`, `world` were `late final` fields | getters that throw `EngineNotReadyError` before `initialize` and after `dispose` |
| `EngineState.error`; `engine.getSystem<T>()` | `EngineState.failed`; `engine.subsystem<T>()` (`getSystem` is deprecated) |

- **A widget that owns its engine** disposes it in `State.dispose`; not awaiting `dispose()` there is safe. A `GameWidget` given an engine that is still initializing starts it once it is ready, and your own code can follow it through `engine.stateListenable`.
- **Default systems.** `DefaultSystems.all` adds input, physics, movement, audio, rendering, sprites, level maps, map collision and cameras; `DefaultSystems.headless` leaves out rendering and audio. A system you added yourself is kept, not added twice. `ParticleSystemECS`, `EffectSystemECS`, `HealthSystem`, `LifetimeSystem` and `CheckpointSystem` are not defaults: add the ones you use.
- **Changed constructors.** `PhysicsSystem()` is `PhysicsSystem(engine.physics, camera: ...)`, and gravity is `engine.physics.setGravity(x, y)`. `PhysicsBridgeSystem` is gone. `InputSystem(engine.input)..buttonMappings` is `InputSystem(engine.input, maps: ['player'])`.
- **Your own components in scenes** need a `ComponentDefinition`, installed through a `ContextExtension` in `EngineConfig(extensions: [...])`. See [Scenes](/docs/scenes).

## Physics bodies

`PhysicsBodyComponent` is split the way 3D physics splits a body: `RigidBody2D` says how it moves, `Collider2D` gives it its shape. A `Collider2D` alone is a static body, so walls and floors need nothing else.

```dart
// 1.6
PhysicsBodyComponent(
  shape: RectangleShape(32, 48),
  fixedRotation: true,
  restitution: 0,
);

// 2.0
RigidBody2D(lockRotation: true, friction: 0.2),
Collider2D(size: Vector2(32, 48)),
```

| 1.6 | 2.0 |
|---|---|
| `shape: RectangleShape(w, h)` | `Collider2D(size: Vector2(w, h))` (a box, the default shape) |
| `shape: CircleShape(r)` | `Collider2D(shape: ColliderShape2D.circle, radius: r)` |
| a shape sized to the sprite or rectangle | `ColliderShape2D.matchShape`, kept in step as the drawing changes |
| `isStatic` | `RigidBody2D.bodyType` (`BodyType.static`, `BodyType.kinematic`, or dynamic by default) |
| `drag`, `fixedRotation`, `isBullet` | `linearDamping`, `lockRotation`, `continuousCollision` |
| `layer` as a bit, `collisionMask` | `layer` as a number from 0 to 15, `collidesWith` |
| `CollisionEvent`, `ContactExitEvent`, `SensorEnterEvent`, `SensorExitEvent` | `CollisionEnter2DEvent`, `CollisionExit2DEvent`, `SensorEnter2DEvent`, `SensorExit2DEvent` (`visitor` is now `other`) |
| `DistanceJointComponent`, `WeldJointComponent`, `PrismaticJointComponent`, `WheelJointComponent` | `DistanceJoint2D`, `FixedJoint2D`, `SliderJoint2D`, `WheelJoint2D` |

- **The defaults changed** to 3D's: `friction` 0.5 (1.6 used 0.2), `restitution` 0 (1.6: 0.8, so everything bounced), `linearDamping` and `angularDamping` 0.05 (1.6's `drag` was 0.98), and `mass` 0, which works the mass out from the collider's area. Set the old values where you relied on them; scenes saved by 1.6 keep theirs.
- **Colliders follow scale.** Scale an entity by 2 and its collider grows with it. Code that sized a shape for an entity it also scaled now sizes it unscaled.
- **Named layers.** The layer names and which pairs collide live in `assets/project/physics.json` (a `PhysicsLayers`); list it under `flutter: assets:`. Check pairs with `engine.context.physicsLayers.collides(a, b)`.
- **New:** `CharacterBody2D`, a character gameplay moves (`moveVelocity`, `jump`) instead of the simulation. See [2D physics](/docs/physics-2d).

## Transforms and the hierarchy

The 2D angle is `angle`, and the full rotation is three Euler angles (`eulerX`, `eulerY`, and `angle` about Z). Every `World` now keeps its transform hierarchy itself, so `HierarchySystem` goes, and a child's offset turns and scales with its parent.

```dart
// 1.6
transform.rotation += 0.1;
world.addSystem(HierarchySystem());
world.createEntityWithComponents([
  TransformComponent(),
  ParentComponent(parentId: ship.id, localOffset: Vector3(0, -20, 0)),
]);

// 2.0: no HierarchySystem; the world keeps the hierarchy itself
transform.angle += 0.1; // or transform.rotate(0.1)
world.createEntityWithComponents([
  TransformComponent(),
  // 20 units above the ship from the next update on, turning with it.
  ParentComponent(parentId: ship.id, localPosition: Vector3(0, -20, 0)),
]);
```

Also renamed: `rotationX` and `rotationY` are `eulerX` and `eulerY`, `prevRotation` (a `double`) is `prevAngle`, and `TransformSignals.rotation` is `TransformSignals.angle`. Code that added a `ChildrenComponent` by hand can go: a `ParentComponent` is the whole link.

## Cameras

Camera behaviours, `CameraFollowComponent`, springs, shake and `worldBounds` are gone. A shot is now an entity with a `VirtualCameraComponent`; the camera brain (`engine.cameraSystem.brain`) shows the enabled shot with the highest priority and blends to it. Components on the same entity decide how the shot moves.

```dart
// 1.6
engine.cameraSystem.addBehavior(SpringFollowBehavior(target: playerPosition));
engine.cameraSystem.mainCamera.worldBounds = const Rect.fromLTWH(0, 0, 4000, 800);
engine.cameraSystem.mainCamera.shake(12, 0.4);

// 2.0
world.createEntityWithComponents([
  TransformComponent(position: Vector3(2000, 400, 0)),
  CameraBoundsComponent(width: 4000, height: 800),
], name: 'Level Bounds');
world.createEntityWithComponents([
  TransformComponent(),
  VirtualCameraComponent(follow: const EntityTarget.name('Player')),
  CameraFramingComponent(dampingX: 0.3, dampingY: 0.5, lookaheadTime: 0.2),
  CameraConfinerComponent(boundsName: 'Level Bounds'),
  CameraImpulseListenerComponent(),
], name: 'Main Camera');
engine.cameraSystem.brain.emitImpulse(
  CameraImpulse(position: const Offset(640, 360), amplitude: 12),
);
```

The other behaviours map to components too: `LookaheadBehavior` to `CameraFramingComponent.lookaheadTime`, `MultiTargetBehavior` to `CameraTargetGroupComponent` with `CameraGroupFramingComponent`, `RoomBehavior` to a virtual camera per room switched by a `CameraTriggerComponent`, `PathBehavior` to `CameraDollyComponent`, and `CinematicBehavior` to `CameraBlendListComponent` or a timeline. The dead zone and soft zone are fractions of the screen, not pixels. The camera systems are in `DefaultSystems.all`, or add them with `registerCameraSystems(world, engine.cameraSystem)`. With no virtual camera in the world, the brain leaves `engine.cameraSystem.mainCamera` alone, so a game that moves it by hand keeps working.

## Input

`engine.input` was an `InputManager` you polled for keys. It is now a `just_inputs` `InputService`: named actions bound to keyboard, mouse, gamepads and touch, read the same way whatever the device. The bindings live in an input asset (`.input.json`) that the game loads after `initialize()`.

```dart
Future<void> loadInput(Engine engine) async {
  final text = await rootBundle.loadString('assets/input/game.input.json');
  engine.input.loadAsset(InputActionAsset.parse(text));
  await engine.input.attachGamepads(); // optional: starts platform channels
}

// InputSystem copies the 'player' map's actions into each InputComponent.
void readInput(Engine engine, Entity player) {
  final input = player.getComponent<InputComponent>()!;
  final Offset move = input.vector('move'); // was input.moveDirection
  if (input.wasPressed('jump')) debugPrint('jump while moving $move');
  // Or read any action directly:
  final pause = engine.input.actions.action('ui/pause');
  if (pause.wasPressedThisFrame()) engine.pause();
}
```

| 1.6 | 2.0 |
|---|---|
| `engine.input.keyboard.isKeyDown(key)` | an action: `engine.input.actions.action('map/name').isPressed()` |
| `InputComponent.isButtonPressed('jump')` | `input.isDown('jump')`; also `wasPressed`, `wasReleased`, `wasPerformed`, `axis` |
| `VirtualJoystick`, `JoystickInputComponent` | on-screen controls in the asset, drawn by `OnScreenControls` |

Input keeps running while the engine is paused, so menus and rebinding work. [Input](/docs/input) shows the asset format.

## Game services

Achievements, sign-in, leaderboards, currency, inventory and ads moved to the `just_game_services` package (`just_game_services: ^0.1.0`). In 1.6 every engine built all six; now you list the ones you use, and the engine starts them in `initialize()` and stops them in `dispose()`.

```dart
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_services/just_game_services.dart';

Future<Engine> startGame() async {
  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      // GameServices.all() gives all six, as 1.6 had them.
      services: [AchievementManager(), CurrencyManager()],
    ),
  );
  await engine.initialize(); // starts both services
  engine.currency.add('coins', 10);
  return engine;
}
```

Saved progress carries over: achievements, currency and inventory still save to the `jge_engine` database. `engine.achievements` and the others now throw a `StateError` naming the fix when the engine has no such service. The managers' `bindWorld`, `initialize` and `dispose` are now `start` and `stop`, called by the engine. The Steam and Epic providers are gone; they did nothing.

## Imports

- **Widgets moved** to `package:just_game_engine/widgets.dart`: `DialogueBoxWidget`, `DialogueChoicesWidget`, `SubtitleOverlay`, `LocalizedText`, `GameCameraControls`, `OnScreenControls`, `RebindList` and the rest. `GameWidget`, `GameLayers`, `LocalizationScope` and `GameTerminal` stay in the main library.
- **Re-exports are lists now.** The engine re-exports only what its own API uses from `just_inputs`, `just_dart`, `just_memory`, `just_audio_engine` and `just_physics_engine`. For anything else, such as the input asset model (`ActionMapDef`, `InputActionDef`), `Quadtree` or `ObjectPool`, add the package to `pubspec.yaml` and import it. A file that imported `package:just_game_engine/src/...` must import the library instead.

## Removed and renamed APIs

| 1.6 | 2.0 |
|---|---|
| `SceneEditor`, `Scene`, `SceneNode`, `engine.sceneEditor` | entities, and `SceneLoader` for JSON scenes |
| `engine.animation`, the tweens, `AnimationStateComponent` | `SpriteAnimationComponent`, effects (`MoveEffect`, `FadeEffect` and the rest) and timelines |
| `TileMapLayerComponent`, `TiledMapFactory`, `TileMapRenderSystem`, `TiledCollisionSystem` | `LevelMapComponent`, `LevelMapSystem`, `MapCollisionSystem` |
| `TextComponent`, `ButtonComponent`, `UIComponent` | `just_ui_editor`, or Flutter widgets over `GameWidget` |
| `engine.network` and the networking classes | nothing: they were stubs |
| `tagComponent.tag` | `tags`, `entity.hasTag('enemy')`, `world.allTagged`, `world.findTagged` |
| `onRenderOverlay`, `onRenderBackground` | `engine.rendering.overlayHooks.add(...)` and `backgroundHooks` |
| `LocalizationManager.instance` | `engine.context.localization` |
| `Sprite.fromAsset(path)` | `Sprite.fromAsset(path, assets: engine.assets)` |
| `AssetBundle` (the engine's), `typedef Easing` | `GameAssetBundle`, `EasingFunction` |
| `SystemPriorities.tileMap` | `SystemPriorities.levelMap` |

## Behaviour you may notice

- **Destroying an entity destroys its children.** `world.destroyEntity(entity, withChildren: false)` keeps them.
- **A switched-off parent switches off its subtree.** Queries, tag lookups and the engine's systems go by `Entity.isActiveInHierarchy`.
- **Draw order follows `LayerComponent`** (layer, then z-order). Give entities one where order matters.
- **`GameWidget` always draws the world.** If your overlay hook called `engine.world.render`, remove the call, or the world draws twice.
- **`RenderSystem` draws particle emitters itself.** Remove emitters you registered with `addManagedEmitter` or `addRenderable`, or they draw twice.
- **`CollisionEnter2DEvent.depth` is always 0**, and its `point` is worked out from where the two bodies' bounds meet.

## Known limitations

These wait on `just_physics_engine` and `just_audio_engine`. The fields involved are saved as usual, so scenes need no change when the limits lift.

- **Joint anchors.** `anchor` and `connectedAnchor` of `DistanceJoint2D` and `FixedJoint2D` are not passed to the physics engine. A wheel joint's axle anchor is honoured on native Box2D only.
- **`collideConnected`.** Jointed bodies with it off send no contact events between them, but on the pure-Dart backend (the web) they still push each other apart.
- **Queries on native Box2D** skip bodies whose collision mask is 0; the Dart backend finds them.
- **Stream channels.** An `AudioStreamComponent`'s channel volume does not apply to the stream, and a playing sound's pitch, pan, speed and loop cannot change.

## Saved data

- **Scenes** carry a `version`; the current format is 10 (9 in 2.0.0-dev.1). `SceneLoader` migrates an older file in memory, one step at a time, before creating anything, and nothing on disk changes until the file is saved again. Timelines, animator graphs, level maps and tilesets have format numbers too, and a file from a newer engine is refused with an `UnsupportedFormatVersionException`.
- **Rewrite the files** with `just game migrate` in a project made with the CLI ([The just CLI](/docs/cli)), or from your own script with `SceneFormat.migrateWithReport`, as the full guide shows. Review the diff before you commit it.
- **Storage.** The engine keeps its own storage file, apart from the app's, and moves its keys there on the first launch of 2.0. Cache entries written with `setString` or `setJson` before 2.0 are no longer read. Game services data stays in the `jge_engine` database, as in 1.x.
''',
  ),
];
