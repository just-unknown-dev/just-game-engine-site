import 'doc_models.dart';

/// The "Flutter & shipping" pages: hosting the game in an app, services,
/// debugging, testing and platforms.
const List<DocPage> flutterDocs = [
  DocPage(
    id: 'game-widget',
    title: 'UI over the game',
    group: DocGroups.flutter,
    summary:
        'Host the game in a GameWidget, draw a HUD with its overlay, put menus and text fields on engine.layers, and use the ready-made widgets.',
    keywords: [
      'GameWidget',
      'GameLayers',
      'GameLayer',
      'GameLayerController',
      'overlay',
      'OnScreenControls',
      'RebindList',
      'DialogueBoxWidget',
      'SubtitleOverlay',
      'LocalizedText',
      'GameCameraControls',
      'SignalBuilder',
      'ESP',
    ],
    body: r'''
UI is ordinary Flutter. `GameWidget` shows the game, and you draw widgets over it in one of two ways: its `overlay`, for a HUD, or `engine.layers`, for menus and anything that needs the keyboard.

## GameWidget

`GameWidget(engine: engine)` ticks the game loop from Flutter's frame ticker, draws the world, and passes keys and pointers to `engine.input`. You can build it before `initialize()` has finished: it starts ticking and drawing the engine once it is ready, with no rebuild.

| Parameter | Default | What it does |
|---|---|---|
| `engine` | required | The engine to show. |
| `showFPS` | `true` | An `FPS: n` badge in the top right corner. |
| `showDebug` | `false` | The debug overlay; see [Debugging & stats](/docs/debugging). |
| `showTerminal` | `false` | The developer terminal, toggled with the backquote key. |
| `overlay` | none | A widget stacked over the game canvas. |
| `showLayers` | `true` | Whether the layers on `engine.layers` are drawn. |
| `passthroughKeys` | none | Keys reported to Flutter as not handled, so a focus ancestor may also act on them. The game still sees them. |

From bottom to top, a `GameWidget` stacks the game canvas with its `overlay`, then the layers, then the FPS badge and the terminal. It also pauses a running engine when the app goes to the background and resumes it on return, but only if it paused it itself: a game the player paused stays paused.

Two `GameWidget`s can show one engine; each frame is counted once. When `engine.context.localization` is set, everything the widget draws sits under a `LocalizationScope` for it (see [Localization](/docs/localization)). Set `engine.cursor.value` to `SystemMouseCursors.none` to hide the mouse over the game.

## A HUD with the overlay

`GameWidget(overlay: ...)` stacks your widgets over the game. Taps on them do not reach the game. They can never take keyboard focus, which keeps the game's key state reliable, so use the overlay for a HUD and buttons, not for text fields.

```dart lib/game_screen.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/widgets.dart';

/// The game with a score and touch controls over it.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.engine, required this.score});

  final Engine engine;
  final ValueNotifier<int> score;

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      engine: engine,
      showFPS: false,
      overlay: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: score,
              builder: (context, value, _) => Text(
                'Score $value',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          // The on-screen sticks and buttons the input asset defines,
          // shown on touch platforms.
          Positioned.fill(child: OnScreenControls(input: engine.input)),
        ],
      ),
    );
  }
}
```

## Menus and text fields with layers

A `GameLayer` registered on `engine.layers` (a `GameLayers`) is drawn in every `GameWidget` that shows the engine. A layer has an `id`, an `order` (lower draws first) and `createController(engine)`. Each `GameWidget` asks it for its own `GameLayerController`, whose `build` draws the widgets, `onFrame` runs once a frame after the game has stepped, and `dispose` releases its state.

Layers sit outside the game's focus node, so a text field in a layer can be typed into and a menu walked with the arrow keys. Keys a layer does not use still reach the game; while a text field has focus, only key-ups go through.

```dart lib/pause_menu.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A pause menu. Register once: `engine.layers.register(const PauseMenu())`.
class PauseMenu extends GameLayer {
  const PauseMenu();

  @override
  String get id => 'pause_menu';

  @override
  GameLayerController createController(Engine engine) => _PauseMenuView(engine);
}

class _PauseMenuView extends GameLayerController {
  _PauseMenuView(this.engine);

  final Engine engine;
  final ValueNotifier<bool> _paused = ValueNotifier(false);

  // Called every frame, even while the engine is paused.
  @override
  void onFrame() => _paused.value = engine.isPaused;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _paused,
    builder: (context, paused, _) => paused
        ? Center(
            child: FilledButton(
              autofocus: true,
              onPressed: engine.resume,
              child: const Text('Resume'),
            ),
          )
        : const SizedBox.shrink(),
  );

  @override
  void dispose() => _paused.dispose();
}
```

`engine.layers` also has `unregister(id)`, `byId(id)`, `all` and `clear()`. `setEnabled(id, false)` hides a layer and keeps its controllers' state; `isEnabled(id)` reads it back. `GameWidget(showLayers: false)` hides them all in one view.

## Ready-made widgets

`package:just_game_engine/widgets.dart` holds optional screen widgets. The main library leaves them out, so import it only when you use them.

| Widget | What it does |
|---|---|
| `OnScreenControls` | Touch sticks and buttons from the input asset, with `OnScreenVisibility`, `OnScreenButtonFace` and `OnScreenStickPainter` to style them. See [Input](/docs/input). |
| `RebindList`, `RebindButton`, `RebindRow`, `BindingLabel` | A player's controls, each with a button to rebind it. |
| `DialogueBoxWidget`, `DialogueChoicesWidget` | Lines and choices of a `DialogueRunner`. See [Dialogue](/docs/dialogue). |
| `SubtitleOverlay` | The cues of a `SubtitleController`. |
| `LocalizedText`, `LocalizationBuilder`, `LocaleSelector` | Text and widgets that follow the locale, with `context.t()` from `L10nContext`. |
| `GameCameraControls` | Zoom by mouse wheel, pinch or buttons, and drag to pan. |

For HUDs and menus designed in an editor and saved as `.ui.json` screens, there is the `just_ui_editor` package, which draws its screens through `engine.layers`. It is not published on pub.dev.

## Engine · Signal · Presentation

For state that several widgets share, or that the game updates continuously, the engine suggests three layers, built from pieces it already has:

1. **Engine layer**: systems and components, the only code that touches ECS types. It pushes continuous values into signals, and one-off moments through `world.events`.
2. **State layer**: plain Dart classes holding `Signal` and `Computed` fields, with no Flutter or ECS imports, so you can unit-test them without a widget tree.
3. **Presentation layer**: widgets that read the state layer through `SignalBuilder` and call back through methods, never reaching into the `World`.

`Signal` and `Computed` come with the engine; `SignalBuilder` needs `just_signals` in your pubspec.

```dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_signals/just_signals.dart';

// State layer.
class PlayerSignals {
  final Signal<double> health = Signal(1.0);
}

// Engine layer: writes the signal once a step, after the gameplay systems.
class PlayerHudSync extends System {
  PlayerHudSync(this.signals);

  final PlayerSignals signals;
  Entity? _player;

  @override
  int get priority => SystemPriorities.gameplay - 5;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    var player = _player;
    if (player == null || !player.isAlive) {
      player = _player = world.findTagged('player'); // looked up once
    }
    final health = player?.getComponent<HealthComponent>();
    if (health != null) signals.health.value = health.healthPercent;
  }
}

// Presentation layer.
class HealthBar extends StatelessWidget {
  const HealthBar({super.key, required this.signals});

  final PlayerSignals signals;

  @override
  Widget build(BuildContext context) => SignalBuilder<double>(
    signal: signals.health,
    builder: (context, value, _) => LinearProgressIndicator(value: value),
  );
}
```

Give the writing system a priority after everything it reads, so a signal is written once per step with settled data. Setting a `Signal` to the value it already holds does nothing, so you need no equality check of your own. For a one-off toggle used by a single widget, a plain `setState` is simpler.
''',
  ),
  DocPage(
    id: 'services',
    title: 'Services & plugins',
    group: DocGroups.flutter,
    summary:
        'Run your own code beside the engine with EngineService, observe a running engine with EnginePlugin, and add achievements, currency and more from just_game_services.',
    keywords: [
      'EngineService',
      'ServiceContext',
      'ServiceHost',
      'EngineConfig.services',
      'EnginePlugin',
      'PluginHost',
      'just_game_services',
      'AchievementManager',
      'CurrencyManager',
      'GameServices',
    ],
    body: r'''
Two hooks let code live beside the game. An `EngineService` starts when the engine initializes and stops when it is disposed. An `EnginePlugin` attaches to an engine to watch or extend it and is called every frame.

## Engine services

A service implements two methods: `start(ServiceContext context)` and `stop()`. List it in `EngineConfig(services: [...])`, or add it later with `engine.services.add(service)`.

```dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_game_engine/just_game_engine.dart';

/// Counts the collisions the game has had, for the engine's whole life.
class CollisionCounter implements EngineService {
  int count = 0;
  EventSubscription? _subscription;

  @override
  Future<void> start(ServiceContext context) async {
    _subscription = context.events.on<CollisionEnter2DEvent>((_) => count++);
  }

  @override
  Future<void> stop() async {
    _subscription?.cancel();
    _subscription = null;
  }
}

Future<Engine> boot() async {
  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      services: [CollisionCounter()],
    ),
  );
  await engine.initialize(); // starts the service
  debugPrint('${engine.service<CollisionCounter>().count} collisions so far');
  return engine;
}
```

- **Starting.** Services start last in `initialize()`, after the world exists, in the order declared. A `Graphics3D` in the config starts before yours, so your services can load models; a `Physics3D` starts after them. A service added to an engine that is already initialized starts at once.
- **Failing.** A `start` that throws fails `initialize()` with an `EngineInitException` whose `stage` is `service:<Type>`, and the services already started are stopped.
- **Stopping.** `dispose()` calls every `stop()`, last started first, before the world goes, and its Future completes once all of them have finished. A service must not touch the world after its `stop()` is called.
- **Context.** `ServiceContext` gives the service its `engine`, the engine's `context`, and `events`, the world's event bus. `events` is read on each call, so never cache the world itself.

`engine.service<T>()` returns the service of type `T`, and throws a `StateError` that says how to add it when there is none. `engine.maybeService<T>()` returns null instead. `engine.services` also has `has<T>()`, `all` and `remove(service)`. Adding a service whose runtime type is already there stops and replaces the old one.

## Plugins

An `EnginePlugin` is for tools that observe or extend a running engine: an editor, a profiler, a replay recorder. Register it with `engine.plugins.register(plugin)`. A plugin has an `id`; registering another with the same id detaches and replaces the first.

| Member | When it is called |
|---|---|
| `attach(engine)` | Once, when the plugin is registered. |
| `update(dt)` | Once per frame, with the unscaled frame time, even while the game is paused or its time scale is zero. |
| `renderOverlay(canvas, size)` | Once per frame, in screen space, after the world has drawn. |
| `detach()` | When the plugin is unregistered, or when the engine is disposed. |

```dart
/// Logs every frame that takes longer than 1/30 s.
class SlowFrameLogger extends EnginePlugin {
  @override
  String get id => 'slow_frame_logger';

  @override
  void update(double dt) {
    if (dt > 1 / 30) {
      debugPrint('Slow frame: ${(dt * 1000).toStringAsFixed(1)} ms');
    }
  }
}

// await engine.plugins.register(SlowFrameLogger());
```

`engine.plugins` also has `unregister(id)`, `byId(id)` and `all`. Simulation belongs in systems, which run on the fixed step; a plugin sees the engine on wall-clock time.

## Achievements, currency and more

Achievements, sign-in, leaderboards, a currency wallet, an inventory and ads are services in a separate package, `just_game_services`. Nothing from it runs unless you list it.

> **Note:** `just_game_services` is not on pub.dev yet, so the dependency below will not resolve until it is published. Watch the [engine repository](https://github.com/just-unknown-dev/just-game-engine) for its release.

```yaml pubspec.yaml
dependencies:
  just_game_engine: ^2.0.0-dev.2
  just_game_services: ^0.1.0
```

```dart
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_services/just_game_services.dart';

Future<Engine> startGame() async {
  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      // Or GameServices.all() for all six.
      services: [
        AchievementManager()..define(
          Achievement(
            id: 'first_win',
            name: 'First Win',
            description: 'Beat level 1',
          ),
        ),
        CurrencyManager(),
      ],
    ),
  );
  await engine.initialize(); // starts both services
  engine.achievements.unlock('first_win');
  engine.currency.add('coins', 10); // saved to disk by default
  return engine;
}
```

`engine.achievements`, `engine.currency` and the others are extension getters from the package, and each is `engine.service<T>()` under another name: asking for one the engine was not given throws a `StateError` naming the fix. `AdsManager.initialize(consent: ...)` is still yours to call. For a real sign-in or leaderboard backend, write an `AuthProvider` or `LeaderboardProvider`.

> **Note:** Coming from 1.x, where every engine built all six: the managers' `bindWorld`, `initialize` and `dispose` are now `start` and `stop`, called by the engine. See [Migration](/docs/migration).
''',
  ),
  DocPage(
    id: 'debugging',
    title: 'Debugging & stats',
    group: DocGroups.flutter,
    summary:
        'Read the engine\'s performance and per-subsystem stats, switch on the debug overlay and the developer terminal, and fix the most common problems.',
    keywords: [
      'performanceStats',
      'world.stats',
      'schedulerStats',
      'RenderingEngine.stats',
      'RenderSystem.stats',
      'PhysicsEngine.stats',
      'GameTerminal',
      'showDebug',
      'showFPS',
      'showTerminal',
      'ColliderDebuggerSystem',
      'drawsOutlines',
      'EngineNotReadyError',
    ],
    body: r'''
Every stat the engine keeps can be read at run time, without external tools, and all of them are cheap enough to read every frame. `GameWidget` adds an FPS badge, a debug overlay and a developer terminal on top.

## The debug overlay

```dart
GameWidget(
  engine: engine,
  showFPS: true, // the default
  showDebug: kDebugMode,
  showTerminal: kDebugMode,
)
```

- **`showFPS`** shows `FPS: n` in the top right corner, from `engine.gameLoop.currentFPS`. It updates about once a second and costs the rest of the widget nothing.
- **`showDebug`** adds a `ColliderDebuggerSystem` to the world, which outlines every physics body and every `RaycastColliderComponent` through the main camera. It also sets `engine.rendering.debugMode`, which prints the rendering figures (render time, draws, culled objects) in the top left corner. Both go away when `showDebug` turns off.
- **`showTerminal`** enables the developer terminal (below).

In 2.0.0-dev.2, `PhysicsSystem` no longer draws collider outlines unless asked. Turn them on with `engine.world.getSystem<PhysicsSystem>()?.drawsOutlines = true`, and narrow them with `outlineFilter`; a collider's own `showDebugOutline` has the last word. Release builds never draw them.

## The developer terminal

With `showTerminal: true`, the backquote key opens a command console over the game. While it is open, the keyboard goes to the terminal, not the game. It has `help` and `clear` built in; register your own commands on `engine.terminal`:

```dart
void addDebugCommands(Engine engine) {
  engine.terminal.registerCommand(
    name: 'stats',
    description: 'Show entity counts and the last update time.',
    handler: (args) {
      final world = engine.world.stats;
      final perf = engine.performanceStats;
      return 'entities ${world['activeEntities']}/${world['totalEntities']}, '
          'update ${perf['lastUpdateMs']} ms';
    },
  );
  engine.terminal.registerCommand(
    name: 'timescale',
    description: 'Set the time scale. Usage: timescale <value>',
    handler: (args) {
      final value = args.isEmpty ? null : double.tryParse(args.first);
      if (value == null || value < 0) return 'Usage: timescale <value>';
      engine.time.timeScale = value;
      return 'time scale $value';
    },
  );
}
```

A handler gets the words after the command name and returns a line to print, or null to print nothing. A command name is one word; registering a name again replaces its handler.

## Engine stats

`engine.performanceStats` is safe to read in any state. It covers the last fixed step:

| Key | What it is |
|---|---|
| `frame` | Fixed steps run while the engine was running, since it was made. |
| `deltaTime` | The `dt` of the last step: the fixed step times the time scale. |
| `lastUpdateMs` | Milliseconds the last step's update tasks took together. |
| `budgetRemainingMs`, `isOverBudget` | The last step measured against a 16.67 ms frame. |
| `systemTimesMs` | Milliseconds per update task: `input`, `parallax`, `particles`, `ecs`, and any you registered. Physics is inside `ecs`. |
| `scheduler` | `engine.systemManager.schedulerStats`: task count and timings. |

The subsystems' own figures exist only between `initialize()` and `dispose()`; check `engine.isInitialized` first when that can happen.

- **`engine.world.stats`**: `totalEntities`, `activeEntities`, `systems`, `activeSystems`, `archetypes` (a number that keeps growing points to component churn), `lastUpdateMs`, `lastCommandFlushes`, and `systemTimesMs` with each system's update time by type name, plus `TransformHierarchy`.
- **`engine.physics.stats`**: `bodyCount`, `awakeBodies`, `lastStepMs` and the pure-Dart engine's broadphase counters. On native platforms, `backend` is `box2d_v3`, or `dart_fallback` when the Box2D library did not load; the web has no `backend` key.
- **`engine.rendering.stats`**: `lastRenderMs`, `drawCalls`, `renderedObjects`, `culledObjects`, `batchedSprites` and `postProcessPasses` for the whole frame. `world.getSystem<RenderSystem>()?.stats` holds what the world's `RenderSystem` drew.
- **Live getters**: `engine.gameLoop.currentFPS` and `interpolation`; `engine.time.deltaTime`, `totalTime`, `timeScale` and `frameCount`; `engine.cache.isUsingMemoryFallback`; and `engine.assets.getCacheStats()` for loaded assets and their estimated memory.

> **Note:** Timings are measured in debug and profile builds only. In a release build `engine.systemManager.profiling` and `engine.world.profiling` are off and the timings read 0; set them to `true` to measure anyway.

One map with every subsystem's figures, to log or send to telemetry:

```dart
Map<String, dynamic> snapshot(Engine engine) => {
  ...engine.performanceStats,
  if (engine.isInitialized) ...{
    'fps': engine.gameLoop.currentFPS,
    'ecs': engine.world.stats,
    'physics': engine.physics.stats,
    'rendering': engine.rendering.stats,
    'cacheInMemory': engine.cache.isUsingMemoryFallback,
  },
  'assets': engine.assets.getCacheStats(),
};
```

The overlay shows no update or physics timings; draw your own from these maps, for example from `lastUpdateMs`, `systemTimesMs` and `physics.stats['lastStepMs']`.

## When something does not work

| What you see | Likely cause |
|---|---|
| A blank screen, nothing moves | No `defaultSystems` in `EngineConfig`, or `engine.start()` was not called. |
| `EngineNotReadyError` | `engine.world` or another subsystem was used before `await engine.initialize()`, or after `dispose()`. |
| `StateError` from `start()` | The engine is not initialized, or already running. |
| Things appear in the wrong place | +Y is down, and the camera's position is the world point in the middle of the screen. |
| A sprite does not show | The file is not listed under `flutter: assets:`, or the atlas image is not beside its JSON. |
| An animator never changes state | It needs a `SpriteAnimationComponent` on the same entity. A parameter whose `binding` is not registered in `engine.context.animatorBindings` silently keeps its default. |
| Particles do not move | `ParticleSystemECS` was not added; it is not a default system. |
| `UnknownComponentTypeException` loading a level | The package that defines the component was not given to `EngineConfig(extensions: ...)`. |
| The player falls through a map on the first frame | Call `await LevelMaps.preload(world)` after loading the scene. |
| Your system reads stale input or runs after physics | Its priority: character control belongs at `SystemPriorities.playerControl` (95). |
| No collider outlines in a debug build | Set `PhysicsSystem.drawsOutlines`, or use `GameWidget(showDebug: true)`. |
| Every timing reads 0 | A release build: see the note above. |
| No sound on the web until the first click | Expected: browsers keep audio silent until the player interacts. |
''',
  ),
  DocPage(
    id: 'testing',
    title: 'Testing',
    group: DocGroups.flutter,
    summary:
        'Test game logic with a bare World or a headless Engine, step time yourself, and load scenes and assets without a device.',
    keywords: [
      'flutter_test',
      'World',
      'DefaultSystems.headless',
      'world.update',
      'gameLoop.tick',
      'SceneLoader.loadString',
      'EngineContext',
      'AssetBundle',
      'testWidgets',
    ],
    body: r'''
Make a new engine, or a new world, in each test and dispose it afterwards. Nothing ticks by itself in a test, because there is no `GameWidget` driving the loop: you step time yourself.

## A world on its own

For plain ECS logic, a `World()` on its own is enough, and much faster than an engine. It makes a fresh context with the engine's components registered and disposes it with itself. Add the systems you are testing and call `world.update(1 / 60)` once per step:

```dart test/movement_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('velocity moves an entity', () {
    final world = World()..initialize();
    addTearDown(world.dispose);
    world.addSystem(MovementSystem());

    final box = world.createEntityWithComponents([
      TransformComponent(),
      VelocityComponent(velocity: Vector3(60, 0, 0)),
    ]);
    for (var i = 0; i < 30; i++) {
      world.update(1 / 60);
    }

    expect(
      box.getComponent<TransformComponent>()!.position.x,
      closeTo(30, 1e-9),
    );
  });
}
```

## A headless engine

When a test needs the engine's subsystems, make an engine with `DefaultSystems.headless`: every standard system except rendering and audio. Await `initialize()`, register `dispose` as a tear-down, and step its world directly.

```dart test/level_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a level loads', () async {
    final engine = Engine(
      config: const EngineConfig(defaultSystems: DefaultSystems.headless),
    );
    addTearDown(engine.dispose);
    await engine.initialize();

    SceneLoader.loadString(engine.world, """
      {"version": 9, "name": "test", "mode": "2d", "entities": [
        {"name": "Spawn", "components": [
          {"type": "TransformComponent", "fields": {}},
          {"type": "SpawnComponent", "fields": {"spawner": "player"}}
        ]}
      ]}
    """);
    engine.world.update(1 / 60);

    expect(SpawnPoints.first(engine.world, 'player')?.name, 'Spawn');
  });
}
```

In a test, the engine's storage cannot open its file, so `engine.cache` keeps everything in memory (`isUsingMemoryFallback` is true), and the audio engine's failure to start is logged and ignored. Neither stops the test.

## Running the whole loop

`world.update` runs the systems only. To run a step the way a game does, with the input update and every other update task, start the engine and tick its game loop with frame timestamps. The first tick only starts the clock; after that, each tick 1/60 s later runs one fixed step.

```dart
test('a pressed key reaches the actions', () async {
  final engine = Engine();
  addTearDown(engine.dispose);
  await engine.initialize();
  engine.input.loadAsset(InputActionAsset.parse(inputJson)); // your asset
  engine.start();

  const frame = Duration(microseconds: 16667);
  engine.gameLoop.tick(Duration.zero); // starts the clock
  engine.input.handleKeyEvent(
    const KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.space,
      logicalKey: LogicalKeyboardKey.space,
      timeStamp: Duration.zero,
    ),
  );
  engine.gameLoop.tick(frame); // one fixed step

  expect(engine.input.actions.action('player/jump').isPressed(), isTrue);
});
```

`KeyDownEvent` and the key classes come from `package:flutter/services.dart`. While the engine is paused, a tick still updates input, so you can test pause menus the same way.

## Assets in tests

- `SceneLoader.loadString` and `SceneLoader.load` read a scene without an asset bundle.
- `SceneLoader.loadAsset` reads through `world.context.bundle`. An engine made with `Engine(context: EngineContext(bundle: myTestBundle))` loads from a test bundle of your own, such as a `CachingAssetBundle` subclass that serves files from a map.
- A context you pass in is yours to dispose: call `context.dispose()` once the engine has been disposed.

## Widget tests

`GameWidget` works in `testWidgets`. Run the engine's asynchronous work with `tester.runAsync`, and pump frames to tick it:

```dart
testWidgets('the game draws', (tester) async {
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  addTearDown(() => tester.runAsync(engine.dispose));

  await tester.pumpWidget(
    MaterialApp(home: GameWidget(engine: engine, showFPS: false)),
  );
  await tester.runAsync(engine.initialize);
  engine.start();

  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(engine.performanceStats['frame'], greaterThan(0));
});
```

A `GameWidget` built before `initialize()` finishes picks the engine up once it is ready, so the order above works without a rebuild.
''',
  ),
  DocPage(
    id: 'platforms',
    title: 'Platforms & the web',
    group: DocGroups.flutter,
    summary:
        'Where the engine runs, what changes on the web and WebAssembly, what Linux builds need, and where 3D graphics and 3D physics are available.',
    keywords: [
      'web',
      'WebAssembly',
      'Wasm',
      'Android',
      'iOS',
      'Windows',
      'macOS',
      'Linux',
      'Box2D',
      'Jolt',
      'Flutter GPU',
      'Physics3D.isSupported',
      'deferAudioUntilInput',
    ],
    body: r'''
The engine runs on Android, iOS, Windows, macOS, Linux and the web, compiled to JavaScript or WebAssembly. It needs Flutter 3.47.1 or newer. A 2-D game runs everywhere; 3-D drawing and 3-D physics depend on what each platform can do.

## Platform support

| Platform | 2-D physics | 3-D graphics (Flutter GPU) | 3-D physics (Jolt) |
|---|---|---|---|
| Windows | Box2D, native | Supported | Supported (x64) |
| Android | Box2D, native | Vulkan devices only | arm64-v8a and x86_64 |
| Linux | Box2D, native | Expected to work, untested | Should build, untested |
| macOS | Box2D, native | Expected to work, untested | Should build, untested |
| iOS | Box2D, native | Expected to work, untested | Should build, untested |
| Web (JS and Wasm) | Pure Dart | Not drawn | Not available |

The 3-D statuses come from the `just_graphics_engine` and `just_jolt` packages the engine builds on. A game without a `Graphics3D` or `Physics3D` in its config is 2-D only and carries none of that code.

## The web and WebAssembly

The engine's library imports `dart:io` in one place only, behind a conditional import, so a game builds for the web with JavaScript or WebAssembly. What differs there:

| Area | On the web |
|---|---|
| Physics | The pure-Dart engine instead of Box2D, with the same API. |
| Audio | Starts at the first key or pointer press, because browsers keep audio silent until the player interacts. `EngineConfig.deferAudioUntilInput` changes this; null means on the web only. |
| Shaders | Post-process passes and `ShaderComponent` effects are skipped and the content is drawn unshaded, as on native platforms still drawing with Skia. The 2-D materials added in 2.0.0-dev.2 draw the same everywhere, the web included. |
| Storage | `engine.cache` keeps its data in the browser's local storage, under a `just_game_engine/` namespace. |
| Gamepads | Work in JavaScript and WebAssembly builds once a button is pressed; browsers hide pads until then. |
| 3-D graphics | Scenes and models load, but nothing is drawn: Flutter GPU is not on the web, and the 3-D view shows a short note instead. |
| 3-D physics | Cannot run. `initialize()` fails with an `EngineInitException` whose `cause` is a `Physics3DUnsupportedError`. |

A game that targets both the web and native platforms asks before it turns 3-D physics on:

```dart
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/physics_3d.dart';

final engine = Engine(
  config: EngineConfig(
    defaultSystems: DefaultSystems.all,
    // Null on the web and wherever Jolt was not built into the app.
    physics3D: Physics3D.isSupported ? Physics3D() : null,
  ),
);
```

`Physics3D.unsupportedReason` says why 3-D physics cannot run. For 3-D drawing, a `Graphics3D` never fails the engine: where Flutter GPU cannot draw, the game runs anyway, `unsupportedReason` on your `Graphics3D` says why, and `Graphics3D(onUnsupported: ...)` hears it once.

## 3-D graphics and 3-D physics

3-D drawing uses Flutter GPU, which must be switched on in each platform's runner: see the Getting started section of the `just_graphics_engine` README, and [3D graphics](/docs/graphics-3d). On Android it needs the Vulkan backend; on a device without Vulkan the game runs without the 3-D view, which shows a short note instead.

3-D physics runs on Jolt, compiled from source by the `just_jolt` build hook, which compiles nothing unless your app's own pubspec asks for it:

```yaml pubspec.yaml
hooks:
  user_defines:
    just_jolt:
      build: true
```

See [3D physics](/docs/physics-3d) for the components.

## Native physics

On native platforms, `engine.physics` is Box2D v3 through FFI, compiled by the `just_box_2d` build hook. If the native library does not load, the engine logs it and falls back to the pure-Dart simulation; `engine.physics.stats['backend']` then reads `dart_fallback`. A web-only game, or one that uses the pure-Dart engine everywhere, can skip compiling Box2D with `hooks: user_defines: just_box_2d: build: false` in its pubspec.

## Linux

To build for Linux, install what the audio plugin links: OpenAL Soft and libsndfile. Players need the runtime libraries, `libopenal1` and `libsndfile1`.

```bash
sudo apt install libopenal-dev libsndfile1-dev
```

The Box2D build hook compiles with clang, which Flutter's Linux toolchain needs anyway.

## Storage

`engine.cache` keeps its data in a store of its own, apart from your app's: `<application support>/just_game_engine/just_storage.json` on desktop and mobile, and the browser's local storage under `just_game_engine/` on the web. When a store cannot be opened, as in tests, the cache keeps everything in memory for the rest of the run.

## No process-wide state

Everything an engine knows lives in its own `EngineContext`, and everything a world holds lives in that `World`. Two engines in one process, or two tests, never see each other's registrations. The engine's own test suite enforces this: it fails on any non-const `static` field in the engine's source that is not on a reviewed list. When you write a package for the engine, keep per-engine state in `context.slot(...)` rather than in a static, so it follows the same rule.
''',
  ),
];
