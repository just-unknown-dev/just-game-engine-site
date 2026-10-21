import 'doc_models.dart';

/// The Graphics group: rendering, sprites, timelines, cameras, particles and
/// 3D graphics, for just_game_engine 2.0.
const List<DocPage> graphicsDocs = [
  DocPage(
    id: 'rendering',
    title: 'Rendering & layers',
    group: DocGroups.graphics,
    summary:
        'How the engine draws your world: the render system, draw order, '
        'self-drawing shapes, culling, render hooks and passes, parallax '
        'backgrounds and render stats.',
    keywords: [
      'RenderSystem',
      'RenderingEngine',
      'RenderableComponent',
      'LayerComponent',
      'LevelLayers',
      'RectangleComponent',
      'CircleComponent',
      'CapsuleComponent',
      'PolygonComponent',
      'LineComponent',
      'ShapePaintStyle',
      'ShapeGradient',
      'CustomRenderable',
      'TextRenderable',
      'ViewCullingSystem',
      'CullStateComponent',
      'RenderHookChain',
      'RenderPass',
      'ComponentPainterPass',
      'ParallaxComponent',
      'ParallaxRenderSystem',
      'ParallaxBackground',
      'ParallaxLayer',
      'draw order',
      'batching',
      'culling',
    ],
    body: r'''
Everything a 2D game shows is drawn by one ECS system, `RenderSystem`, inside the `GameWidget` that hosts your engine. You describe what to draw with components; the system sorts it and draws it through the camera once per display frame.

## What the rendering systems do

`EngineConfig(defaultSystems: DefaultSystems.all)` includes `DefaultSystem.rendering`, which adds two systems. Both draw through `engine.cameraSystem.mainCamera`.

| System | Priority | What it draws |
|---|---|---|
| `RenderSystem` | 40 | Every entity's `RenderableComponent`, every level-map layer and every particle emitter, in one sorted list |
| `ParallaxRenderSystem` | 105 | `ParallaxComponent` backgrounds, behind the world |

`DefaultSystems.headless` leaves both out, for servers and tests. Around them, `engine.rendering` (a `RenderingEngine`) owns the frame: the background colour (`backgroundColor`), render hooks, post-processing and frame stats.

Drawing happens once per display frame, between the fixed 60 Hz updates. Moving physics bodies, and their children, are drawn between their last two poses so they stay smooth on a 120 Hz screen; everything else is drawn where it is. See [The engine](/docs/engine) for the loop.

> **Note:** One entity draws one thing. Shapes and sprites are all stored as a `RenderableComponent`, and an entity holds one component of each type, so adding a second shape replaces the first. Put a second drawing on a child entity.

## Shapes that draw themselves

Five components draw themselves, centred on their entity's `TransformComponent`. Lines and polygons take points relative to it.

| Component | Size fields |
|---|---|
| `RectangleComponent` | `width`, `height`, `cornerRadius` |
| `CircleComponent` | `radius` |
| `CapsuleComponent` | `width`, `height`; round at both ends of the longer side |
| `PolygonComponent` | `vertices`, a list of `Offset`s closed back to the first |
| `LineComponent` | `start` (the entity's position by default), `end`, `roundCaps` |

Each has a `fillStyle` and a `strokeStyle` (a line has only the stroke), `filled`, and a `strokeWidth` in world units. By default a shape is filled white with a translucent white outline one unit wide. The outline is drawn whenever its style is not fully transparent, so pass `strokeStyle: const ShapePaintStyle(color: Colors.transparent)` to remove it.

A `ShapePaintStyle` is a `color` plus an optional `gradient`. With a gradient, the colour tints it through `blendMode` (`BlendMode.modulate` by default, so the default white leaves it as it is). `ShapeGradient.linear` runs from `begin` to `end`, `ShapeGradient.radial` spreads from `center` out to `radius` (a fraction of the shape's shorter side), and `ShapeGradient.sweep` turns round `center`. All three take `colors` and optional `stops`.

```dart lib/scenery.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void addScenery(World world) {
  // Far behind everything: a gradient sky with no outline.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, -150, 0)),
    RectangleComponent(
      width: 2400,
      height: 700,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.linear(
          colors: [Color(0xFF14213D), Color(0xFF5B7DB1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      strokeStyle: const ShapePaintStyle(color: Colors.transparent),
    ),
    LayerComponent(layer: LevelLayers.background),
  ], name: 'Sky');

  // The main layer, drawn after main-layer entities with a lower zOrder.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 140, 0)),
    CapsuleComponent(
      width: 32,
      height: 72,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.radial(colors: [Colors.white, Colors.teal]),
      ),
    ),
    LayerComponent(zOrder: 10),
  ], name: 'Hero');

  // In front of everything: an outlined triangle.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(220, 120, 0)),
    PolygonComponent(
      vertices: const [Offset(0, -30), Offset(26, 15), Offset(-26, 15)],
      filled: false,
      strokeStyle: const ShapePaintStyle(color: Colors.amber),
      strokeWidth: 2,
    ),
    LayerComponent(layer: LevelLayers.foreground),
  ], name: 'Warning');
}

/// Shapes are stored as RenderableComponent: read them back by that type.
void highlight(Entity entity) {
  final shape = entity.getComponent<RenderableComponent>();
  if (shape is RectangleComponent) shape.strokeWidth = 6;
  shape?.renderable.tint = Colors.yellow;
}
```

Every field is read when the shape draws, so change `width`, `radius` or a style at any time and the next frame shows it. To find a shape later, keep the component you created, or ask for `RenderableComponent` and check its type, as `highlight` does: `getComponent<CircleComponent>()` finds nothing. The renderable inside also has `opacity`, `tint` and `visible`, which effects such as `FadeEffect` animate (see [Particles, effects & post-processing](/docs/particles)).

## Draw order and layers

`RenderSystem` sorts by layer, then by `zOrder`; lower values draw first, further back. Entities with equal keys keep the order they were found in, so they never swap from one frame to the next. Give an entity a `LayerComponent` to place it:

- `layer`: the coarse order. `LevelLayers` holds the usual values: `background` (-200), `backgroundNear` (-100), `main` (0) and `foreground` (100).
- `zOrder`: the order within a layer.
- `layerId`: the name the editor's layer panel groups by (`main` by default). It does not change the order.
- `visible` and `locked`: used by the editor only; the game ignores them.
- `mapLayer`: on a child of a level map, draws the entity among that map layer's tiles. See [Level maps](/docs/level-maps).

An entity without a `LayerComponent` sorts by its renderable's own `layer` and `zOrder`, which are 0 for the built-in shapes. For a top-down game, set `ySort` on a renderable: it then draws after the rest of its layer and `zOrder`, ordered by world y, so whatever stands lower on screen is drawn in front.

## Batching and culling

Sprites batch on their own: consecutive sprites from one image, drawn at one uniform positive scale, go into a single `Canvas.drawRawAtlas` call. A mirrored or stretched sprite draws by itself, and a batch is flushed whenever the draw order key changes, so batching never changes the order.

`RenderSystem` has two more switches, both off by default. Set them on the default one, for example `engine.world.getSystem<RenderSystem>()?.batchShapes = true`:

- `batchShapes` draws runs of rectangles with square corners and circles in one `Canvas.drawVertices` call, when their fill and outline are plain colours and the entity is fully opaque, untinted and has no shader. Edges are not anti-aliased and a circle becomes a 16- or 24-sided polygon, so use it for many small shapes: bullets, debris, blockouts.
- `cullOffscreen` skips renderables whose bounds lie wholly outside the view. Level-map layers and particle emitters are always drawn, and it is only as good as each renderable's `getBounds`.

For large levels, `ViewCullingSystem` also stops simulating what is far away. Add it yourself with `world.addSystem(ViewCullingSystem(camera: engine.cameraSystem.mainCamera))`; only entities you give a `CullStateComponent` take part, so don't give one to the player. Outside the render area (1.2 times the view by default) an entity's renderable is hidden. Outside the active area (2 times the view) its `CullStateComponent.isActive` turns false and `MovementSystem` and `PhysicsSystem` skip it; check the same flag in your own systems, such as AI. A `hysteresisMargin` (24 units) stops entities on the edge from flickering.

## Drawing your own things

There are three ways in, depending on where the drawing belongs:

- In the world, sorted with everything else: put a `RenderableComponent(renderable: CustomRenderable(onRender: ...))` on an entity. `onRender` draws in the entity's own space, and `getBoundsCallback` gives the bounds that culling uses. `TextRenderable` draws a line of text the same way.
- On the screen: add a callback to `engine.rendering.overlayHooks` (over the world) or `backgroundHooks` (behind it). These `RenderHookChain`s run in screen space, outside the camera transform, in ascending `order`. `GameWidget` adds the world's own drawing at order 0 and the engine adds plugin overlays at 100. `remove` takes a hook out, and `addIfAbsent` never adds one twice.
- After the renderables, in world space: give `RenderSystem` extra `passes`. A `RenderPass` runs inside the camera transform, in ascending `order`. The default list is one `ComponentPainterPass` (order 100), which draws components whose definition has a painter, such as `just_ui_editor`'s world-space text; keep it in your own list.

The default `RenderSystem` is made during `initialize()`, so a game that wants custom passes leaves rendering out of the default set and adds its own:

```dart lib/axes.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Draws the world's x and y axes, inside the camera transform.
class AxesPass extends RenderPass {
  final Paint _paint = Paint()..color = const Color(0x55FFFFFF);

  // Before ComponentPainterPass, which runs at 100.
  @override
  int get order => 50;

  @override
  void render(Canvas canvas, RenderContext context, RenderPassFilter filter) {
    final view = context.camera?.getVisibleBounds();
    if (view == null) return;
    canvas
      ..drawLine(Offset(view.left, 0), Offset(view.right, 0), _paint)
      ..drawLine(Offset(0, view.top), Offset(0, view.bottom), _paint);
  }
}

Future<Engine> startWithAxes() async {
  final engine = Engine(
    config: EngineConfig(
      // Everything but rendering, which this game sets up itself.
      defaultSystems: DefaultSystems.all.difference({DefaultSystem.rendering}),
    ),
  );
  await engine.initialize();
  engine.world.addSystem(
    RenderSystem(
      camera: engine.cameraSystem.mainCamera,
      statsSink: engine.rendering,
      passes: [ComponentPainterPass(), AxesPass()],
    ),
  );
  // Adds ParallaxRenderSystem; the RenderSystem above is kept.
  registerDefaultSystems(
    engine.world,
    engine,
    include: {DefaultSystem.rendering},
  );

  // A crosshair in screen space, over the world (order 0).
  engine.rendering.overlayHooks.add((canvas, size) {
    final c = size.center(Offset.zero);
    final paint = Paint()..color = Colors.white;
    canvas
      ..drawLine(c - const Offset(8, 0), c + const Offset(8, 0), paint)
      ..drawLine(c - const Offset(0, 8), c + const Offset(0, 8), paint);
  }, order: 50);
  return engine;
}
```

## Parallax backgrounds

A `ParallaxComponent` holds a `ParallaxBackground`: a list of `ParallaxLayer`s from back to front. `ParallaxRenderSystem` scrolls it against the camera and draws it in screen space, behind the world. Several backgrounds are ordered by their entity's `LayerComponent`.

Each layer takes a decoded image. `scrollFactorX` and `scrollFactorY` say how far it moves with the camera, from 0 (fixed, like a sky) to 1 (with the world), 0.5 by default; `ParallaxLayer.uniform` takes one `scrollFactor` for both. `velocityX` and `velocityY` auto-scroll it in pixels per second, for drifting clouds, and it also takes a `scale`, `offset`, `opacity`, `tint`, and `repeat` (tile to fill the view, on by default). Parallax backgrounds are not saved in scenes, so add them in code:

```dart
import 'package:just_game_engine/just_game_engine.dart';

Future<void> addBackground(Engine engine) async {
  final assets = engine.assets;
  final sky = (await assets.loadImage('assets/backgrounds/sky.png')).image!;
  final hills = (await assets.loadImage('assets/backgrounds/hills.png')).image!;
  engine.world.createEntityWithComponents([
    ParallaxComponent(
      background: ParallaxBackground(
        layers: [
          ParallaxLayer(image: sky, scrollFactorX: 0, scrollFactorY: 0),
          ParallaxLayer(image: hills, scrollFactorX: 0.3, scrollFactorY: 0.1),
        ],
      ),
    ),
  ], name: 'Background');
}
```

## Render stats

- `engine.rendering.stats` describes the whole last frame: `lastRenderMs`, `drawCalls`, `renderedObjects`, `culledObjects`, `batchedSprites` and `postProcessPasses`. The default `RenderSystem` reports into it; one you make yourself counts only if you pass `statsSink: engine.rendering`.
- `engine.world.getSystem<RenderSystem>()?.stats` holds `drawCalls`, `renderedObjects`, `culledObjects` and `batchedSprites` for the world alone, without the extra passes' drawing. In tests, `RenderSystem.debugDrawOrder()` lists the draw order.
- [Debugging](/docs/debugging) covers the on-screen tools.

## The deprecated legacy path

Adding renderables to the rendering engine directly, as 1.x games did, still works in 2.0 but is deprecated and will be removed in 3.0:

| Deprecated | Use instead |
|---|---|
| `engine.rendering.addRenderable`, `removeRenderable`, `useSpatialIndex` and the other spatial-index members | An entity with a `RenderableComponent`; `cullOffscreen` for culling |
| `addManagedEmitter`, `removeManagedEmitter`, `updateManagedEmitters` | `ParticleEmitterComponent` with `ParticleSystemECS` |
| `engine.parallax`, `ParallaxSystem` | `ParallaxComponent` and `ParallaxRenderSystem` |
| `onRenderOverlay`, `onRenderBackground` | `overlayHooks`, `backgroundHooks` |

> **Warning:** `RenderSystem` now draws particle emitters itself, and `GameWidget` always draws the world. Remove `addManagedEmitter` calls for emitters that are also on entities, and any `engine.world.render` call from your own overlay hook, or they draw twice.
''',
  ),
  DocPage(
    id: 'sprites',
    title: 'Sprites & animation',
    group: DocGroups.graphics,
    summary:
        'Show images and atlas regions, play clips from TexturePacker and '
        'Aseprite atlases, and let animator graphs pick the clip for you.',
    keywords: [
      'SpriteComponent',
      'SpriteAnimationComponent',
      'SpriteAtlas',
      'AtlasParser',
      'AtlasAnimationClip',
      'AtlasFrame',
      'AnimatorComponent',
      'AnimatorGraph',
      'AnimatorBindings',
      'AnimatorBlendTree',
      'AnimatorSystem',
      'SpriteAnimationSystem',
      'SpriteLoadSystem',
      'SpriteAnimationSignal',
      'SpriteBatch',
      'EasingFunction',
      'Easings',
      'EasingType',
      'Aseprite',
      'TexturePacker',
      'state machine',
      'blend tree',
    ],
    body: r'''
Three components put 2D art on screen. `SpriteComponent` shows a still image or one region of an atlas. `SpriteAnimationComponent` plays clips from an atlas. `AnimatorComponent` runs an animator graph: a state machine that picks the clip from the entity's own state, so your game needs no animation code.

The systems behind them come with `DefaultSystem.sprites` (`SpriteLoadSystem`, `AnimatorSystem` and `SpriteAnimationSystem`, plus the timeline systems), or add them to any world with `registerSpriteSystems(world)`. Images, atlases and graphs are read through the asset bundle, so list their folders under `flutter: assets:` in `pubspec.yaml` (see [Assets](/docs/assets)).

## Showing an image

`SpriteComponent(spritePath: ...)` shows a whole image, centred on its entity. To show one frame of an atlas instead, set `atlasPath` and `region`; an empty `region` shows the atlas's first. It also takes `flipX`, `flipY` and a `tint`, and `pixelArt: true` samples without smoothing so scaled pixels stay square. That is off by default for `SpriteComponent` and on for `SpriteAnimationComponent`.

Sprites are renderables: order them with a `LayerComponent` like shapes (see [Rendering & layers](/docs/rendering)), and fade or tint them with effects.

## Atlases

An atlas is the JSON a sprite tool exports beside its sheet. The engine recognises the format from the file itself (`AtlasParser.detect`), so you never name it:

| Format | Recognised by | Clips |
|---|---|---|
| Aseprite JSON, hash or array | `meta.app` contains `aseprite` | One per `frameTags` entry |
| TexturePacker JSON array or hash | `frames` is a list or an object | None in the file; register them in code |
| TexturePacker multi-page | A top-level `textures` list | None in the file |

The image path inside the JSON is relative to the JSON file. Aseprite tags play `forward`, `reverse` or `pingpong`, each frame for its own `duration` (milliseconds in the file, seconds in the engine), and loop by default. Trimmed and rotated frames are drawn where and how they belong.

To work with an atlas in code, load it with `SpriteAtlas.fromAsset(path, assets: engine.assets)`. The asset manager caches it, so you get the same atlas the sprite systems use. It lists `regionNames` and `clipNames`, finds them with `getRegion` and `getClip`, and takes extra clips with `registerClip`: an `AtlasAnimationClip` of `AtlasFrame`s, with durations in seconds.

## Playing clips

`SpriteAnimationComponent(atlasPath: ..., clip: 'run')` plays one clip at its authored timing. An empty `clip`, or a name the atlas lacks, plays every region in order, a tenth of a second each.

- `speed`: 1 is as authored, 0 holds the frame, and a negative speed plays backwards.
- `play()`, `pause()`, `stop()` (back to the first frame) and `restart()` control it; `playOnStart: false` waits for `play()`.
- `switchClip('idle')` changes clip and starts it from its first frame. Asking for the clip already playing does nothing unless you pass `restartIfSame: true`, and `loop:` overrides the clip's own looping.
- `isPlaying`, `frameIndex` and `isComplete` say where it is.

`SpriteAnimationSystem.signals` streams `SpriteAnimationSignal`s: the frame events an atlas carries (in its `meta.just` block), and `SpriteAnimationSignal.completed` when a clip that does not loop ends.

## Animator graphs

An `.animator.json` file holds parameters, states and transitions. Put an `AnimatorComponent(graphPath: ...)` beside a `SpriteAnimationComponent` and the graph decides which clip plays. `faceVelocity: true` also flips the sprite to face the way the entity moves, keeping the last direction while it stands still.

```dart lib/hero.dart
import 'package:just_game_engine/just_game_engine.dart';

void addSprites(Engine engine) {
  // `grounded` is not a built-in binding, so teach it to this engine.
  engine.context.animatorBindings.register(
    'grounded',
    (entity) => entity.getComponent<RigidBody2D>()?.isGrounded,
  );

  final world = engine.world;

  // A whole image.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-200, 150, 0)),
    SpriteComponent(spritePath: 'assets/sprites/crate.png'),
  ], name: 'Crate');

  // One region of an atlas: the frame called "hero 0".
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-100, 150, 0)),
    SpriteComponent(
      spritePath: '',
      atlasPath: 'assets/sprites/hero.json',
      region: 'hero 0',
      pixelArt: true,
    ),
  ], name: 'Statue');

  // Animated: the graph picks the clip.
  world.createEntityWithComponents([
    TransformComponent(),
    VelocityComponent(),
    SpriteAnimationComponent(atlasPath: 'assets/sprites/hero.json'),
    AnimatorComponent(
      graphPath: 'assets/sprites/hero.animator.json',
      faceVelocity: true,
    ),
    RigidBody2D(friction: 0, lockRotation: true),
    Collider2D(size: Vector2(28, 32)),
    LayerComponent(zOrder: 10),
  ], name: 'Hero');
}
```

The graph for that hero, assuming its atlas has `idle`, `walk`, `run`, `jump`, `fall` and `attack` tags:

```json assets/sprites/hero.animator.json
{
  "version": 2,
  "atlas": "assets/sprites/hero.json",
  "entry": "idle",
  "parameters": [
    { "name": "speed", "type": "float", "binding": "speedX" },
    { "name": "vy", "type": "float", "binding": "velocityY" },
    { "name": "grounded", "type": "bool", "binding": "grounded" },
    { "name": "attack", "type": "trigger" }
  ],
  "states": [
    { "name": "idle" },
    {
      "name": "move",
      "blend": {
        "type": "1d",
        "parameter": "speed",
        "motions": [
          { "clip": "walk", "threshold": 60 },
          { "clip": "run", "threshold": 240 }
        ]
      }
    },
    { "name": "jump" },
    { "name": "fall" },
    { "name": "attack", "loop": false }
  ],
  "transitions": [
    { "from": "idle", "to": "move", "conditions": [{ "param": "speed", "op": ">", "value": 20 }] },
    { "from": "move", "to": "idle", "conditions": [{ "param": "speed", "op": "<=", "value": 20 }] },
    {
      "from": "*",
      "to": "jump",
      "conditions": [
        { "param": "grounded", "op": "==", "value": false },
        { "param": "vy", "op": "<", "value": 0 }
      ]
    },
    { "from": "jump", "to": "fall", "conditions": [{ "param": "vy", "op": ">=", "value": 0 }] },
    { "from": "fall", "to": "idle", "conditions": [{ "param": "grounded", "op": "==", "value": true }] },
    { "from": "*", "to": "attack", "priority": 1, "conditions": [{ "param": "attack" }] },
    { "from": "attack", "to": "idle", "hasExitTime": true, "exitTime": 1.0 }
  ]
}
```

How it reads:

- Parameters are `float` (the default), `int`, `bool` or `trigger`, with an optional `default`. A `binding` fills one from the entity every frame. The built-in bindings are `velocityX`, `velocityY`, `speed`, `speedX`, `speedY`, `health`, `healthFraction` and `alive`; register more with `engine.context.animatorBindings.register`. A binding nobody registered silently leaves its parameter at the default.
- A state plays the clip of its own name unless it sets `clip`. It can also set `speed`, `loop`, and `timeline`: a `.timeline.json` the entity's `TimelinePlayerComponent` plays from the start on entering the state (see [Timelines](/docs/timelines)).
- A transition fires when all its `conditions` hold. A condition compares a `param` with a `value` by `op` (`>`, `>=`, `<`, `<=`, `==` or `!=`). A trigger condition holds while the trigger is set, and the transition that takes it switches it off again. `"from": "*"` leaves any state, and `hasExitTime` with an `exitTime` from 0 to 1 waits until the clip has played that far.
- Transitions from any state are tried first, then the current state's own, highest `priority` first.
- Set parameters that have no binding from your code with `setFloat`, `setInt`, `setBool`, `setTrigger` and `resetTrigger` on the `AnimatorComponent`. `currentState` and `stateTime` say where it is, and `AnimatorSystem.stateChanges` streams every change.

## Blend trees and crossfades

A state with a `blend` object plays several clips weighted by parameters instead of one: a `"1d"` tree places `motions` at a `threshold` along one `parameter`, and a `"2d"` tree places them at `x` and `y` over `parameter` and `parameterY`. A transition's `duration` crossfades between states. Both need `"version": 2` in the file.

A sprite can't blend two frames, so on a sprite a blend tree plays its heaviest motion (in the graph above, `walk` up to a speed of 150 and `run` beyond it) and transitions always cut. On a 3D model with an `AnimationPlayerComponent`, blend trees and crossfades really blend; see [3D graphics](/docs/graphics-3d).

## Clips and events in code

```dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_game_engine/just_game_engine.dart';

/// The graph's attack state takes it from here.
void attack(Entity hero) =>
    hero.getComponent<AnimatorComponent>()?.setTrigger('attack');

Future<void> watchAnimation(Engine engine) async {
  // The atlas the sprite systems use: the asset manager caches it.
  final atlas = await SpriteAtlas.fromAsset(
    'assets/sprites/hero.json',
    assets: engine.assets,
  );
  debugPrint('clips: ${atlas.clipNames.join(', ')}');

  // A clip the file does not have, made from its regions.
  atlas.registerClip(
    const AtlasAnimationClip(
      name: 'taunt',
      frames: [
        AtlasFrame(regionName: 'hero 0', duration: 0.2),
        AtlasFrame(regionName: 'hero 4', duration: 0.4),
      ],
      loop: false,
    ),
  );

  final world = engine.world;
  world.getSystem<AnimatorSystem>()?.stateChanges.listen((change) {
    debugPrint('${change.entity.name}: ${change.from} -> ${change.to}');
  });
  world.getSystem<SpriteAnimationSystem>()?.signals.listen((signal) {
    if (signal.name == SpriteAnimationSignal.completed) {
      debugPrint('${signal.entity.name} finished ${signal.clip}');
    }
  });
}
```

## Batching many sprites

`RenderSystem` already batches sprites for you (see [Rendering & layers](/docs/rendering)). When you draw many sprites yourself, for example from a `CustomRenderable`, use a `SpriteBatch`. Make one for an image, `add` each sprite with its `sourceRect` and `position` (and optionally `rotation`, `scale` and a `color`), then `flush(canvas)` draws them all in one `Canvas.drawRawAtlas` call and empties the batch. Its `filterQuality` is `FilterQuality.none` by default, which keeps pixel art crisp.

## Easing

An `EasingFunction` is `double Function(double t)`: progress from 0 to 1 in, eased progress out. The engine's curves are static functions on `Easings`: `linear`; the `easeIn`, `easeOut` and `easeInOut` versions of `Quad`, `Cubic`, `Quart`, `Sine` and `Expo`; and `easeInElastic`, `easeOutElastic`, `easeInBounce` and `easeOutBounce`.

The same curves are named in two other places:

- Effects take an `EasingType`, such as `EasingType.easeOutCubic`, and `type.transform(t)` evaluates one. It names every curve except the quartic ones and `easeInOutExpo`.
- Timeline keys name a curve in `"e"`, looked up in `engine.context.easings`: the `EasingType` names except `easeInSine` and `easeOutSine`. Add your own with `engine.context.easings.register('name', curve)`.

Coming from 1.x: the top-level `easeInQuad` and friends are now `Easings.easeInQuad`, and `typedef Easing` is now `EasingFunction`.
''',
  ),
  DocPage(
    id: 'timelines',
    title: 'Timelines',
    group: DocGroups.graphics,
    summary:
        'Animate any component field over time, and play clips, cut cameras, '
        'switch entities, play sounds and fire events from one asset.',
    keywords: [
      'TimelineAsset',
      'TimelinePlayerComponent',
      'TimelineTriggerComponent',
      'TimelineSystem',
      'TimelineTriggerSystem',
      'TimelineTriggerAction',
      'TimelineWrapChoice',
      'PropertyTrack',
      'EventTrack',
      'SpriteClipTrack',
      'CameraShotTrack',
      'AudioTrack',
      'ActivationTrack',
      'NestedTimelineTrack',
      'SkeletalClipTrack',
      'TimelineSignals',
      'TimelineEventFired',
      'KeyCurve',
      'TimelineKey',
      'cut-scene',
      'keyframes',
    ],
    body: r'''
A timeline animates component fields over time, and can also play sprite clips, cut between cameras, switch entities on and off, play sounds and fire events, all on one clock. Use one for a bobbing coin, a door, a moving platform or a whole cut-scene.

Timelines are assets: a `.timeline.json` file (format 2), or a `TimelineAsset` stored inline in the component that plays it. The editor's Timeline dock authors them, with a dope sheet, a curve editor, record mode and motion paths drawn in the level (see [The editor](/docs/editor)). The files are plain JSON, so you can also write them by hand or build them in code.

`TimelineSystem` plays them and `TimelineTriggerSystem` starts them from trigger areas. Both come with `DefaultSystem.sprites`.

## A timeline file

This one slides its entity 96 units up in one second and fires `opened` at the end:

```json assets/timelines/door_open.timeline.json
{
  "formatVersion": 2,
  "name": "door_open",
  "duration": 1.0,
  "wrap": "once",
  "tracks": [
    {
      "kind": "property",
      "component": "TransformComponent",
      "field": "position",
      "channel": "y",
      "mode": "relative",
      "keys": [
        { "t": 0.0, "v": 0.0, "i": "eased", "e": "easeInOutCubic" },
        { "t": 1.0, "v": -96.0 }
      ]
    },
    {
      "kind": "event",
      "events": [{ "time": 1.0, "name": "opened" }]
    }
  ]
}
```

- `duration` is in seconds, and `wrap` is `once`, `loop` or `pingPong`. `fps` only sets how the editor snaps time. Optional `markers` (`{ "time": 3.0, "name": "skip" }`) are named places to play from.
- A property track keys one field of one component: any field the component's definition saves, a package's own components included. `channel` picks one number of a vector (`x`, `y`, `z`) or an offset (`dx`, `dy`).
- `"mode": "relative"` makes the keys offsets from the value the field had when the timeline started, so one asset opens every door wherever it stands. Only numbers can be relative.
- A key has a time `t` and a value `v`. Without `i` it reaches the next key along a bezier, which is a straight line until you give it `in` and `out` handles. `"i": "linear"` is a straight line, `"i": "step"` holds, and `"i": "eased"` follows the easing named in `e` (see Easing on [Sprites & animation](/docs/sprites)).
- A track acts on the entity playing the timeline unless it has a `binding`, such as `{ "name": "Door" }` or `{ "tag": "enemy" }`.

## Track kinds

| `kind` | Track | What it does |
|---|---|---|
| `property` | `PropertyTrack` | Keys one field of one component |
| `event` | `EventTrack` | Fires named `events`, each with an optional `payload`, whenever play crosses them in either direction |
| `spriteClip` | `SpriteClipTrack` | Plays the block's clip on the bound `SpriteAnimationComponent`; between blocks the sprite goes back to its own clip |
| `cameraShot` | `CameraShotTrack` | Raises the priority of the virtual camera the block names by its `amount`, rounded to a whole number, while the block lasts (the editor starts new shots at 100) |
| `audio` | `AudioTrack` | Plays the file the block names, at `amount` volume, when time passes the block's start going forwards |
| `activation` | `ActivationTrack` | The bound entity is active inside the blocks and inactive outside them |
| `nested` | `NestedTimelineTrack` | Runs the timeline the block names inside this one |
| `skeletalClip` | `SkeletalClipTrack` | With `Graphics3D` only: plays clips on a 3D model's `AnimationPlayerComponent` |

All but the first two are block tracks: a list of `blocks`, each with a `start` and `length` in seconds, a `value`, and optional `speed`, `amount` and `loop`. A cut-scene:

```json assets/timelines/boss_intro.timeline.json
{
  "formatVersion": 2,
  "name": "boss_intro",
  "duration": 6.0,
  "wrap": "once",
  "tracks": [
    {
      "kind": "cameraShot",
      "blocks": [{ "start": 0.0, "length": 3.0, "value": "BossCam", "amount": 100 }]
    },
    {
      "kind": "spriteClip",
      "binding": { "name": "Boss" },
      "blocks": [{ "start": 1.0, "length": 2.0, "value": "roar" }]
    },
    {
      "kind": "audio",
      "blocks": [{ "start": 1.0, "value": "assets/audio/roar.ogg", "amount": 0.8 }]
    },
    {
      "kind": "activation",
      "binding": { "name": "BossHealthBar" },
      "blocks": [{ "start": 3.0, "length": 3.0 }]
    },
    {
      "kind": "event",
      "events": [{ "time": 6.0, "name": "fight", "signal": true }]
    }
  ],
  "markers": [{ "time": 3.0, "name": "skip" }]
}
```

> **Note:** Blocks that run to the very end of a `once` timeline hold there: a camera shot keeps its camera until the player stops, and activation and sprite-clip blocks keep their state. End a shot block before the timeline ends to hand the camera back, as `boss_intro` does.

## Playing from code

A `TimelinePlayerComponent` plays one timeline on its entity: the asset at `timelinePath`, or the `inline` one when the path is empty. Tracks without a binding act on that entity, so one asset can animate many.

```dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_game_engine/just_game_engine.dart';

void addDoor(Engine engine) {
  final world = engine.world;

  // Plays when a player walks into the 200 x 200 area round the door,
  // and plays backwards when they leave.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(500, 250, 0)),
    RectangleComponent(width: 40, height: 96),
    TimelinePlayerComponent(
      timelinePath: 'assets/timelines/door_open.timeline.json',
    ),
    TimelineTriggerComponent(
      width: 200,
      height: 200,
      onEnter: TimelineTriggerAction.play,
      onExit: TimelineTriggerAction.reverse,
    ),
  ], name: 'Door');

  // Events from every timeline in the world.
  world.getSystem<TimelineSystem>()?.events.listen((event) {
    debugPrint('${event.owner.name}: ${event.name}');
  });
}

/// Restarts every timeline player whose `listenSignal` is "alarm".
void soundTheAlarm(Engine engine) => engine.context.signals.emit('alarm');
```

The player's controls work even before the timeline has loaded: the last one asked is done when it arrives.

- `play()` carries on from where it is, `restart()` plays from the start, `reverse()` plays backwards and `forwards()` forwards again. `pause()` holds, `stop()` rewinds, `seek(t)` jumps without firing the events in between, `playFrom('skip')` starts at a marker, and `playTimeline(path)` swaps in another asset.
- `playOnStart: true` plays at once. `speed` scales time, and a negative speed plays backwards.
- `wrap` overrides the asset's own: `TimelineWrapChoice.once`, `loop`, `pingPong` or `fromTimeline` (the default).
- `from` and `to` play only part of the timeline, in seconds, so one asset can serve several entities differently.
- `isPlaying`, `isFinished`, `time` and `progress` say where it is.

A `TimelineTriggerComponent` drives a player when a target walks into its rectangle, centred on its entity (128 by 128 by default; the entity's scale and rotation are ignored). It is set off by entities tagged `player` unless you give it another `target`, and drives its own entity's player unless `playerName` names another. `onEnter` (`restart` by default) and `onExit` (`nothing` by default) take a `TimelineTriggerAction`: `play`, `restart`, `reverse`, `pause`, `stop` or `nothing`. `oneShot: true` fires once.

## Events and signals

`world.getSystem<TimelineSystem>()?.events` streams a `TimelineEventFired` (its `owner`, `name` and `payload`) for every event any timeline fires.

`engine.context.signals.emit('alarm')` restarts every player whose `listenSignal` is `alarm`. Signals are shared by every world on the engine, so a button on a UI screen can start a timeline in the level. An event with `"signal": true`, like `fight` above, is sent as a signal too, which is how one timeline sets off another.

## Timelines in code

A `TimelineAsset` can also be built in code and given to a player as `inline`:

```dart
import 'package:just_game_engine/just_game_engine.dart';

/// A coin that bobs 12 units up and down for ever.
Entity addCoin(World world, Vector3 at) {
  final bob = TimelineAsset(
    name: 'coin_bob',
    duration: 1.0,
    wrap: TimelineWrap.pingPong,
    tracks: [
      PropertyTrack(
        component: 'TransformComponent',
        field: 'position',
        channel: 'y',
        mode: PropertyTrackMode.relative,
        curve: KeyCurve(const [
          TimelineKey(
            time: 0,
            value: 0,
            interpolation: KeyInterpolation.eased,
            easing: 'easeInOutSine',
          ),
          TimelineKey(time: 1, value: -12),
        ]),
      ),
    ],
  );
  return world.createEntityWithComponents([
    TransformComponent(position: at),
    CircleComponent(radius: 10),
    TimelinePlayerComponent(inline: bob, playOnStart: true),
  ], name: 'Coin');
}
```

`TimelineAsset.parse(text)` reads a file's text, and `encode()` writes one. A package can add its own track kinds to `engine.context.trackKinds`; a track of a kind the engine doesn't know is kept and saved back unchanged.
''',
  ),
  DocPage(
    id: 'cameras',
    title: 'Cameras',
    group: DocGroups.graphics,
    summary:
        'Describe shots with virtual cameras and let the camera brain pick, '
        'blend, frame, confine and shake them, in 2D and 3D.',
    keywords: [
      'CameraSystem',
      'Camera',
      'CameraBrain',
      'VirtualCameraComponent',
      'CameraFramingComponent',
      'CameraConfinerComponent',
      'CameraBoundsComponent',
      'CameraNoiseComponent',
      'CameraImpulse',
      'CameraImpulseListenerComponent',
      'CameraImpulseSourceComponent',
      'CameraTargetGroupComponent',
      'CameraGroupFramingComponent',
      'CameraTriggerComponent',
      'CameraDollyComponent',
      'CameraStateDrivenComponent',
      'CameraBlendListComponent',
      'CameraMixerComponent',
      'CameraBlend',
      'CameraBlendRule',
      'OrbitFollowComponent',
      'FirstPersonComponent',
      'LookAtComponent',
      'registerCameraSystems',
      'camera shake',
      'dead zone',
    ],
    body: r'''
`engine.cameraSystem.mainCamera` is the camera the world is drawn through. You can move it yourself, but most games describe shots instead: entities with a `VirtualCameraComponent`. Each frame the camera brain (`engine.cameraSystem.brain`) picks the enabled shot with the highest priority, blends to it, and writes the result into the main camera.

## Moving the main camera yourself

With no virtual camera in the world, the brain leaves the main camera alone and it is yours to move:

```dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/painting.dart' show Offset;
import 'package:just_game_engine/just_game_engine.dart';

void lookAround(Engine engine, Offset tap) {
  final camera = engine.cameraSystem.mainCamera;
  camera
    ..lookAt(const Offset(400, 300))
    ..zoom = 2.0;

  // Where a tap on the screen lands in the world, and back.
  final world = camera.screenToWorld(tap);
  final screen = camera.worldToScreen(world);
  debugPrint('$world is at $screen; in view: ${camera.getVisibleBounds()}');
}
```

`position` is the world point at the centre of the screen. At `zoom` 1 a world unit is one pixel, and larger is closer; `setZoom` keeps it between `minZoom` and `maxZoom`. `rotation` rolls the view, and `moveBy`, `zoomBy` and `zoomToPoint` help with panning and zooming. Moves are immediate: smoothing belongs to shots. `GameCameraControls` in `widgets.dart` adds wheel, pinch and button zoom (see [Game widget](/docs/game-widget)).

## Shots and the camera brain

A shot is an entity with a `VirtualCameraComponent`:

- `priority`: 10 by default. Higher wins; between equals, the one activated most recently (`brain.activate(entity)`).
- `follow`: an `EntityTarget` by tag or name, looked up every frame, so a camera authored in a level finds a player spawned later.
- `zoom`, `dutch` (extra roll, in radians) and `enabled`.
- `standbyUpdate`: `CameraStandbyUpdate.always` keeps a shot settled on its target while it isn't live, instead of snapping when it goes live.

Other components on the same entity shape the shot, as the rest of this page shows. `DefaultSystem.cameras` adds the systems: `CameraTargetGroupSystem` (priority 47), `CameraTriggerSystem` (46) and `CameraBrainSystem` (45), which runs after everything has moved and before rendering, so a shot frames where its target is. Without the default set, call `registerCameraSystems(world, engine.cameraSystem)` once. When you replace a level's entities, call `engine.cameraSystem.brain.reset()` to forget the old cameras.

Blends: `brain.defaultBlend` is a `CameraBlend`, half a second with an ease-in-out `curve` unless you say otherwise, and `CameraBlend.cut` switches at once. `brain.blendTable.rules` holds `CameraBlendRule`s for pairs of cameras by entity name, with `CameraBlendRule.any` (`*`) matching any; the most specific rule wins. `brain.liveCamera` is the live shot, and `brain.onCameraActivated` hears every change.

```dart lib/cameras.dart
import 'package:flutter/painting.dart' show Offset;
import 'package:just_game_engine/just_game_engine.dart';

void addCameras(Engine engine) {
  final world = engine.world;

  // Follows whoever is tagged "player", so it keeps working after a
  // respawn makes a new player entity.
  world.createEntityWithComponents([
    TransformComponent(),
    VirtualCameraComponent(follow: const EntityTarget.tag('player'), zoom: 1.5),
    CameraFramingComponent(
      screenY: 0.1, // the target sits a little below the middle
      deadZoneWidth: 0.15,
      dampingX: 0.3,
      lookaheadTime: 0.25,
    ),
    CameraConfinerComponent(boundsName: 'LevelBounds'),
    CameraImpulseListenerComponent(),
  ], name: 'FollowCam');

  // The view never shows anything outside this rectangle.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(2000, 400, 0)),
    CameraBoundsComponent(width: 4000, height: 800),
  ], name: 'LevelBounds');

  // A fixed shot of the boss room. Its trigger raises its priority from 5
  // to 25 while a player is inside, so it wins there.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(3600, 300, 0)),
    VirtualCameraComponent(priority: 5, zoom: 0.8),
    CameraTriggerComponent(
      width: 800,
      height: 600,
      mode: CameraTriggerMode.boostPriority,
      amount: 20,
    ),
  ], name: 'BossCam');

  // Blend over 0.8 s, but cut straight back when leaving the boss room.
  engine.cameraSystem.brain
    ..defaultBlend = const CameraBlend(duration: 0.8)
    ..blendTable.rules.add(
      const CameraBlendRule(from: 'BossCam', blend: CameraBlend.cut),
    );
}

/// A landing, an explosion: every listening shot near it shakes.
void thud(Engine engine, Offset where) {
  engine.cameraSystem.brain.emitImpulse(
    CameraImpulse(position: where, amplitude: 16, duration: 0.3),
  );
}
```

## Framing the target

`CameraFramingComponent` keeps the followed target where you want it on screen. Everything is in screen fractions, so a shot reads the same at any zoom and window size:

- `screenX`, `screenY`: where the target sits, from the centre. -0.5 is the left or top edge and 0.5 the right or bottom. A platformer often wants a small positive `screenY`.
- `deadZoneWidth`, `deadZoneHeight` (0.1): the target moves freely inside this without the camera moving.
- `softZoneWidth`, `softZoneHeight` (0.8): the target never leaves this, however heavy the damping.
- `dampingX`, `dampingY` (0.5): seconds for the camera to close 99% of the gap; 0 is rigid.
- `lookaheadTime`: looks this many seconds ahead along the target's velocity (0, off), with `lookaheadSmoothing` (0.3 s) calming changes of direction.
- `followX`, `followY`: turn one off to hold that axis at the camera entity's own position, for a room that scrolls only sideways.

## Keeping the view inside the level

Put a `CameraBoundsComponent` (a `width` by `height` rectangle centred on its entity) on an entity of its own, and a `CameraConfinerComponent(boundsName: ...)` on the shot. The confiner keeps the whole view inside the bounds, not just its centre; where the bounds are narrower than the view, it centres on them. Its `damping` (0, a hard wall) softens the edge. Any component that implements `CameraBoundsSource` can serve as bounds.

## Shake: noise and impulses

- `CameraNoiseComponent` adds continuous handheld motion from a `CameraNoisePreset`: `handheldMild`, `handheldNormal` (the default), `handheldStrong` or `shake`, scaled by `amplitudeGain` and `frequencyGain`.
- Impulses replace 1.x's `camera.shake`. Give shots a `CameraImpulseListenerComponent` (`gain`, and a `channels` bit mask), then call `brain.emitImpulse(CameraImpulse(position: ...))` when something happens. Every listening shot reacts by its distance; a `radius` above 0 limits the reach. The same impulses in the same order shake the same way on every run.
- A `CameraImpulseSourceComponent` stores an authored impulse on an entity, and `brain.emitImpulseFrom(entity)` sends it from wherever that entity is.

## Groups, triggers and rails

- Target groups: a `CameraTargetGroupComponent` moves its own entity to the weighted centre of its `members` (each a `CameraGroupMember` with a `target`, `weight` and `radius`; one member tagged `player` covers every player). Follow that entity by name, and add a `CameraGroupFramingComponent` (`padding`, `minZoom`, `maxZoom`, `zoomDamping`) to zoom out as the group spreads.
- Trigger areas: a `CameraTriggerComponent` (640 by 360 by default, centred on its entity) switches a camera while a target is inside. `CameraTriggerMode.enableWhileInside`, the default, makes a shot exist only inside; `boostPriority` adds `amount` to its priority. It drives the camera on its own entity unless `cameraName` names another, and is set off by the `player` tag unless `target` says otherwise.
- Dolly path: a `CameraDollyComponent` rides the shot along `waypoints` in world space (`closed` joins the ends). With `autoDolly` on, the default, it goes to the point nearest the followed entity; turn it off and animate `pathPosition` (0 to 1 along the track) for a scripted move.

## Cameras made of cameras

A manager is a virtual camera whose shot comes from its child entities' virtual cameras, the children being parented to it with `ParentComponent`. The children are not candidates on their own: the brain sees only the manager, at the manager's priority.

- `CameraStateDrivenComponent` shows the child mapped to the `CameraStateComponent.state` of a `source` entity (the first tagged `player` by default).
- `CameraBlendListComponent` plays its children as a sequence of `CameraBlendStep`s (`child`, `hold`, `blend`): a cut-scene. It starts over each time it goes live, so raise its priority to start one and lower it to end it.
- `CameraMixerComponent` shows a weighted mix of its children by name; animate its `weights` to steer between shots.

```dart
import 'package:just_game_engine/just_game_engine.dart';

void addPlayerRig(World world, Entity player) {
  final rig = world.createEntityWithComponents([
    TransformComponent(),
    VirtualCameraComponent(priority: 20),
    CameraStateDrivenComponent(
      states: {'grounded': 'NearCam', 'falling': 'WideCam'},
      defaultChild: 'NearCam',
      blend: 0.4,
    ),
  ], name: 'PlayerRig');

  // The children are ordinary virtual cameras under the rig.
  world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: rig.id),
    VirtualCameraComponent(follow: const EntityTarget.tag('player'), zoom: 1.5),
    CameraFramingComponent(),
  ], name: 'NearCam');
  world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: rig.id),
    VirtualCameraComponent(follow: const EntityTarget.tag('player'), zoom: 0.8),
    CameraFramingComponent(screenY: -0.2),
  ], name: 'WideCam');

  // The game writes the state; the rig shows the matching child.
  player.addComponent(CameraStateComponent(state: 'grounded'));
}
```

A timeline can also take the shot for a while with a `cameraShot` track (see [Timelines](/docs/timelines)).

## 3D rigs

A shot with `projection: CameraProjection.perspective` sees in perspective, with a `fieldOfView` (in radians, 60 degrees by default), `nearClip` and `farClip`. The default `nearClip` is behind the camera, which a perspective shot replaces with 1, so set a small one for a world in metres. Three components aim a 3D shot:

- `OrbitFollowComponent`: a third-person camera circling its target at `distance` (4 m by default, kept between `minDistance` and `maxDistance`), turned by `yaw` and `pitch` within `minPitch` and `maxPitch`. A pitch below 0 looks down, since +Y is down. It circles a `pivot` (head height by default), with a sideways `shoulder` offset and `damping`.
- `FirstPersonComponent`: the camera at the target's `eye`, turned by `yaw` and `pitch`.
- `LookAtComponent`: aims at the target, raised by `offset`, wherever the rest of the shot put the camera.

Your input code turns the shot by writing `yaw` and `pitch`. For smooth motion at any frame rate, set `brain.updateMode = CameraUpdateMode.frame`: the brain then runs once per rendered frame, following targets between their fixed updates. With 3D physics, `CameraCollision3D` keeps an orbiting camera out of walls; see [3D physics](/docs/physics-3d).

```dart
import 'package:just_game_engine/just_game_engine.dart';

Entity addThirdPersonCamera(World world) => world.createEntityWithComponents([
  TransformComponent(),
  VirtualCameraComponent(
    follow: const EntityTarget.tag('player'),
    projection: CameraProjection.perspective,
    nearClip: 0.1,
    farClip: 500,
  ),
  OrbitFollowComponent(distance: 5, pitch: -0.35, shoulder: 0.5),
], name: 'ThirdPersonCam');

/// Mouse or right-stick look, in radians per unit of input.
void look(Entity camera, double dx, double dy) {
  final orbit = camera.getComponent<OrbitFollowComponent>()!;
  orbit
    ..yaw += dx * 0.005
    ..pitch += dy * 0.005;
}
```

## Screen effects

The main camera also carries screen effects, added with `mainCamera.effectManager.addEffect(...)`: `ScreenFadeEffect` (`fadeIn`, `fadeOut`, `flash`), `LetterboxEffect` (`show`, `hide`) and `MotionBlurEffect`. Fades and letterbox bars keep running on real time while the game is paused.
''',
  ),
  DocPage(
    id: 'particles',
    title: 'Particles, effects & post-processing',
    group: DocGroups.graphics,
    summary:
        'Particle emitters and presets, deterministic tick-based effects that '
        'replay and serialize, and fragment-shader passes over the frame.',
    keywords: [
      'ParticleEmitter',
      'ParticleEffects',
      'ParticleEmitterComponent',
      'ParticleSystemECS',
      'ParticleForce',
      'GravityForce',
      'WindForce',
      'DragForce',
      'SubEmitterConfig',
      'EffectSystemECS',
      'MoveEffect',
      'ScaleEffect',
      'RotateEffect',
      'FadeEffect',
      'ColorTintEffect',
      'ShakeEffect',
      'PathEffect',
      'SequenceEffect',
      'ParallelEffect',
      'DelayEffect',
      'RepeatEffect',
      'EffectSerializer',
      'PostProcessPass',
      'ShaderComponent',
      'PostProcessSystem',
      'shaders',
    ],
    body: r'''
Three tools for things that burst, move and glow: particle emitters, tick-based effects that play the same on every machine, and fragment-shader passes over the frame.

## Particle emitters

A `ParticleEmitterComponent` puts a `ParticleEmitter` on an entity. `ParticleSystemECS` (priority 48) updates every emitter, keeps it at its entity (`syncPositionFromTransform`, on by default) and, with `removeEntityWhenComplete`, destroys the entity once the emitter has finished. `RenderSystem` draws emitters in layer order, like any renderable.

`ParticleSystemECS` is not a default system, so add it once. Emitters are not saved in scenes either: add them in code.

`ParticleEffects` has ready-made emitters, each taking the `position` to start at: `explosion`, `fire`, `smoke`, `sparkle`, `rain`, `snow`, `portal`, `magic`, `bloodSplatter`, `dustKick`, `electricSparks`, `waterSplash`, `healAura`, `confetti` and `lavaEmbers`. Some take more, such as `explosion`'s `particleCount` and `color`.

```dart lib/fx.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A one-shot explosion; the entity goes when its last particle does.
void explode(World world, Vector3 at) {
  if (!world.hasSystem<ParticleSystemECS>()) {
    world.addSystem(ParticleSystemECS());
  }
  world.createEntityWithComponents([
    TransformComponent(position: at),
    ParticleEmitterComponent(
      emitter: ParticleEffects.explosion(position: at, color: Colors.amber),
      removeEntityWhenComplete: true,
    ),
  ], name: 'Explosion');
}

/// A flame on a wall torch, drawn in front of the level.
Entity addFlame(World world, Entity torch) => world.createEntityWithComponents([
  TransformComponent(),
  ParentComponent(parentId: torch.id, localPosition: Vector3(0, -40, 0)),
  ParticleEmitterComponent(
    emitter: ParticleEmitter(
      maxParticles: 120,
      emissionRate: 60,
      particleLifetime: 0.8,
      startSize: 10,
      endSize: 2,
      startColor: Colors.orange,
      endColor: Colors.red.withValues(alpha: 0),
      emissionAngle: -math.pi / 2, // up is -Y
      emissionSpread: 0.4,
      speed: 90,
      renderer: SquareParticleRenderer(),
      forces: [
        const GravityForce(Offset(0, -60)),
        WindForce(strength: 20, turbulence: 30),
        const DragForce(coefficient: 0.1),
      ],
    ),
  ),
  LayerComponent(layer: LevelLayers.foreground),
], name: 'Flame');
```

To build your own, a `ParticleEmitter` takes `maxParticles` and:

- Emission: `emissionRate` (particles per second), `duration` (seconds before it stops; null for ever), `emissionAngle` (radians from +X, so up is `-math.pi / 2`), `emissionSpread` (`math.pi * 2` emits every way), `speed` and `speedVariation`.
- Each particle: `particleLifetime`, `startSize` and `endSize`, `startColor` and `endColor`, and `angularVelocity`, with `lifetimeVariation`, `sizeVariation` and `angularVelocityVariation` for randomness.
- `renderer`: `CircleParticleRenderer` by default, or `SquareParticleRenderer`, `TriangleParticleRenderer`, `StarParticleRenderer`, `LineParticleRenderer`, `SpriteParticleRenderer`, `AnimatedSpriteParticleRenderer`, `TextParticleRenderer` or `CustomPathParticleRenderer`.
- `forces`: `GravityForce`, `WindForce`, `DragForce`, `VortexForce`, `AttractorForce`, `RepellerForce`, `NoiseForce` and `BoundaryForce`, or your own `ParticleForce`, whose `advance` runs once per update and `apply` once per particle.
- `subEmitters`: `SubEmitterConfig`s that start another emitter where a particle dies (`SubEmitterTrigger.onDeath`) or at a fraction of its life (`onLifetimeFraction`), with at most `maxInstances` alive at once.

While it runs, `burst(count)` emits at once, setting `isEmitting` to false stops new particles, `addForce` and `removeForce` change the forces, and `reset()` clears it. `isComplete` and `particleCount` say where it is.

## Deterministic effects

Effects are small animations on an entity. They count fixed steps (ticks, 60 a second) rather than seconds, so they play exactly the same on every machine and can be sent over a network. `EffectSystemECS` (priority 65) advances them one tick per update; it is not a default system, so add it once.

`scheduleEffect(entity: ..., effect: ...)` starts an effect on the next tick, or at `startTick`, and returns an `EffectHandle`. Pass that to `cancelEffect(entity, handle)` to stop the effect early.

| Effect | What it does |
|---|---|
| `MoveEffect(to: ...)` | Moves to `to`; with `from`, moves by `to` minus `from` from wherever the entity is |
| `ScaleEffect(to: ...)` | Scales uniformly |
| `RotateEffect(to: ...)` | Turns `angle`, in radians |
| `FadeEffect(to: ...)` | Fades the opacity of the entity's `RenderableComponent`, 0 to 1 |
| `ColorTintEffect(to: ...)` | Tints the entity's `RenderableComponent` |
| `ShakeEffect(amplitude: ...)` | Shakes and ends where it started; `frequency`, `xOnly` |
| `PathEffect(waypoints: ...)` | Moves through `Offset` waypoints; `cubicBezier: true` with exactly four |
| `SequenceEffect(children: ...)` | Plays its children one after another |
| `ParallelEffect(children: ...)` | Plays its children together |
| `DelayEffect()` | Waits |
| `RepeatEffect(child: ..., times: ...)` | Repeats a child; `times: 0` repeats for ever |

The single effects take `durationTicks` (30 by default, 60 for `PathEffect`) and `onComplete`; all but `DelayEffect` also take `loop`, and the tweening ones an `easing` (an `EasingType`, linear by default). Transform effects add their change each tick, so two `MoveEffect`s on one entity add up; a colour tint sets the colour, so the last one wins.

```dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

EffectSystemECS effectsOf(World world) {
  var effects = world.getSystem<EffectSystemECS>();
  if (effects == null) {
    effects = EffectSystemECS();
    world.addSystem(effects);
  }
  return effects;
}

/// A hit: a short shake, then a fade out.
EffectHandle hit(World world, Entity enemy) => effectsOf(world).scheduleEffect(
  entity: enemy,
  effect: SequenceEffect(
    children: [
      ShakeEffect(amplitude: 6, durationTicks: 12),
      FadeEffect(to: 0, durationTicks: 30, easing: EasingType.easeInQuad),
    ],
  ),
);

/// A collected coin pops up, grows and turns gold, all at once.
void collect(World world, Entity coin) {
  effectsOf(world).scheduleEffect(
    entity: coin,
    effect: ParallelEffect(
      children: [
        MoveEffect(
          from: Vector3.zero(),
          to: Vector3(0, -40, 0), // up 40, from wherever it is
          durationTicks: 20,
          easing: EasingType.easeOutCubic,
        ),
        ScaleEffect(to: 1.5, durationTicks: 20),
        ColorTintEffect(to: Colors.amber, durationTicks: 10),
      ],
    ),
  );
}
```

To keep effects in step across machines, schedule them at the same `startTick` (`currentTick` says where the system is). For rollback, `snapshotState()` and `restoreSnapshot(snapshot, world)` save and restore every running effect, and `snapshotToBytes()` and `restoreFromBytes(bytes, world)` do the same in a compact binary form. `EffectSerializer` turns one effect into JSON and back (`encodeEffect`, `decodeEffect`); register effect types of your own with `engine.context.effectTypes.register`.

## Post-processing

Fragment shaders can draw over the whole frame or over one entity. Declare each shader under `flutter: shaders:` in `pubspec.yaml` and load it with `ui.FragmentProgram.fromAsset`.

A `ShaderComponent(program: ...)` draws its own entity through the shader, in a layer clipped to the entity's bounds. With `isPostProcess: true` it becomes a full-screen pass instead: add a `PostProcessSystem` once (it is not a default system), and it keeps a `PostProcessPass` on `engine.rendering` for each such component. Passes run in ascending `passOrder`, the lowest applied first, closest to the raw scene, and `enabled` switches one off without removing it. You can also skip the components and call `engine.rendering.addPostProcessPass(PostProcessPass(shader: ...))` yourself, and `removePostProcessPass` later.

The scene arrives in the shader's sampler, bound for you. Your `setUniforms` callback writes the float uniforms each frame, in the order they are declared:

```text shaders/vignette.frag
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uResolution;
  vec4 color = texture(uTexture, uv);
  float edge = 0.75 + 0.05 * sin(uTime);
  float shade = 1.0 - smoothstep(0.35, edge, distance(uv, vec2(0.5)));
  fragColor = vec4(color.rgb * shade, color.a);
}
```

```dart
import 'dart:ui' as ui;

import 'package:just_game_engine/just_game_engine.dart';

Future<void> addVignette(Engine engine) async {
  final world = engine.world;
  if (!world.hasSystem<PostProcessSystem>()) {
    world.addSystem(
      PostProcessSystem(engine.rendering, getTime: () => engine.time.totalTime),
    );
  }
  final program = await ui.FragmentProgram.fromAsset('shaders/vignette.frag');
  world.createEntityWithComponents([
    ShaderComponent(
      program: program,
      isPostProcess: true,
      setUniforms: (shader, width, height, time) {
        shader
          ..setFloat(0, width) // uResolution.x
          ..setFloat(1, height) // uResolution.y
          ..setFloat(2, time); // uTime
      },
    ),
  ], name: 'Vignette');
}
```

> **Warning:** Shader effects need Impeller. On the web, and on platforms still drawing with Skia, the engine skips them: the content draws unshaded and one line is logged per kind of effect. This applies to `ShaderComponent`, post-process passes and an emitter's `shader` alike. `ShaderFilterSupport.isSupported` tells you in advance.
''',
  ),
  DocPage(
    id: 'graphics-3d',
    title: '3D graphics',
    group: DocGroups.graphics,
    summary:
        'Opt in to 3D drawing on Flutter GPU: glTF models, lights, sky, '
        'skeletal animation and eleven built-in shapes, in metres with +Y '
        'down.',
    keywords: [
      'Graphics3D',
      'ModelComponent',
      'LightComponent',
      'LightKind',
      'EnvironmentComponent',
      'AnimationPlayerComponent',
      'SocketComponent',
      'Primitive3D',
      'Cube3D',
      'Sphere3D',
      'Plane3D',
      'Cylinder3D',
      'Capsule3D',
      'Cone3D',
      'Torus3D',
      'Ramp3D',
      'Stairs3D',
      'Arch3D',
      'Polygon3D',
      'CameraLens',
      'GraphicsSceneRenderer',
      'just_graphics_engine',
      'Flutter GPU',
      'glTF',
      'PBR',
    ],
    body: r'''
3D is opt-in. Give the engine a `Graphics3D` and it saves, loads and draws 3D components with [just_graphics_engine](https://pub.dev/packages/just_graphics_engine), a renderer built on Flutter GPU: glTF models, physically based materials, lights and shadows, a sky, skeletal animation, and eleven shapes you can build levels from without a model file.

A game without a `Graphics3D` is 2D only: it makes no GPU device and loads no shaders, and a scene holding 3D components fails to load with an `UnknownComponentTypeException` that says how to turn 3D on. 3D physics is a separate switch; see [3D physics](/docs/physics-3d).

## Turning 3D on

Import `package:just_game_engine/graphics_3d.dart` and pass a `Graphics3D` to `EngineConfig`. As the engine is made it registers the 3D components. As it initializes, it makes the GPU device and the renderer, loads models through `engine.assets`, adds a `GraphicsSceneRenderer` to the frame and an `AnimationSystem3D` to the world. `engine.graphics3D` returns the one you gave, or null in a 2D game.

```dart lib/main.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/graphics_3d.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      graphics3D: Graphics3D(
        onUnsupported: (reason) => debugPrint('No 3D here: $reason'),
      ),
    ),
  );
  await engine.initialize();

  // A perspective camera, in metres: 3 m up (+Y is down), 8 m back,
  // tilted down a little.
  engine.cameraSystem.mainCamera
    ..lens = const CameraLens.perspective(near: 0.1, far: 500)
    ..position = const Offset(0, -3)
    ..z = -8
    ..pitch = -0.36;

  final world = engine.world;
  world.createEntityWithComponents([
    TransformComponent(),
    Plane3D(width: 20, depth: 20, color: const Color(0xFF7A8B6F)),
  ], name: 'Ground');
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-1.5, -0.5, 0)),
    Cube3D(color: Colors.orange, roughness: 0.6),
  ], name: 'Crate');
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(1.5, -0.5, 0)),
    Sphere3D(color: const Color(0xFFFFD54F), metallic: 1, roughness: 0.25),
  ], name: 'GoldBall');

  // The sun shines along its entity's +Z axis, here turned to point down.
  world.createEntityWithComponents([
    TransformComponent(euler: Vector3(-0.9, 0.4, 0)),
    LightComponent(kind: LightKind.directional, intensity: 3),
  ], name: 'Sun');
  world.createEntityWithComponents([
    TransformComponent(),
    EnvironmentComponent(fog: true, fogStart: 15),
  ], name: 'Sky');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
```

Units are metres. The axes are the engine's own: +X right, +Y down (so up is -Y) and +Z into the screen. glTF models, which are Y-up, are turned into these axes as they load.

The 3D view is drawn as an image beneath the 2D world, so sprites, shapes, particles and Flutter UI draw on top of it, and post-processing and camera effects still apply.

## Switching on Flutter GPU

Flutter GPU needs Impeller and a switch in each platform's runner. The engine needs Flutter 3.47.1 or newer, the first stable release where Flutter GPU can be switched on in Windows and Linux release builds. From the Getting started of `just_graphics_engine`:

| Platform | Where | What to set |
|---|---|---|
| Windows | `windows/runner/main.cpp`, after the `DartProject` is made | `project.set_enable_flutter_gpu(true);` |
| Linux | `linux/runner/my_application.cc` | `fl_dart_project_set_enable_flutter_gpu(project, TRUE);` |
| Android | `android/app/src/main/AndroidManifest.xml`, inside the application element | `meta-data` entries `io.flutter.embedding.android.EnableImpeller` and `io.flutter.embedding.android.EnableFlutterGPU` set to `true`, and `io.flutter.embedding.android.ImpellerBackend` set to `vulkan` |
| iOS, macOS | `Info.plist` | `FLTEnableFlutterGPU` set to `true`, and `FLTEnableImpeller` on macOS |

On Windows, `flutter run --enable-flutter-gpu` also works, but only in debug builds. Android devices without Vulkan fall back to OpenGL ES, where 3D is not drawn.

## The camera

A 3D scene is seen through the same main camera as a 2D one, given a perspective lens. `CameraLens.perspective` takes a `fieldOfView` (60 degrees by default, in radians), `near` and `far`. Besides its `position` (x and y), the camera has a depth `z`, a `pitch` (below 0 looks down) and a `yaw`. For a camera that follows a player, use a perspective virtual camera with an orbit, first-person or look-at rig; see [Cameras](/docs/cameras).

## Models and animation

- `ModelComponent(model: ...)` draws a glTF 2.0 model (`.glb`, or `.gltf` with its files beside it) at its entity's transform. `castShadows` and `visible` switch it, and `bounds` fills in once it has loaded. List the files under `flutter: assets:`.
- `AnimationPlayerComponent` plays the model's clips: `clip`, `speed` (negative plays backwards), `loop`, `playing` and `crossfade` (0.2 s by default). `play('Walk')` fades to another clip; set `speed` and `loop` for the new clip after calling it, since the old one fades out as it was. `playBlend(clips, weights)` plays several clips in step, and `setBlendWeights` moves the weights.
- An `AnimatorComponent` on the same entity drives the player from an animator graph: a transition's `duration` crossfades, and blend trees really blend (see [Sprites & animation](/docs/sprites)). A timeline's `skeletalClip` track plays clips too.
- `SocketComponent(node: ...)` on a child entity pins it to a joint of its parent's model, keeping its own scale: a sword in a hand, a hat on a head.

```dart
import 'package:just_game_engine/graphics_3d.dart';
import 'package:just_game_engine/just_game_engine.dart';

Entity addKnight(World world) {
  final knight = world.createEntityWithComponents([
    TransformComponent(),
    ModelComponent(model: 'assets/models/knight.glb'),
    AnimationPlayerComponent(clip: 'Idle'),
    TagComponent('player'),
  ], name: 'Knight');

  // A sword in the right hand: a child pinned to the hand joint.
  world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: knight.id),
    SocketComponent(node: 'hand_r'),
    ModelComponent(model: 'assets/models/sword.glb'),
  ], name: 'Sword');
  return knight;
}

void walk(Entity knight) {
  final player = knight.getComponent<AnimationPlayerComponent>()!;
  player.play('Walk', fade: 0.3);
  player.speed = 1.2; // after play(): it applies to the new clip
}
```

## Lights and sky

`LightComponent` lights the scene from its entity:

- `LightKind.directional`: a sun, shining along the entity's +Z axis; turn the entity to aim it. The first one is the sun the renderer uses, and it casts the shadows.
- `LightKind.point`, the default: shines every way from the entity, out to `range` metres (0 for no limit).
- `LightKind.spot`: a cone along +Z, at full brightness inside `innerConeAngle` and dark outside `outerConeAngle` (radians).

`color` is sRGB, as picked, and `intensity` (10 by default) is lux-like for a directional light and candela-like for the others. The renderer takes up to 8 point and spot lights. A scene with no lights at all gets a default sun, so a model you drop in is never black.

`EnvironmentComponent` sets the sky and ambient light; the first enabled one in the scene is used. It draws a gradient sky (`zenith`, `horizon`, `ground`) or, with `sky: false`, a flat `background`, and a `skybox` (an equirectangular `.hdr`) replaces the gradient and lights the scene. `ambientSky` and `ambientGround` set the ambient light, `reflections` and `reflectionStrength` the reflections, `exposure` the brightness, and `fog`, `fogColor`, `fogDensity` and `fogStart` the distance fog.

## Shapes

Eleven shapes build their own meshes from their sizes, in metres, centred on their entity:

| Shape | Sizes, with defaults |
|---|---|
| `Cube3D` | `width`, `height`, `depth` (1 each) |
| `Plane3D` | `width`, `depth` (10 each); flat, seen from both sides |
| `Sphere3D` | `radius` (0.5), `segments`, `rings` |
| `Cylinder3D` | `radius` (0.5), `height` (1), `segments` |
| `Capsule3D` | `radius` (0.5), `height` (2, ends included) |
| `Cone3D` | `radius` (0.5), `height` (1), tip up |
| `Torus3D` | `radius` (0.5, to the middle of the tube), `tubeRadius` (0.2) |
| `Ramp3D` | `width` (1), `height` (1, at its back), `depth` (2), rising towards +Z |
| `Stairs3D` | `width` (1), `height` (1), `depth` (2), `steps` (5) |
| `Arch3D` | `radius` (1.5, outside), `thickness` (0.3), `depth` (0.5), `angle` (half a turn) |
| `Polygon3D` | `points`, an (x, z) outline (a hexagon by default), and `height` (1) |

Every shape also carries its material: `color`, `metallic` (0 to 1), `roughness` (0 a mirror, 1 chalk), `emission` and `emissionStrength` for a glow, `opacity` (below 1 draws blended), `unlit`, and a `texture` repeated `tiling` times per face, or per metre with `tileInMetres`. `castShadows` and `visible` switch it, and round shapes take `smooth: false` for a faceted look.

An entity has at most one shape: find it with `entity.getComponent<Primitive3D>()`. Equal shapes share a mesh and a material, so a hundred equal crates are one draw. In [3D physics](/docs/physics-3d), `Collider3D(shape: ColliderShape3D.matchShape)` gives a body the same shape.

## Performance and stats

- `Graphics3D(renderScale: 0.75)` renders fewer pixels, and `engine.graphics3D!.sceneRenderer.renderScale` changes it later. The scene renderer's `dynamicResolution` lowers the resolution while frames run slow: set `enabled` and `targetFps`, with `minScale` and `maxScale` as limits.
- `engine.graphics3D!.renderer.stats` says what the last frame did: `drawCalls`, `shadowDrawCalls`, `instances`, `skinnedInstances`, `shadowCasters`, `triangles`, `culled`, `lights` and `joints`.
- Physics bodies and characters are drawn between their last two poses, so they move smoothly at any frame rate.

## Where Flutter GPU can't draw

On the web, on Android without Vulkan, with Impeller turned off, or in a plain `flutter test`, the game still runs: scenes and models load (models for their bounds), and the 3D view shows a short note instead of the picture. `engine.graphics3D!.unsupportedReason` says why and `isSupported` is false, and `Graphics3D(onUnsupported: ...)` is told once as the engine initializes. See [Platforms](/docs/platforms) for what else differs on each platform.
''',
  ),
];
