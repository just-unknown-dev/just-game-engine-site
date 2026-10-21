import 'doc_models.dart';

/// The Gameplay pages: physics, input, level maps, tags and spawners.
const List<DocPage> gameplayDocs = [
  DocPage(
    id: 'physics-2d',
    title: '2D physics',
    group: DocGroups.gameplay,
    summary:
        'Give entities bodies and shapes with RigidBody2D and Collider2D, move '
        'them with forces or a CharacterBody2D, and react to collisions, '
        'sensors and queries.',
    keywords: [
      'RigidBody2D',
      'Collider2D',
      'ColliderShape2D',
      'CharacterBody2D',
      'PhysicsSystem',
      'Physics2DQueries',
      'PhysicsLayers',
      'CollisionEnter2DEvent',
      'SensorEnter2DEvent',
      'DistanceJoint2D',
      'FixedJoint2D',
      'SliderJoint2D',
      'WheelJoint2D',
      'BodyType',
      'Box2D',
    ],
    body: r'''
`RigidBody2D` says how a body moves and `Collider2D` gives it a shape. Put them on an entity that has a `TransformComponent` and the engine simulates it. The 3D components use the same names with a `3D` suffix, so what you learn here carries over to [3D physics](/docs/physics-3d).

## How it fits together

`PhysicsSystem` is one of the default systems (`DefaultSystem.physics`, part of `DefaultSystems.all`). Each fixed step it makes a body for every entity with a `Collider2D`, applies the forces and velocities you asked for, steps `engine.physics`, writes the results back to `TransformComponent` and `VelocityComponent`, and fires collision and sensor events on `world.events`. It runs at `SystemPriorities.physics` (90), after input (100) and player control (95), so a velocity you set in a step moves the body in that same step. See [ECS](/docs/ecs) for how priorities work.

Units are world units (pixels in a 2D game) and +Y is down: gravity points along +Y and a jump is −Y. The default gravity is 981 units/s², real gravity at 1 unit = 1 cm. Platformers usually want more, for example `engine.physics.setGravity(0, 2000)`.

## Bodies and colliders

A `Collider2D` on its own is a static body, so floors and walls need nothing else. It behaves like `RigidBody2D(bodyType: BodyType.static)` with the default settings. Add a `RigidBody2D` when the body should move, or when a static body needs its own friction, bounce or layer.

```dart lib/playground.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

void buildPlayground(Engine engine) {
  engine.physics.setGravity(0, 2000);
  final world = engine.world;

  // Static ground: a collider alone. matchShape follows the rectangle.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 200, 0)),
    RectangleComponent(
      width: 900,
      height: 40,
      fillStyle: const ShapePaintStyle(color: Colors.brown),
    ),
    Collider2D(shape: ColliderShape2D.matchShape),
  ], name: 'Ground');

  // A dynamic ball.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-100, -200, 0)),
    VelocityComponent(),
    CircleComponent(
      radius: 20,
      fillStyle: const ShapePaintStyle(color: Colors.red),
    ),
    RigidBody2D(restitution: 0.7),
    Collider2D(shape: ColliderShape2D.circle, radius: 20),
    TagComponent('ball'),
  ], name: 'Ball');

  // A sensor reports overlaps and blocks nothing.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(300, 140, 0)),
    RigidBody2D(bodyType: BodyType.static, isSensor: true),
    Collider2D(size: Vector2(80, 80)),
  ], name: 'Goal');

  world.events.on<CollisionEnter2DEvent>((e) {
    debugPrint('${e.entityA.name} touched ${e.entityB.name}');
  });
  world.events.on<SensorEnter2DEvent>((e) {
    if (e.other.hasTag('ball')) debugPrint('Goal!');
  });
}
```

> **Note:** A contact bounces as much as the less bouncy of its two bodies, and a collider-only body has no bounce. For a bouncy floor, give it `RigidBody2D(bodyType: BodyType.static, restitution: 1)`.

## Body types

| `bodyType` | Moves | Use it for |
|---|---|---|
| `BodyType.dynamic` (default) | by gravity, forces and collisions | crates, balls, debris |
| `BodyType.kinematic` | only by the velocity you give it, and cannot be pushed | moving platforms, lifts |
| `BodyType.static` | never | level geometry |

`isStatic`, `isKinematic` and `isDynamic` read the type back. A kinematic body you move by writing its transform carries what stands on it.

## Rigid body settings

| Field | Default | What it does |
|---|---|---|
| `mass` | 0 | Mass in kg. 0 works it out from the collider's area: a 100 × 100 box weighs 1000 kg (`PhysicsSystem.autoMassPerSquareUnit`). |
| `friction` | 0.5 | Grip, from 0 (ice) up. A contact uses both bodies' friction. |
| `restitution` | 0 | Bounce, 0 to 1. |
| `linearDamping` | 0.05 | Speed a dynamic body loses on its own each second. |
| `angularDamping` | 0.05 | The same, for spin. |
| `gravityScale` | 1 | 0 floats, 2 falls hard. Handy for variable jump height. |
| `isSensor` | false | Report overlaps and stop nothing: triggers, pickups, zones. |
| `lockRotation` | false | Never turn. |
| `continuousCollision` | false | Sweep a small, fast body so it cannot pass through thin walls. Native backend only. |
| `canSleep` | true | Let a body at rest fall asleep until something touches it. |
| `initialVelocity`, `initialAngularVelocity` | zero | What the body starts with. A `VelocityComponent` wins. |
| `layer`, `collidesWith`, `groupIndex` | 0, null, 0 | Collision filtering; see below. |

A platformer character usually wants `friction: 0`, so it slides down walls instead of sticking to them, and `lockRotation: true`. Friction, bounce and damping you change while the game runs take effect on every platform.

After each step `PhysicsSystem` fills in `linearVelocity`, `angularVelocity`, `isAwake`, `isGrounded`, `groundEntity` and `groundNormal`. `isGrounded` stays true for as long as a contact from below lasts.

## Collider shapes

| `shape` | Sized by |
|---|---|
| `ColliderShape2D.box` (default) | `size`, the full width and height (64 × 64 by default); `cornerRadius` rounds the corners |
| `ColliderShape2D.circle` | `radius` |
| `ColliderShape2D.capsule` | `radius` and `height`, the whole height along Y, ends included |
| `ColliderShape2D.polygon` | `points`, a convex polygon of at most 8 points; `cornerRadius` |
| `ColliderShape2D.segment` | the first two `points`, `thickness` thick |
| `ColliderShape2D.chain` | every one of `points`, closed with `loop`, `thickness` thick: terrain |
| `ColliderShape2D.matchShape` | whatever the entity draws: a rectangle, circle, capsule, polygon or line component, else its sprite's box |

A match shape follows the drawing as it changes. Every shape is centred on the entity unless `offset` moves it, and `rotation` and `scale` turn and stretch the collider itself. The collider also grows and shrinks with the entity's scale, as its sprite does; a negative scale on a box, circle or upright capsule does not rebuild the body, so flipping a character to face the other way stays cheap.

`oneWay: true` makes a platform you can jump up through. `oneWayDirection` picks the solid side: `fromAbove` (the default), `fromBelow`, `fromLeft` or `fromRight`. `showDebugOutline: false` leaves a collider out of the debug outlines (see [Debugging](/docs/debugging)).

## Moving bodies from code

Push a `RigidBody2D` with `addForce`, `addImpulse`, `addTorque`, `addAngularImpulse`, `setVelocity`, `setAngularVelocity` and `wakeUp`. Each applies at the next physics step. You can also write the entity's `VelocityComponent`, which the physics system picks up, and teleport a body by writing its `TransformComponent`.

A simple platformer controller is a system at `SystemPriorities.playerControl` that sets `velocity.x` from the `move` action and, when `body.isGrounded` and `jump` was pressed, sets `velocity.y = -800` (up is −Y). Reading actions is covered in [Input](/docs/input).

## Character bodies

A `CharacterBody2D` is a character that gameplay moves rather than the simulation. It walks slopes up to `maxSlopeAngle` (50° by default), climbs steps up to `stepHeight`, keeps to the floor going down (`stickToFloor`), rides moving platforms, stands on one-way platforms and jumps up through them, and pushes dynamic bodies. It needs no `RigidBody2D` or `Collider2D`: its shape is its own, a capsule or a box (`CharacterShape2D`), centred on the entity plus `offset`.

```dart lib/hero.dart
Entity addHero(World world) => world.createEntityWithComponents([
  TransformComponent(),
  InputComponent(),
  RectangleComponent(width: 32, height: 48),
  CharacterBody2D(shape: CharacterShape2D.box, width: 32, height: 48),
  TagComponent('player'),
], name: 'Hero');

class HeroControlSystem extends System {
  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [InputComponent, CharacterBody2D];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final input = entity.getComponent<InputComponent>()!;
      final body = entity.getComponent<CharacterBody2D>()!;
      body.moveVelocity = Offset(input.vector('move').dx * 260, 0);
      if (body.isGrounded && input.wasPressed('jump')) body.jump(800);
    });
  }
}
```

While `useGravity` is on (the default) only the sideways part of `moveVelocity` counts; the system adds gravity and the ground's own velocity. After each step read `velocity`, `groundState` (a `GroundState2D`), `isGrounded`, `groundNormal`, `groundVelocity` and `groundEntity`. The character's own body is kinematic, so sensors see it and dynamic bodies bump into it, but it touches static ground through its mover rather than through contacts: read `groundEntity` to know what it stands on. Set `detectable: false` to hide it from sensors and rays.

## Joints

Put a joint on an entity that has a body and point `connectedBody` at the other one with an [EntityTarget](/docs/tags-spawners), such as `EntityTarget.name('Anchor')`. `PhysicsJointBindingSystem`, part of the default physics systems, makes the joint once both bodies exist and remakes it when a setting changes.

| Joint | What it does | Main fields |
|---|---|---|
| `DistanceJoint2D` | keeps two bodies a set distance apart, springily | `length`, `stiffness` (Hz; 0 holds the length rigidly), `damping` (a damping ratio) |
| `FixedJoint2D` | holds two bodies rigidly together | none |
| `SliderJoint2D` | lets the bodies slide along one axis | `axis`, `useLimits`, `minPosition`, `maxPosition`, `enableMotor`, `motorSpeed`, `motorMaxForce` |
| `WheelJoint2D` | a wheel on a suspension | `axis`, `stiffness`, `damping`, `enableMotor`, `motorSpeed`, `motorMaxTorque` |

Every joint also has `anchor`, `connectedAnchor`, `collideConnected` (false: the two bodies do not collide with each other) and `enabled`. Axes are in the joint entity's own space.

## Layers and filtering

Each body sits on one of 16 collision layers, `layer: 0` to `15`. The project names the layers and says which ones collide in `assets/project/physics.json`, a `PhysicsLayers` that the editor's Physics Layers dock writes. `Engine.initialize` reads it when the app bundles it, so list the file under `flutter: assets:`. Without it every body collides with every other.

The file lists each layer by number, for example `{"version": 1, "layers": [{"index": 1, "name": "Player"}, {"index": 2, "name": "Enemy", "ignores": [2]}]}`, where enemies pass through each other. Read the grid in code with `engine.context.physicsLayers`, for example `engine.context.physicsLayers.collides(1, 2)`.

- `collidesWith` is a mask (bit `n` for layer `n`) that overrides the grid for one body: `RigidBody2D(layer: 2, collidesWith: (1 << 0) | (1 << 2))`. Two bodies collide only when each collides with the other's layer.
- Set `collidesWith = 0` to make a body collide with nothing for a while, such as a crumbling platform, and set it back to `null` to follow the grid again.
- `groupIndex` overrides layers for a group: a positive group always collides with itself, a negative one never does, and 0 leaves it to the layers.

## Collision and sensor events

Listen on `world.events`. Events are per pair of entities, so a chain collider sends one enter and one exit.

| Event | When | Fields |
|---|---|---|
| `CollisionEnter2DEvent` | two bodies begin touching | `entityA`, `entityB`, `point`, `normal` (from A towards B), `depth` |
| `CollisionStay2DEvent` | every step they keep touching, once you turn it on | the same |
| `CollisionExit2DEvent` | they stop touching | `entityA`, `entityB` |
| `SensorEnter2DEvent` | something enters a sensor | `sensor`, `other` |
| `SensorExit2DEvent` | something leaves a sensor | `sensor`, `other` |

Stay events are off so that nothing pays for them unasked. Turn them on with `engine.world.getSystem<PhysicsSystem>()?.reportContactStay = true`.

## Queries

`Physics2DQueries` casts rays and circles and finds overlaps, answering with entities. Every query takes a `layerMask` (all layers by default), an entity to `ignore` (usually the one asking) and `includeSensors` (false by default).

```dart lib/vision.dart
/// Whether [guard] can see the player straight ahead.
bool canSeePlayer(Engine engine, Entity guard) {
  final queries = Physics2DQueries(
    engine.physics,
    engine.world.getSystem<PhysicsSystem>()!,
  );
  final eyes = guard.getComponent<TransformComponent>()!.position;
  final hit = queries.raycast(
    Offset(eyes.x, eyes.y),
    const Offset(1, 0),
    maxDistance: 300,
    ignore: guard,
  );
  return hit?.entity?.hasTag('player') ?? false;
}
```

`raycastAll` returns every hit, nearest first, and `circleCast` sweeps a circle. `overlapCircle` and `overlapBox` (a `Rect`) return the entities they touch. A hit (`PhysicsHit2D`) carries `entity`, `body`, `point`, `normal`, `distance` and `fraction`.

## Two backends

`engine.physics` is a `PhysicsEngine` from `just_physics_engine`. On native platforms it is Box2D v3 through FFI; on the web (JavaScript and WebAssembly), or wherever the native library does not load, it is a pure-Dart engine with the same API. Your components, events and queries are the same on both. To choose the engine yourself, pass `EngineConfig(createPhysics: ...)`: for example `createPhysics: PhysicsEngine.pureDart` runs the pure-Dart engine on every platform.

## Known limitations

These wait on `just_physics_engine`. The fields involved are saved as usual, so scenes need no change when the limits lift.

- `anchor` and `connectedAnchor` of `DistanceJoint2D` and `FixedJoint2D` are not passed to the physics engine: a distance joint holds the bodies by their centres, and a fixed joint holds them as they were when joined. A wheel joint's axle anchor is honoured on native Box2D only.
- Jointed bodies with `collideConnected` off send no contact events between them, but on the pure-Dart backend they still push each other apart.
- On native Box2D, queries skip bodies whose collision mask is 0 (such as `collidesWith: 0`); the pure-Dart backend finds them.
- `continuousCollision` works on the native backend only.
- `CollisionEnter2DEvent.depth` is always 0, and its `point` is worked out from where the two bodies' bounds meet, because neither backend reports them in 2D.
- On native Box2D a static sensor does not report static colliders.
''',
  ),
  DocPage(
    id: 'physics-3d',
    title: '3D physics',
    group: DocGroups.gameplay,
    summary:
        'Opt into Jolt-based 3D physics with Physics3D, then use RigidBody3D, '
        'Collider3D and CharacterBody3D, which mirror the 2D components.',
    keywords: [
      'Physics3D',
      'RigidBody3D',
      'Collider3D',
      'ColliderShape3D',
      'CharacterBody3D',
      'PhysicsSystem3D',
      'Physics3DQueries',
      'HingeJoint3D',
      'CollisionEnter3DEvent',
      'SensorEnter3DEvent',
      'CameraCollision3D',
      'Jolt',
      'just_jolt',
    ],
    body: r'''
3D physics runs on Jolt Physics and is opt-in. A game without it is 2D only, and its release build carries no 3D code and no Jolt. The components mirror [2D physics](/docs/physics-2d): `RigidBody3D` says how a body moves, `Collider3D` gives it a shape, and the events and queries have the same names with `3D` for `2D`.

## Turn it on

Import `package:just_game_engine/physics_3d.dart` and give the engine a `Physics3D`. Jolt is native code, so the app's own `pubspec.yaml` must also ask for it to be built. An app that gets Jolt only through another package builds nothing.

```yaml pubspec.yaml
hooks:
  user_defines:
    just_jolt:
      build: true
```

```dart lib/main.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/physics_3d.dart';

Future<Engine> createEngine() async {
  final engine = Engine(
    config: EngineConfig(
      defaultSystems: DefaultSystems.all,
      // Null where Jolt cannot run, such as the web.
      physics3D: Physics3D.isSupported ? Physics3D() : null,
    ),
  );
  await engine.initialize();
  if (engine.physics3D == null) {
    debugPrint('No 3D physics here: ${Physics3D.unsupportedReason}');
  }
  return engine;
}
```

As the engine is made, `Physics3D` registers the 3D components, so scenes holding them load and save, and adds a camera stage that keeps cameras out of walls. As the engine initializes, it starts Jolt and adds `PhysicsSystem3D` to the world. The physics world itself is made only when the first 3D body or character appears, so a game whose 3D scenes come later pays nothing until then. `engine.physics3D` is the `Physics3D` you passed, or null.

## Where it runs

Where 3D physics cannot run, `initialize()` fails with an `EngineInitException` whose `cause` is a `Physics3DUnsupportedError`. That happens on the web, on 32-bit Android ABIs, and in an app whose pubspec did not ask for Jolt. Ask first with `Physics3D.isSupported`, and read why with `Physics3D.unsupportedReason`, as the sample above does.

| Platform | Jolt (`just_jolt` 0.1.0) |
|---|---|
| Windows x64 | built and tested |
| Android arm64-v8a, x86_64 | built by the hook (NDK r26 or newer) |
| Linux, macOS, iOS | should build; untested |
| Web | not available |

The component classes are plain data with no native code. Where Jolt cannot run, `Physics3D.registerSchemas(engine.context)` registers them without simulating them, which is what a tool that reads and writes 3D scenes uses.

> **Tip:** On Windows, Jolt builds inside the app's `.dart_tool` folder, so keep the app's folder path under about 175 characters.

## Units and settings

Units are metres, seconds and radians, and +Y is down, so gravity is (0, 9.81, 0) unless you pass `Physics3D(gravity: ...)`. The other options are `workerThreads` (below 0: cores minus one, the default), `maxBodies` (10240), `reportContactStay`, `reportActivation`, `addSystem` (true; false leaves adding `system` to the game) and `engine`, a `PhysicsEngine3D` of your own.

## Bodies and colliders

As in 2D, a `Collider3D` alone is a static body, and a `RigidBody3D` beside it says how it moves. `RigidBody3D` has the 2D fields: `bodyType` (`BodyType3D.static`, `kinematic` or `dynamic`, the default), `mass` (0 works it out from the collider's volume), `friction` (0.5), `restitution` (0), `linearDamping` and `angularDamping` (0.05), `gravityScale`, `isSensor`, `lockRotation`, `continuousCollision`, `canSleep`, `layer`, `initialVelocity` and `initialAngularVelocity`. Changing `bodyType`, damping, `isSensor`, `canSleep` or `lockRotation` rebuilds the body.

Push a body with `addForce` (N), `addTorque`, `addImpulse` (N·s), `addAngularImpulse`, `setVelocity`, `setAngularVelocity` and `wakeUp`, all applied before the next step. After each step it holds `linearVelocity`, `angularVelocity` and `isAwake`. Move a kinematic or static body by writing its transform. A 3D body has only a `layer`: there is no `collidesWith` or `groupIndex`, so the project's layer grid decides what collides.

| `ColliderShape3D` | Sized by |
|---|---|
| `box` (default) | `size`, the full size along X, Y and Z (1 m) |
| `sphere` | `radius` (0.5 m) |
| `capsule` | `radius` and `height`, along Y, caps included |
| `cylinder` | `radius` and `height`, along Y |
| `convexHull` | the convex hull of a model's vertices: `model` (a `.glb` or `.gltf`) and optionally `meshName` |
| `mesh` | a model's triangles; static and kinematic bodies only |
| `heightField` | terrain from `heights`, `heightFieldSize` samples a side (at least 4) and `cellSize`; static bodies only |
| `matchShape` | the 3D shape the entity is drawn as, such as `Cube3D` or `Stairs3D`; concave ones are made of convex parts, so they work on dynamic bodies too |

Each shape has its own `offset`, `rotation` (Euler angles) and `scale`, and follows the entity's scale. Models load through the engine's assets. Bodies have no look of their own: draw them with [3D graphics](/docs/graphics-3d).

```dart lib/room.dart
void buildRoom(World world) {
  // A floor: a collider alone is static. +Y is down, so -2 is above it.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 0.5, 0)),
    Collider3D(size: Vector3(20, 1, 20)),
  ], name: 'Floor');

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, -2, 0)),
    Collider3D(),
    RigidBody3D(),
  ], name: 'Crate');

  // A coin: a static sensor.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(4, -1.2, 0)),
    Collider3D(shape: ColliderShape3D.sphere, radius: 0.3),
    RigidBody3D(bodyType: BodyType3D.static, isSensor: true),
  ], name: 'Coin');

  // A door on a hinge that swings to 1 radian. Jointed bodies still
  // collide, so the frame stands clear of the door.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-0.5, -1, 0)),
    Collider3D(size: Vector3(0.2, 2, 0.2)),
  ], name: 'Frame');
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0.6, -1, 0)),
    Collider3D(size: Vector3(1, 2, 0.1)),
    RigidBody3D(gravityScale: 0),
    HingeJoint3D(
      connectedBody: const EntityTarget.name('Frame'),
      anchor: Vector3(-0.5, 0, 0),
      motor: MotorState3D.position,
      motorTarget: 1,
    ),
  ], name: 'Door');
}
```

## Characters

A `CharacterBody3D` is a capsule that gameplay moves rather than forces (Jolt's `CharacterVirtual`). It walks on ground, slides along walls, climbs steps and slopes, and rides moving platforms. Its entity's position is its feet, and it needs no `RigidBody3D` or `Collider3D`. The defaults are a character 1.8 m tall with a 0.3 m radius, `maxSlopeAngle` 50°, `stepHeight` 0.4 m, `stickToFloor` 0.5 m, `mass` 70 kg and `pushStrength` 100 N.

```dart lib/hero_3d.dart
class Hero3DControlSystem extends System {
  static const double speed = 4; // m/s

  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [InputComponent, CharacterBody3D];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final input = entity.getComponent<InputComponent>()!;
      final body = entity.getComponent<CharacterBody3D>()!;
      final move = input.vector('move'); // y is down: "up" is -1
      body.moveVelocity.setValues(move.dx * speed, 0, -move.dy * speed);
      if (body.isGrounded && input.wasPressed('jump')) body.jump(5);
    });
  }
}
```

With `useGravity` on, the system adds gravity and the ground's velocity to `moveVelocity`. Turn it off and `moveVelocity` is the whole velocity, for flying, swimming or ladders. After each step read `velocity`, `groundState` (a `GroundState3D`), `isGrounded`, `groundNormal`, `groundVelocity` and `groundEntity`. A `detectable` character is seen by sensors and hit by rays.

## Joints

Every joint sits on one entity and names the other with `connectedBody`, an `EntityTarget`; leave it as `EntityTarget.none` to join the body to the world. `anchor` is in the joint entity's own space, and `enabled` switches the joint off. The joint is made where the bodies are when both exist, and made again when a setting changes. Jointed bodies still collide with each other: leave a gap between them, or put them on layers that do not collide.

| Joint | What it does |
|---|---|
| `FixedJoint3D` | holds two bodies rigidly together |
| `PointJoint3D` | holds them at one point, free to turn (a ball joint) |
| `HingeJoint3D` | turns about `axis`, with optional limits (`useLimits`, `minAngle`, `maxAngle`), `friction` and a motor; reports `angle` |
| `SliderJoint3D` | slides along `axis`, with optional limits, `friction` and a motor; reports `position` |
| `DistanceJoint3D` | keeps `anchor` and `connectedAnchor` between `minDistance` and `maxDistance`, with `springFrequency` and `springDamping` |
| `SixDofJoint3D` | each of the six axes `SixDofAxisMode3D.free`, `limited` or `fixed` |

A motor is `MotorState3D.off`, `velocity` (a target speed) or `position` (a target angle or position), set by `motorTarget` and capped by `motorMaxTorque` or `motorMaxForce`.

## Events and queries

The events fire on `world.events` after the step, with the 2D fields: `CollisionEnter3DEvent` and `CollisionStay3DEvent` (`entityA`, `entityB`, `point`, `normal`, `depth`), `CollisionExit3DEvent`, and `SensorEnter3DEvent` and `SensorExit3DEvent` (`sensor`, `other`). Stay events fire only with `Physics3D(reportContactStay: true)`.

`engine.physics3D!.queries` is a `Physics3DQueries`: `raycast`, `raycastAll`, `sphereCast`, `shapeCast`, `overlapSphere`, `overlapBox` and `overlap`. Like the 2D queries, each takes `layerMask`, `ignore` and `includeSensors`, and a hit (`PhysicsHit3D`) names its `entity`, `point`, `normal` and `distance`. For example, `queries.raycast(Vector3(0, -10, 0), Vector3(0, 1, 0), maxDistance: 50)` looks straight down (+Y is down). Until the first 3D body exists every query finds nothing.

To keep a third-person camera out of walls, add `CameraCollision3D` to the camera entity beside its `OrbitFollowComponent`; see [Cameras](/docs/cameras).
''',
  ),
  DocPage(
    id: 'input',
    title: 'Input',
    group: DocGroups.gameplay,
    summary:
        'Read named actions from keyboard, mouse, gamepads and touch through '
        'engine.input, with local multiplayer, rebinding and on-screen '
        'controls.',
    keywords: [
      'InputService',
      'InputActionAsset',
      'InputComponent',
      'InputSystem',
      'PlayerInputManager',
      'PlayerInput',
      'rebindPlayer',
      'RebindList',
      'OnScreenControls',
      'PointerLock',
      'LookInput',
      'just_inputs',
    ],
    body: r'''
`engine.input` is an `InputService` from `just_inputs`. Your game reads named actions such as `jump` and `move`, and an input asset binds them to keyboard keys, mouse buttons, gamepads and touch controls. Gameplay code never asks which device was used.

## How input works

| Piece | What it is |
|---|---|
| Asset | a `.input.json` file (`InputActionAsset`) holding everything below |
| Map | actions switched on and off together, such as `player` while playing and `ui` in menus |
| Action | something the player does: a `button`, an `axis` or a `vector2` |
| Binding | a control path such as `<Keyboard>/space` or `<Gamepad>/leftStick`, or a composite such as `2DVector` for WASD |
| Interaction, processor | how a press becomes the action (press, hold, tap) and changes on the way (dead zones, invert, scale) |
| Scheme | a way of playing (keyboard and mouse, gamepad, touch) and its bindings |

Keys are bound by position, so WASD stays under the left hand on an AZERTY keyboard. `GameWidget` sends keys and pointers to `engine.input`, and the engine updates it once per fixed step, and every frame while paused so menus and rebinding keep working.

## The input asset

Actions live in an asset, not in code. The Input Actions editor in the [editor](/editor) writes these files; you can also write them by hand. List the folder under `flutter: assets:` in `pubspec.yaml`.

```json assets/input/game.input.json
{
  "format": "just_inputs",
  "version": 3,
  "nextId": 11,
  "name": "game",
  "maps": [
    {
      "id": "m1",
      "name": "player",
      "actions": [
        {
          "id": "a1", "name": "move", "type": "vector2",
          "bindings": [
            {
              "id": "b1", "composite": "2DVector",
              "parts": [
                { "id": "b2", "part": "up", "path": "<Keyboard>/w" },
                { "id": "b3", "part": "down", "path": "<Keyboard>/s" },
                { "id": "b4", "part": "left", "path": "<Keyboard>/a" },
                { "id": "b5", "part": "right", "path": "<Keyboard>/d" }
              ]
            },
            { "id": "b6", "path": "<Gamepad>/leftStick" }
          ]
        },
        {
          "id": "a2", "name": "jump", "type": "button",
          "bindings": [
            { "id": "b7", "path": "<Keyboard>/space" },
            { "id": "b8", "path": "<Gamepad>/buttonSouth" }
          ]
        }
      ]
    },
    {
      "id": "m2",
      "name": "ui",
      "actions": [
        {
          "id": "a3", "name": "pause", "type": "button",
          "bindings": [
            { "id": "b9", "path": "<Keyboard>/escape" },
            { "id": "b10", "path": "<Gamepad>/start" }
          ]
        }
      ]
    }
  ]
}
```

To build an asset in code, import `package:just_inputs/just_inputs.dart` for the asset model (`InputActionDef`, `ControlBindingDef` and the rest) and validation; the engine re-exports only what a game uses at run time.

## Load and read actions

Load the asset after `engine.initialize()`; until then no action is bound. `InputSystem`, a default system, then copies each player's `player`-map actions onto every entity with an `InputComponent`, by action name.

```dart lib/input.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_game_engine/just_game_engine.dart';

Future<void> loadInput(Engine engine) async {
  final text = await rootBundle.loadString('assets/input/game.input.json');
  engine.input.loadAsset(InputActionAsset.parse(text));
  // Players' saved bindings, so they apply from the start.
  await engine.input.players.preloadOverrides();
  // Gamepads are opt-in: attaching them opens platform channels.
  await engine.input.attachGamepads();

  // Actions outside the player map are read from the service. Input keeps
  // updating while the engine is paused, so this can also resume it.
  engine.input.actions.action('ui/pause').onPerformed((_) {
    engine.isPaused ? engine.resume() : engine.pause();
  });
}

/// Moves every entity that has an InputComponent, top-down style.
class WalkSystem extends System {
  static const double speed = 240;

  // After InputSystem (100) has copied the actions in.
  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [InputComponent, VelocityComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final input = entity.getComponent<InputComponent>()!;
      final velocity = entity.getComponent<VelocityComponent>()!.velocity;
      final move = input.vector('move'); // y is down, like the world
      velocity.x = move.dx * speed;
      velocity.y = move.dy * speed;
    });
  }
}
```

`InputComponent` reads player 1 by default; `InputComponent(playerIndex: 1)` reads player 2 and `playerIndex: -1` reads every device at once.

| Method | Returns |
|---|---|
| `vector('move')` | a vector action's value as an `Offset`, y down |
| `axis('throttle')` | how far an axis or button action is pushed |
| `isDown('jump')` | whether a button is held |
| `wasPressed('jump')` | whether it went down this step (true for one step only) |
| `wasReleased('jump')` | whether it was let go this step |
| `wasPerformed('jump')` | whether the action completed this step, for example a hold |

Outside the ECS, read an action by its `map/name` path: `engine.input.actions.action('player/jump')` has `isPressed()`, `wasPressedThisFrame()`, `readVector2()`, `readAxis()` and the callbacks `onStarted`, `onPerformed` and `onCanceled`. Switch a whole map off for a menu with `engine.input.actions.map('player')!.disable()` and back on with `enable()`.

## Gamepads

Gamepads are opt-in: call `await engine.input.attachGamepads()` once. Bind them with paths such as `<Gamepad>/leftStick` and `<Gamepad>/buttonSouth`, and list the connected pads with `engine.input.gamepads`. On the web, gamepads work in JavaScript and WebAssembly builds once a button is pressed, because browsers hide pads until then.

## Local multiplayer

`engine.input.players` is a `PlayerInputManager`. A single-player game can leave it off and read the shared actions. Call `start()` and players come and go as the asset's `players` block says, for example `"players": {"max": 2, "joining": "onJoinAction", "joinActions": ["player/join"]}`:

- player 1 is whoever plays first, with whatever they touch;
- a device nobody uses joins as the next player when a join action is performed on it (give the join action a hold, so a quick press can mean something else);
- a player whose pad is pulled out is lost until it, or another pad, comes back (`deviceLost`, `deviceRegained`, `dropLost`).

```dart lib/coop.dart
void startCoop(Engine engine) {
  final players = engine.input.players;
  players.joined.listen((player) {
    engine.world.createEntityWithComponents([
      TransformComponent(),
      VelocityComponent(),
      InputComponent(playerIndex: player.index),
      RectangleComponent(width: 32, height: 48),
    ], name: 'Player ${player.index + 1}');
  });
  players.start();
}
```

`players[1]` is player 2's `PlayerInput`, or null while nobody is playing as them, and `engine.input.actionsFor(1)` is their live actions. Set `players.joiningEnabled = false` to stop new players joining, for example while paused.

## Rebinding

`rebindPlayer(player, bindingId)` listens for the next control the player touches, keeps it and saves it, swapping with any binding it clashes with. It works while the game is paused, takes keys before any focused widget, and Escape alone cancels. `player.resetOverrides()` goes back to the asset's bindings.

The engine saves each player's bindings in its own settings store (`CacheInputOverrideStore`), apart from the cache's entries, so `engine.cache.clearAll()` leaves them alone. Call `engine.input.players.preloadOverrides()` after `loadAsset`, as above, to apply them at the next start. A `PlayerInput` exists once its player has joined, so start the player manager when your game offers rebinding.

## On-screen controls

The asset's `onScreen` list places touch buttons and sticks relative to the screen, for example `{"id": "jump", "kind": "button", "anchor": [0.8, 0.6], "label": "A"}`. `anchor` runs from -1 to 1 on each axis like Flutter's `Alignment`, and `size` is a share of the screen's shorter side. A stick's `mode` is `fixed` or `floating` (under the thumb, inside its `region`). Bind them like any other control: `<OnScreen>/jump`.

```dart lib/game_screen.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/widgets.dart';

Widget gameScreen(Engine engine) => GameWidget(
  engine: engine,
  overlay: Positioned.fill(
    // Shown on phones and tablets; OnScreenVisibility.always shows them
    // everywhere.
    child: OnScreenControls(input: engine.input),
  ),
);

/// A controls page: each action with a button to rebind it.
Widget controlsPage(Engine engine) {
  final player = engine.input.players[0];
  if (player == null) return const Text('Press any key to join.');
  return RebindList(player: player, maps: const ['player']);
}
```

`widgets.dart` also has `RebindButton`, `RebindRow` and `BindingLabel` for building your own rebinding screen.

## Mouse look and pointer lock

For mouse look, set `engine.input.lockPointerOnClick = true`. `GameWidget` then takes hold of the pointer on a press on the game: the cursor hides, stays in the window, and raw mouse movement feeds the mouse device. Escape lets go, as does the window going behind another, and the next click takes hold again. You can also call `engine.input.pointerLock.lock()` and `unlock()` yourself. Pointer lock works on Windows today; elsewhere `pointerLock.isSupported` is false and nothing happens.

A camera should read look input once per rendered frame rather than once per fixed step. `LookActions.addTo(asset)` adds a `look` action for the mouse and `lookStick` for the right stick, and `LookInput(engine.input.actionsFor(0)!).read(dt)` returns the turn in radians.
''',
  ),
  DocPage(
    id: 'level-maps',
    title: 'Level maps',
    group: DocGroups.gameplay,
    summary:
        'Draw tile maps from the scene, a .map.json file or a Tiled .tmx/.tmj '
        'with LevelMapComponent, give layers collision, and change tiles '
        'while the game runs.',
    keywords: [
      'LevelMapComponent',
      'LevelMapData',
      'MapLayerData',
      'LevelMaps',
      'LevelMapHandle',
      'MapCollisionSystem',
      'MapCollisionKinds',
      'MapBodyComponent',
      'TiledInterop',
      'MapGeometry',
      'WangFiller',
      'BuiltInTilesets',
      'TileChangedEvent',
      'Tiled',
    ],
    body: r'''
A level map is layers of tiles. One `LevelMapComponent` puts a whole map in the level at its entity's position; the map is not rotated or scaled with the entity. Maps can be orthogonal, isometric, staggered or hexagonal (`MapOrientation`), and `MapGeometry` places cells exactly as Tiled does, so a map looks and collides the same here as in Tiled. Tiles can be animated, flipped and rotated.

Two default systems run maps: `LevelMapSystem` (priority 110) loads and draws them, and `MapCollisionSystem` (108) builds their collision. Both are in `DefaultSystems.all`; for a world of your own, call `registerLevelMapSystems(world)` and add a `RenderSystem` to draw the layers.

## Three ways to store a map

| Where the map lives | How you set it | Good for |
|---|---|---|
| In the scene | `LevelMapComponent(inline: LevelMapData(...))`, saved as the component's `inline` field | the editor's default: a level that is one file with one undo history |
| A `.map.json` file | `LevelMapComponent(mapPath: 'assets/maps/cave.map.json')` | one map shared by several scenes |
| A Tiled file | `LevelMapComponent(mapPath: 'assets/maps/cave.tmx')`, or `.tmj` | maps made in Tiled |

While `mapPath` is set the inline map is ignored. Tilesets are `.tileset.json` files, or Tiled's `.tsx`. Older `.tilemap.json` files are still read. List every folder the map, its tilesets and their images live in under `flutter: assets:`; a folder entry does not include its subfolders.

A scene's own map is usually the entity called `LevelMaps.primaryName` (`Level Map`), which is how `LevelMaps.primary(world)` finds it.

```dart lib/level.dart
Future<void> startLevel(World world) async {
  world.createEntityWithComponents([
    TransformComponent(),
    LevelMapComponent(mapPath: 'assets/maps/level_01.tmx'),
  ], name: LevelMaps.primaryName);

  // Load maps and tilesets before the first frame: otherwise the player
  // can fall through ground that is still loading.
  final failures = await LevelMaps.preload(world);
  for (final failure in failures) {
    debugPrint('Map ${failure.path} did not load: ${failure.error}');
  }
}
```

`LevelMaps.preload` loads every map in the world and its tilesets; images may still be arriving. A map that will not load does not stop the others: it is left without anything to draw or collide with, logged once, and returned in the list. When you move from level to level, call `LevelMaps.evictUnused(world)` after the next level has loaded to drop tilesets that no map uses any more. Loading scenes is covered in [Scenes](/docs/scenes).

## Tiled maps

`.tmx` and `.tmj` maps load directly, with their tilesets embedded or as `.tsx` files; image paths are read relative to the file that names them. A few Tiled settings carry meaning:

- A tile layer with the bool custom property `collides` set to true gets physics bodies, and one with `foreground` draws in front of the level.
- Tile collision comes from Tiled's tile collision editor: rectangles, ellipses and polygons. Lines and points are left out.
- A tile's collision kind is its `collision` string property; failing that, the first shape's class when it names a registered kind; otherwise `solid`.
- Object layers become empty map layers. Their objects are not turned into entities.

To read the objects, parse the file with the `just_tiled` package and call `TiledInterop.importMap`. It returns a `TiledImport` with the converted `map` and `tilesets`, every object as a `TiledObjectRecord` (`object`, `layerName`, `position`, `mapLayerId`), the image layers and any `warnings`. `TiledInterop.exportMap` and `exportTileset` go the other way. Their signatures use `just_tiled` models, so add that package to call them.

## Layers

Each layer is a `MapLayerData` with a `name`, `visible`, `opacity`, `tint`, `offsetX` and `offsetY`, `parallaxX` and `parallaxY` (less than 1 lags behind like a distant background), `collides`, `className` and custom `properties`. A layer sorts among the level's other drawing by `sortLayerId` (`background`, `main` or `foreground`), `sortLayer` and `zOrder`, so one map's background layer draws behind the player and its foreground layer in front.

An entity can sit on a layer: make it a child of the map's entity with `LayerComponent(mapLayer: layerId)`, and it draws just above that layer's tiles and below the next layer's.

## Tile collision

`MapCollisionSystem` gives every layer marked `collides` static bodies built from its tiles' collision shapes. The bodies are ordinary entities with a transform, a static `RigidBody2D`, a `Collider2D` and a `MapBodyComponent` that says which map, layer, kind, class and cells they came from. They are generated, never saved. Contacts with them are reported like any other, and standing on them grounds a character (see [2D physics](/docs/physics-2d)). A layer's bodies are rebuilt at most once a frame when its cells, settings or tilesets change, or the map moves.

The engine knows two collision kinds: `MapCollisionKinds.solid`, merged into as few boxes as possible, and `MapCollisionKinds.oneWay`, merged along rows and passed through from below. A kind nobody registered resolves to `solid`. Register your own in `engine.context.collisionKinds` before the maps load:

```dart lib/hazards.dart
void addHazards(Engine engine) {
  engine.context.collisionKinds.register(
    MapCollisionKind(
      id: 'hazard',
      label: 'Hazard',
      color: 0xFFE57373, // the editor's collision overlay
      merge: TileMergeMode.none, // one body per tile
      sensor: true,
      decorate: (body, spec, properties) => body.addTag('hazard'),
    ),
  );

  engine.world.events.on<SensorEnter2DEvent>((e) {
    final tile = e.sensor.getComponent<MapBodyComponent>();
    if (tile?.kind == 'hazard' && e.other.hasTag('player')) {
      debugPrint('${e.other.name} touched a hazard');
    }
  });
}
```

`decorate` runs once each body is built and receives its tile's properties, such as a spike's `damage`. `TileMergeMode` is `area`, `rows` or `none`.

## Change tiles at run time

`LevelMaps.primary(world)`, or `LevelMaps.of(world, entity)` for any map, returns a `LevelMapHandle` once the map has loaded. Changes are the running game's own: the map file and the scene's saved map are untouched. Collision follows within the frame, and each change fires a `TileChangedEvent` with the map entity, the layer id and the changed cells.

```dart lib/blocks.dart
/// Knocks out the tile under [point] on the "Ground" layer if its
/// tileset gives it the class "Breakable".
void hitBlock(World world, Offset point) {
  final map = LevelMaps.primary(world);
  final ground = map?.layer('Ground');
  if (map == null || ground == null) return;
  final cell = map.cellAt(ground, point);
  if (map.tileAt(ground, cell)?.className == 'Breakable') {
    map.setTile(ground, cell, TileCell.empty);
  }
}
```

`tileAt` returns a `TileInfo` with the tile's `className`, `properties`, `tileset` and `localId`, and `tileAtPoint` takes a world point. `setTiles` changes many cells with one event and one collision rebuild. `cellCenter` turns a cell back into a world point. `setCellsHidden` and `setBodyHidden` stop drawing cells without changing them, for a platform that crumbles and comes back. A cell value is made with `TileCell.make(slot, localId)`, where `slot` is the tileset's index in the map's `tilesets`.

## Terrain with Wang sets

`LevelMapHandle.setTerrain(layer, targets, color, slot: ..., wangSet: ...)` paints terrain from a tileset's Wang set, choosing tiles as the editor's terrain brush does. `WangFiller` does the work; targets are `WangTarget.corner`, `WangTarget.edge` or `WangTarget.cell`. It returns a `WangResult` with the cells it changed and any it could only match roughly. Hexagonal maps are not supported by the filler.

## Block out with built-in shapes

`BuiltInTilesets.basicShapes` is a tileset the engine draws itself, so it needs no image or tileset file. Its 32 × 32 tiles are plain geometry for blocking out a level before there is art: a full block, half and quarter blocks, a one-way plank, 45° and 22.5° slopes for floors and ceilings, rounded corners, a circle, a triangle and a diamond. Every tile collides as it looks, and tile ids never change.

```dart lib/blockout.dart
Entity addBlockout(World world) {
  final map = LevelMapData(tilesets: [BuiltInTilesets.basicShapes]);
  final ground = map.addLayer(name: 'Ground')..collides = true;
  for (var x = -10; x < 10; x++) {
    ground.cells.setCell(x, 4, TileCell.make(0, 0)); // a full block
  }
  ground.cells.setCell(2, 1, TileCell.make(0, 5)); // a one-way plank
  return world.createEntityWithComponents([
    TransformComponent(),
    LevelMapComponent(inline: map),
  ], name: LevelMaps.primaryName);
}
```
''',
  ),
  DocPage(
    id: 'tags-spawners',
    title: 'Tags, targets & spawners',
    group: DocGroups.gameplay,
    summary:
        'Label entities with tags, point at entities by name or tag with '
        'EntityTarget, and create players and enemies at spawn points with '
        'your own spawners.',
    keywords: [
      'TagComponent',
      'EntityTags',
      'findTagged',
      'allTagged',
      'EntityTarget',
      'SpawnComponent',
      'Spawner',
      'SpawnPoints',
      'TagLibrary',
      'EngineTags',
    ],
    body: r'''
Tags label entities so systems can find them: `player`, `enemy`, `boss`. Targets name an entity instead of holding it, so a camera or trigger authored in a level can find a player that is spawned later. Spawn points say what to create, and your game's spawners say how.

## Tags

A `TagComponent` holds any number of tags. The world keeps an index of them, so looking tagged entities up is cheap; don't query `TagComponent` and compare strings yourself.

```dart lib/tags.dart
void tagsAndTargets(World world) {
  final boss = world.createEntityWithComponents([
    TransformComponent(position: Vector3(900, 0, 0)),
    TagComponent.of(['enemy', 'boss']),
  ], name: 'Boss');
  boss.addTag('armored');

  final enemies = world.allTagged('enemy'); // switched-on ones, oldest first
  final player = world.findTagged('player'); // the oldest, or null
  debugPrint('${enemies.length} enemies; player: ${player?.name}');

  const target = EntityTarget.tag('boss');
  final found = target.resolve(world, null);
  debugPrint('the boss is ${found?.name}, armored: ${found?.hasTag('armored')}');
}
```

- `TagComponent('enemy')` holds one tag and `TagComponent.of([...])` several; blanks and repeats are dropped.
- On an entity, `hasTag`, `addTag` (which adds a `TagComponent` if there is none), `removeTag` and `tags` work directly. On the component, use `tags`, `has`, `add` and `remove`; the single `tag` getter is deprecated.
- `world.findTagged(tag)` returns the oldest switched-on entity with the tag, or null, and `world.allTagged(tag)` returns all of them, oldest first. Pass `includeInactive: true` to include switched-off entities. `world.tagsInUse` lists every tag in use.
- Switched-off entities (`entity.isActive = false`) are left out of tag lookups and targets, and so is everything under them in the hierarchy (`entity.isActiveInHierarchy`).
- Tag names use letters, digits, `_` and `-`, and are case-sensitive (`TagNames.isValid`).

`EngineTags.player` (`player`) is the tag the engine looks for by default: cameras, trigger zones, checkpoints and [dialogue](/docs/dialogue) find the player by it unless told otherwise.

## Targets

An `EntityTarget` names who a component means, and is looked up when it is needed:

| Target | Means | Saved as |
|---|---|---|
| `EntityTarget.name('Door')` | the oldest entity with that name | `{"name": "Door"}` |
| `EntityTarget.tag('player')` | the oldest entity with that tag, or all of them where several make sense | `{"tag": "player"}` |
| `EntityTarget.self()` | the component's own entity | `"self"` |
| `EntityTarget.none` | nobody | `null` |

Late binding is on purpose: a level's camera is authored long before the player it follows is spawned, and a respawn makes a new player entity. A stored entity id would be wrong both times; a name or a tag is right.

`resolve(world, owner)` returns one entity and `resolveAll(world, owner)` returns every entity a tag means. `EntityTarget.parse` reads the short text form: `self`, `#enemy` for a tag, and anything else as a name. Cameras (`VirtualCameraComponent.follow`), joints (`connectedBody`) and timeline bindings all take targets; see [Cameras](/docs/cameras) and [Timelines](/docs/timelines).

## Spawn points and spawners

A spawn point is an entity with a `SpawnComponent`. Its `spawner` field (`player` by default) names one of your game's `Spawner`s, which creates the entity. The spawn point is never consumed: it stays where it is, and the spawner reads its position and any tuning components beside it.

```dart lib/spawners.dart
final List<Spawner> spawners = [
  Spawner(
    id: 'player',
    label: 'Player',
    tags: const {'player'}, // what the spawned entity will carry
    spawn: (world, point) => world.createEntityWithComponents([
      // The spawn point's position; TransformComponent copies it.
      TransformComponent(
        position: point.getComponent<TransformComponent>()?.position,
      ),
      VelocityComponent(),
      InputComponent(),
      RectangleComponent(width: 32, height: 48),
      RigidBody2D(friction: 0, lockRotation: true),
      Collider2D(shape: ColliderShape2D.matchShape),
      TagComponent('player'),
    ], name: 'Player'),
  ),
];

Future<void> loadLevel(Engine engine, String path) async {
  await SceneLoader.loadAsset(engine.world, path);
  await LevelMaps.preload(engine.world);
  SpawnPoints.spawnAll(
    engine.world,
    spawners,
    onMissing: (point, id) => debugPrint('No spawner for "$id"'),
  );
}
```

`SpawnPoints.spawnAll` calls the matching spawner for every switched-on spawn point, oldest first, and returns what it created; a spawn point whose spawner is not in the list is skipped and reported to `onMissing`. `SpawnPoints.of(world, 'enemy')` lists the spawn points for one spawner and `SpawnPoints.first(world, 'player')` finds one. A spawner's `label`, `description` and `tags` are for editors and pickers; the editor's Play button calls your spawners the same way.

In a scene file a spawn point is an entity with two components:

```json
{
  "name": "PlayerSpawn",
  "components": [
    { "type": "TransformComponent", "fields": { "position": { "x": 0, "y": 200, "z": 0 } } },
    { "type": "SpawnComponent", "fields": { "spawner": "player" } }
  ]
}
```

## The project's tag library

A project keeps its tags, with a colour and a description for each, in `assets/project/tags.json` (`TagLibrary.defaultPath`): `{"version": 1, "tags": [{"name": "enemy", "description": "Hurts the player"}]}`, with colours as ARGB integers. The [editor](/editor) reads and writes it to offer tag pickers and to warn about near-duplicates such as `Players` beside `player`.

The engine does not need the file to run: tags on entities are plain strings. Tags that code relies on are declared rather than read from the file (`EngineTags.declared`), so an editor will not let you rename or delete `player`. A spawner's `tags` tell the editor that a tag is real in a level that has only a spawn point for it so far. In code, `TagLibrary.fromJson`, `withDeclared` and `TagNames.closest` (the tag a typo most likely meant) are there for tools of your own.
''',
  ),
];
