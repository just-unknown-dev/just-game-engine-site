import 'doc_models.dart';

/// The "Tools" pages: the level editor and the `just` command-line tool.
const List<DocPage> toolsDocs = [
  DocPage(
    id: 'editor',
    title: 'Level editor',
    group: DocGroups.tools,
    summary:
        'Install the level editor, give it an entry point that never ships, '
        'register your components, and find your way around its tools.',
    keywords: [
      'just_game_engine_editor',
      'JustGameEditorPlugin',
      'JustGameEngineEditor',
      'main_editor.dart',
      'kDebugMode',
      'ComponentDefinition',
      'RefreshableExtension',
      'EditorModule',
      'PrefabDefinition',
      'Level Designer',
      'Asset Store',
      'F1',
    ],
    body: r'''
The Just Game Engine editor is a level editor that runs inside your game while you develop it. You start the game's editor entry point in a debug build on Windows, macOS or Linux, and the running game is the scene you edit. 2D and 3D scenes, the Level Map, physics, cameras, timelines, materials and play-testing share one undo stack, and a profile or release build of the game holds none of it. The [editor overview](/editor) has screenshots and the feature list.

> **Tip:** A project made with `just create` already has the editor, its entry point and its wiring. Run `just game run --editor` and skip to "Open the editor" below.

## Install

The editor is a dev dependency: only your editor entry point imports it, so it never ships, and a release build also leaves out the native plugins only the editor brings. Add it from the project folder with `flutter pub add --dev just_game_engine_editor`, which puts `just_game_engine_editor: ^0.1.0-dev.1` under `dev_dependencies`. It needs `just_game_engine` 2.0.0-dev.2 or newer and Flutter 3.47.1.

## The editor entry point

Keep `lib/main.dart` free of the editor, and give the editor an entry point of its own, `lib/main_editor.dart`:

```dart lib/main_editor.dart
// The editor is a dev dependency, imported by this entry point alone.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine_editor/just_game_engine_editor.dart';

import 'main.dart' show MyGame; // the game, as lib/main.dart runs it

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kDebugMode is a compile-time constant: a profile or release build keeps
  // only the else branch, so it holds no editor.
  if (kDebugMode) {
    await _runEditor();
  } else {
    runApp(const MyGame());
  }
}

Future<void> _runEditor() async {
  final engine = Engine(
    config: const EngineConfig(
      extensions: [MyGameExtension()], // your components (below)
      defaultSystems: DefaultSystems.all,
    ),
  );
  await engine.initialize(); // boot the game's world here, as main.dart does
  final plugin = await JustGameEditorPlugin.register(
    engine: engine,
    modules: [MyGameModule()], // what your game adds to the editor
    spawners: mySpawners, // what Play spawns at each spawn point
    onReassemble: (plugin) => rewire(engine, plugin),
  );
  engine.start();
  runApp(
    MaterialApp(
      home: JustGameEngineEditor(engine: engine, plugin: plugin),
    ),
  );
}

/// Runs after every hot reload: what main handed the editor from code.
void rewire(Engine engine, JustGameEditorPlugin plugin) {
  plugin.syncModules([MyGameModule()]); // a module added since launch joins
  plugin.scope.spawners.value = mySpawners; // read at the next Play
}
```

- **Why `if (kDebugMode)`.** Because `kDebugMode` is a constant, the compiler keeps one branch and drops the other, so a release build of this file is the game alone. An early `if (!kDebugMode) { ...; return; }` is not the same: code after a `return` is still compiled in. `just doctor` checks that `main` keeps this shape.
- **`JustGameEditorPlugin.register`** returns null in a profile or release build, and where the editor cannot run (`JustGameEditorPlugin.supportsPlatform`). `JustGameEngineEditor` is then a plain `GameWidget`.
- **The `ignore_for_file` line** is there because `flutter_lints` reports a `lib/` import of a package that is only a dev dependency.
- **Spawners** are the game's own `Spawner` list. Play spawns through them, so the editor makes exactly the player the shipped game does.

## Run it

Run `flutter run -t lib/main_editor.dart -d windows` (or `macos`, `linux`), or `just game run --editor` in a project made with `just create`. Start it from the project folder: the editor reads and saves the project's own files, relative to the working directory.

## Hot reload

The editor runs in a debug build, so hot reload (**r**) and hot restart (**R**) work on it. A hot reload swaps the code but runs nothing again: not `main`, not a constructor. So after each reload the editor calls your `onReassemble`, where you hand over again what `main` did once (modules, spawners, systems added since launch). It then puts the component definitions in place again, including each `RefreshableExtension`'s, so a field you added shows in the inspector and is saved; rebuilds its docks, commands, prefabs and inspector sections from the modules; and brings live components up to a definition that changed.

Write what is built from code as a getter, not a `static final`, which is built once and kept: component definitions, prefabs, workspaces. Some changes still need a hot restart: a changed argument of a module or system that is already running, and the engine's configuration.

## Register your components

A component is described once, in the game, by a `ComponentDefinition`. That one description saves it, loads it in the shipped game, and builds its inspector section:

```dart lib/game/health.dart
import 'package:flutter/material.dart' show Icons;
import 'package:just_game_engine/just_game_engine.dart';

class MyHealthComponent extends Component {
  int maxHp = 3;
}

// A getter, so a hot reload builds it again from the code.
ComponentDefinition<MyHealthComponent> get myHealthDefinition =>
    ComponentDefinition(
      type: 'MyHealthComponent',
      create: MyHealthComponent.new,
      fields: [
        SchemaField(
          name: 'maxHp',
          kind: FieldTypes.integer,
          min: 0,
          read: (c) => (c as MyHealthComponent).maxHp,
          write: (c, v) => (c as MyHealthComponent).maxHp = v as int,
        ),
      ],
      // What the inspector shows. The game ignores it.
      hints: const ComponentHints(
        name: 'Health',
        group: 'Gameplay',
        icon: Icons.favorite,
        fields: {
          'maxHp': FieldHint(label: 'Max HP', scrub: ScrubHint(integer: true)),
        },
      ),
    );

// Registers the game's components on the engine it is given, and again,
// as the code now makes them, after a hot reload.
class MyGameExtension implements RefreshableExtension {
  const MyGameExtension();

  @override
  String get id => 'my_game';

  @override
  void install(EngineContext context) =>
      context.definitions.register(myHealthDefinition);

  @override
  void refresh(EngineContext context) =>
      context.definitions.refresh([myHealthDefinition]);
}
```

Give the extension to every engine the game makes, in `lib/main.dart` as well as in the editor entry point: `EngineConfig(extensions: [MyGameExtension()])`. A component with no registered definition is not shown, and is left out of the save with a warning in the log, because the shipped game could not load it. The engine has a `HealthComponent` of its own, so a game's component needs a type name of its own.

## Add an editor module

An `EditorModule` is where the editor's side of your game goes: prefabs, viewport tools, overlays, icons, checks and inspector editors for field types of your own. It lives in the editor entry point, or in a file only it imports, never in `lib/main.dart`'s imports:

```dart lib/editor/my_game_module.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine_editor/just_game_engine_editor.dart';

import '../game/health.dart';

class MyGameModule extends EditorModule {
  @override
  String get id => 'my_game';

  @override
  String get name => 'My Game';

  // In every Level Designer, beside the editor's own shapes.
  @override
  List<PrefabDefinition> get sharedPrefabs => [
    PrefabDefinition(
      id: 'my_game.enemy',
      name: 'Enemy',
      category: 'Enemies',
      icon: Icons.bug_report,
      color: const Color(0xFFE57373),
      placement: PrefabPlacement.point,
      defaultSize: const Size(32, 32),
      build: (position, size) => [
        TransformComponent(position: Vector3(position.dx, position.dy, 0)),
        RectangleComponent(width: size.width, height: size.height),
        MyHealthComponent(),
      ],
    ),
  ];
}
```

- **Prefabs** in `sharedPrefabs` appear in every Level Designer. Prefabs in `prefabs` make the module a Level Designer of its own, picked in the designer switch.
- **More contributions:** scene-tree icons (`entityIcons`), docks, toolbar buttons, settings pages, commands and key bindings, checks for the Problems dock, kinds of file for the Assets dock, and the tags its code relies on.
- **Lifecycle:** `onRegister` runs once and `onReassemble` after each hot reload. Everything a module contributes is rebuilt from it on every reload, so nothing piles up.
- **Built-ins:** the editor's own tools arrive the same way, as `BuiltInEditorModule`, `BuiltInMaterialsModule` and, for a game with 3D graphics, `BuiltInGraphicsModule`. Kits and plugins build their modules on `just_editor_core`, which this package re-exports.

## Open the editor

Press **F1** at run time to show or hide the editor. The game viewport shifts left, and the right panel shows the scene tree, the inspector and the Scenes list.

With no scene open, the viewport shows a start card: New scene, Reopen the last scene, the steps to a saved level, and the tools that need no scene. New scene asks for a name and whether the scene is 2D or 3D, and writes the same starter scene as `just game scene new`: a camera and the player's spawn point, plus, in 2D, the bounds the camera keeps to. The Scenes list searches, sorts and reorders: dragging a scene, or Alt+Up/Down, sets the play order in `scenes.json`, and the first scene is where the game starts.

## A tour of the tools

- **Scenes and saving.** A scene is one file, `assets/scenes/<name>.scene.json`, and the game loads the same file through `SceneLoader`. **Ctrl+S** saves it and any map files it uses; saving during a play-test saves the level as authored, not as the game left it. Autosave runs every 2 minutes by default and keeps backups in `.editor_backups/<scene>/`; when a backup holds changes the file lacks, opening the scene offers to recover them. Older scene formats are migrated as they open, and the file changes only when you save.
- **Level Designer.** **F3**, or the map icon on the play toolbar, opens it. Its tool strip has Draw (B), Paint (P), Sample (I), Stamp (S), Fill (G), Terrain (T), Erase (D), Select tiles (V) and Measure (M). A scene has one Level Map: tiles on square, isometric, staggered and hexagonal grids, with a built-in Basic shapes tileset (blocks, slopes, a one-way plank and more, each colliding as drawn) to block out a level before there is art. Everything you place becomes an entity on one of the map's layers, and Tiled maps import and export. A 3D scene gets a 3D Level Designer with its own Default 3D kit.
- **Inspector.** It is built from each component's `ComponentDefinition`, with an editor for every field type, a colour picker, and tag and entity pickers. Physics bodies get one card for 2D and 3D alike: body type, material presets, Fit to visual, collider handles in the viewport, and collision layers picked by name and saved to `assets/project/physics.json`.
- **Play-testing.** **F5** plays in place, **F6** pauses, **F10** steps one frame and **Shift+F5** restarts, with speeds from a quarter to double. Play spawns at every spawn point through your spawners, the game's camera brain drives the view, and **Stop** puts every authored entity back exactly as it was. **F4** shows what the game camera frames while you work.
- **Timeline.** The Timeline dock edits timelines that animate any component field, with a dope sheet, a curve editor, record mode and motion paths drawn in the viewport. See [Timelines](/docs/timelines).
- **Materials.** 3D materials (`*.material.json`) and 2D materials (`*.material2d.json`) are pictured in the Assets dock, edited in a Material window with a live preview, presets and variants, and dropped on what they draw. The 3D previews need Flutter GPU switched on in the game's runner ([Installation](/docs/installation)); the 2D ones need nothing.
- **Docks.** One tabbed panel at the foot of the editor, opened and shut with **F2**: Console (Ctrl+Shift+C), Assets (Ctrl+Shift+A), Timeline (Ctrl+Shift+T), Profiler (Ctrl+Shift+P), World (Ctrl+Shift+W), Search (Ctrl+Shift+F), History (Ctrl+Shift+H), Problems (Ctrl+Shift+E), Tags, Physics Layers and Animator. Problems lists what is wrong with the open scene, many items with a one-click fix. Tabs reorder and pop out, and the layout is remembered.

## Key shortcuts

These are the defaults; change any of them in Settings (Ctrl+,) under Keyboard. On macOS, read Cmd wherever this page says Ctrl.

| Key | Action |
|---|---|
| `F1` | Show or hide the editor |
| `F2` | Open or shut the dock panel |
| `F3` | Open or close the Level Designer |
| `F4` | The game camera preview |
| `F5` / `Shift+F5` | Play or stop / restart |
| `F6`, `F10` | Pause or resume, step one frame |
| `Ctrl+S` | Save the scene |
| `Ctrl+Z` / `Ctrl+Shift+Z` or `Ctrl+Y` | Undo / redo |
| `Ctrl+C`, `Ctrl+V`, `Ctrl+D`, `Delete` | Copy, paste, duplicate, delete |
| `Q`, `W`, `E`, `R` | All, Move, Scale, Rotate |
| `F` / `Shift+F` | Frame the selection / everything |
| `Ctrl+Shift+G` | The Asset Store window |

## Platforms

- **The package compiles everywhere Flutter does**, so a game that imports it in its editor entry point still builds for Android, iOS and the web.
- **Editing runs on a desktop** (Windows, macOS or Linux), in a debug build launched from the project folder. On a phone, a tablet or the web the app has only its bundled, read-only assets, so `register` returns null and the game runs on its own.
- **macOS:** a sandboxed debug app cannot write the project folder. Set `com.apple.security.app-sandbox` to `false` in `macos/Runner/DebugProfile.entitlements`; the release entitlements stay as they are. The Asset Store window also needs `com.apple.security.network.client` there, which `just create` adds and `just doctor` checks. Cmd is the primary modifier, and Backspace deletes as Delete does.

## Asset Store, plugins and kits

A module reaches other projects inside a package. There are two kinds:

| Kind | What it brings | In the game's pubspec |
|---|---|---|
| Plugin | Tools for the editor only, such as a window, a dock or an asset editor. Nothing of it ships. | `dev_dependencies` |
| Kit | Game code and its editor half: components and systems the game runs, plus the prefabs, tools and inspector fields to place them. | `dependencies` |

- **From the Asset Store.** Ctrl+Shift+G opens the store window, to browse, install, update and remove items. In a terminal, `just add <id>`, `just remove <id>` and `just store list` do the same. The store adds the package to `pubspec.yaml` and rewrites `lib/editor/store_modules.g.dart` (the editor modules) and `lib/game/store_extensions.g.dart` (the kits' engine extensions), which a project made with `just create` already uses. Hot restart (**R**) the editor after installing code.
- **By hand.** Add the package to `pubspec.yaml`, add its module to `modules` in `lib/main_editor.dart`, and for a kit, give its engine extension to every engine the game makes, in `lib/main.dart` too. Import a package's editor library from `lib/main_editor.dart` only.

First-party modules include `PlatformerModule` (`just_platformer_kit`), `ThirdPersonModule` (`just_third_person_kit`), `WorldBuilderModule` (`just_world_builder_kit`), `SpriteStudioModule` (`just_sprite_editor`) and `InputEditorModule` (`just_input_editor`). The [editor's README](https://github.com/just-unknown-dev/just-game-engine-editor) explains how to make and publish a plugin or kit of your own.
''',
  ),
  DocPage(
    id: 'cli',
    title: 'The just CLI',
    group: DocGroups.tools,
    summary:
        'Install just, create a game with it, and run, build, check, upgrade '
        'and migrate the game with the just game commands.',
    keywords: [
      'just',
      'ju',
      'just_core_cli',
      'just_game_engine_cli',
      'just create',
      'just game run',
      'just game build',
      'just game scene',
      'just game check',
      'just game doctor',
      'just game upgrade',
      'just game migrate',
      'just upgrade',
      'just.json',
    ],
    body: r'''
`just` is the Just ecosystem's command-line tool. It comes in two packages, and the [CLI overview](/cli) shows them side by side:

- **`just_core_cli`** (0.1.1) is the tool itself. It knows no product of its own: it makes projects, keeps their tools on versions that work together, checks their setup, links them to local checkouts, changes them all or nothing, and runs the commands and hooks that plugins add.
- **`just_game_engine_cli`** (0.1.2) is the game plugin. It adds `just game ...`: run the game and its editor, build releases that provably hold no editor, manage the levels, keep the engine's packages on versions that work together, and keep saved files in the current formats. Every game made with `just create` has it as a dev dependency, and `just` runs it at the version the project resolved.

## Install

```bash
dart pub global activate just_core_cli
just doctor
```

Or download `just` and `ju` for Windows, macOS or Linux from the [releases](https://github.com/just-unknown-dev/just-core-cli/releases). The install scripts in the repository's `tool/` folder (`install.sh` and `install.ps1`) do it for you, and never put this `just` in front of another one. Then `just doctor` checks Flutter, the tools' versions and the rest.

- **Flutter** is found through `FLUTTER_ROOT` first, then the SDK that last fetched the project's packages, then `flutter` on the `PATH`.
- **Projects pin their own `just`.** A project lists `just_core_cli` in its dev dependencies, and a global `just` run inside it hands over to that version (all but `upgrade`, which moves the pin itself), so a team runs the same tool whatever each person installed.

## just and ju

`ju` is the same tool under a second name, for machines where `just` is already another program, such as the `just` command runner. Every command on this page works with `ju` too.

## Create a game

```bash
just create my_game
just create space_rocks --title "Space Rocks" --org com.mystudio --platforms windows,macos,web
```

The folder name becomes the Dart package name, so it must be a valid one. `create` runs `flutter create`, writes `just.json`, adds `just_core_cli` and the kind's plugin to the dev dependencies as pub.dev versions, fetches the packages, and hands the project to the plugin's `create` hook. For a game, that is `just game init`: the game template on the engine's version set, the first level, the editor through the Asset Store, and Flutter GPU switched on for a 3D game. On a failure the folder is deleted when `create` made it, or emptied when it was there already, empty.

| Option | What it does |
|---|---|
| `--kind` | What to make. `game`, the default, is filled in by `just_game_engine_cli`. |
| `--template`, `-t` | What to start from, passed to the plugin: `empty` by default, or a template from the Asset Store. |
| `--title` | The project's name as people see it (default: from the folder). |
| `--org` | The reverse-domain organisation for app ids (default `com.example`). |
| `--platforms` | The platforms to create, separated by commas (default `windows,macos,linux,android,ios,web`). |
| `--local <folder>` | Points every `just_*` package in that folder at its checkout (`pubspec_overrides.yaml`), for working on the ecosystem itself. |
| `--source <catalog>` | Where the plugin finds a `--template`; repeat it for several catalogs. |

`just.json` holds the project's title and the tool set it is on. Its `entry.game` and `entry.editor` keys change where the game and the editor start; they default to `lib/main.dart` and `lib/main_editor.dart`.

## The game commands

| Command | What it does |
|---|---|
| `just game run` | Runs the game, or with `--editor` the game with the editor over it. |
| `just game build <platform>` | A release build, then a check that it holds no editor. |
| `just game scene ...` | Makes, lists, renames, deletes, orders, migrates and validates the scenes in `assets/scenes/`. |
| `just game check` | No editor code reachable from the game, and saved files in formats this engine reads. |
| `just game doctor` | Checks the game's setup. |
| `just game upgrade` | Moves the engine's packages in `pubspec.yaml` to the versions this plugin carries. |
| `just game migrate` | Rewrites old scenes, timelines and animator graphs in the current formats. |

`just help game build` shows any command's own help. Some examples:

```bash
just game run --editor                        # the editor, on this desktop
just game run --release                       # the game in release
just game build windows                       # build, then check it holds no editor
just game build web -- --wasm                 # anything after -- goes to flutter build
just game scene new cave --after level_01     # a level, as the editor's New scene writes it
just game scene order level_01 cave           # the play order; the first is where the game starts
just game check release-build --platform web  # check an existing release build
just game upgrade --check                     # what the engine's packages would move to
just game migrate --check                     # whether old files could be migrated now
```

### run

- `--editor` (`-e`) runs `lib/main_editor.dart`, on this desktop unless `--device` says otherwise. The editor runs in debug builds only, so `--editor` with `--release` or `--profile` is refused.
- `--device` (`-d`), `--profile` and `--release` go to `flutter run`, as does anything after `--`. The command hands the terminal to `flutter run` and exits with its code.

### build

- `just game build <platform>` first checks that no editor code is reachable from `lib/main.dart`, then runs `flutter build <platform> --release`, then reads the build's files for editor code and, in a 2D game, 3D physics.
- The build check reads `windows`, `macos`, `linux` and `web` builds (the JavaScript, and the WebAssembly from a `--wasm` build). Other platforms, such as `apk` or `ios`, are checked through their source only.
- `--editor-entry` builds `lib/main_editor.dart` instead: its release build must be the game, with no editor in it.

### scene

- `list` shows the play order first, then any scene not in it.
- `new [<name>]` makes a scene as the editor does, with a camera and a player spawn. `--3d` makes a 3D scene, `--after <scene>` places it in the play order, and `--unlisted` leaves it out. With no name, one is suggested.
- `rename <old> <new>` renames the file, the name inside, and its place in the play order.
- `delete <name>` puts a copy in `.editor_trash/scenes/` and takes the scene out of the play order.
- `order <name>...` sets the play order. A scene left out stays on disk, unlisted.
- `migrate [<name>...]` rewrites scenes saved in an older format in the current one (`SceneFormat.current`). `--engine-only` goes ahead with the engine's rules alone, though a kit may have its own.
- `validate [<name>...]` checks scenes without changing them: they parse, their format is readable, entity names are unique and parents exist.

Commands that write refuse while the editor has the project open, because it would save over the change. Close the editor, make the change in it, or pass `--force`.

### check, doctor, upgrade and migrate

- **`check [release-imports] [release-build] [formats]`** runs the checks named, or `release-imports` and `formats` when none is named. `--platform` picks the build `release-build` reads: `windows`, `macos`, `linux` or `web` (default: this desktop).
- **`doctor`** checks that the editor entry point keeps the editor to debug builds, that the game imports no editor and ships no editor package, the git ignores for `.editor_backups/`, `.editor_logs/` and `.editor_trash/`, the macOS network entitlement for the Asset Store, Flutter and Dart against the engine's floors, the engine's packages against the version set, and store items linked to checkouts that are gone.
- **`upgrade`** makes one-line bumps of the engine's packages in `pubspec.yaml` to the plugin's version set. A package already as new as the set, or newer, stays. It runs no `pub get`, and `--check` only says what would move. You normally run it through `just upgrade`.
- **`migrate`** rewrites scenes, timelines and animator graphs saved in an older format. `--check` changes nothing and fails, saying why, when a migration could not run now; `--engine-only` goes ahead with the engine's rules alone though a kit may have its own; `--force` goes ahead though the editor is open.

## Project commands

These come from `just_core_cli` and run each plugin's hooks:

- **`just check`** runs every installed plugin's checks, and fails when nothing was checked.
- **`just doctor`** checks Flutter, the tools, `just.json` and links, then each plugin's checks.
- **`just upgrade`** moves the tools, then each plugin's packages, with `pub get`, in one transaction, then runs the plugins' migrations. Anything after `--` goes to them: `just upgrade -- --engine-only`.
- **`just dev link <folder>`** points the project at local checkouts; **`just dev unlink`** undoes it.
- **`just version`** and **`just help`**.

The Asset Store is a plugin too: it adds `just store`, `just add` and `just remove` ([Level editor](/docs/editor)).

## Hooks

The game plugin's `just_plugin.json` gives `just` six hooks:

| Hook | Command | When |
|---|---|---|
| `create` | `game init` (hidden) | `just create` made a Flutter project: lay the game template over it, add the editor through the Asset Store, switch Flutter GPU on for a 3D game |
| `check` | `game check` | `just check`: release imports and saved formats |
| `doctor` | `game doctor` | `just doctor`: the game's setup |
| `upgrade` | `game upgrade` | `just upgrade`, inside its transaction: bump the engine's packages |
| `migrate` | `game migrate` | `just upgrade`: with `--check` before it changes anything, again with the new packages before it commits, then for real |
| `link` | `game link` (hidden) | after `just dev link`, and around `just dev unlink`: register Asset Store items among the checkouts |

## Global flags and exit codes

Every command takes these, before or after its name but before a `--`:

- `--json`: one JSON document on stdout, messages on stderr.
- `--yes`: go ahead without asking, for scripts and CI. It never allows a plugin that is not trusted.
- `--verbose`: say more.
- `--project <folder>`: run on that project. A folder without a `pubspec.yaml` is no project.

| Code | Meaning |
|---|---|
| 0 | Done, or nothing to do. |
| 1 | Failed. A change that fails is rolled back first. |
| 2 | Called wrongly: an unknown command, a missing argument or a bad option. |
| other | A plugin's command, or a run handed to the project's pinned `just`, exits with that process's code; a process ended by a signal gives 128 plus the signal's number. |

Two steps come after a change is kept, and a failure there exits 1 while keeping it: a plugin's migrations at the end of `just upgrade`, and a plugin's `link` hook after `just dev link` or `unlink`. The message says which.

## Transactions and the trash

- **All or nothing.** Every change to a project is journalled and backed up first. A failure puts every byte back, and a crash is rolled back the next time a command changes the project.
- **One change at a time.** A project lock says who holds it, and is taken over when its holder stops renewing it or has stopped running.
- **The trash.** What a change replaces or removes goes to `.just_trash/<tool>/`, unless the tool keeps its own. The game commands and the Asset Store use the editor's `.editor_trash/`, so you can restore from the editor.
- **Pubspecs keep every other byte.** A tool edits only its own marked block of `pubspec.yaml`, and leaves comments, order and line endings as they were.
- **Plugin trust.** The ecosystem's own plugins run without asking when they come from a local checkout, from github.com/just-unknown-dev, or from pub.dev under the names the ecosystem publishes there (`just_game_engine_cli` and `just_asset_store`). Any other plugin is asked about once in a terminal, and the answer is kept in the project's `just.json` or your user `plugins.json`.

## As a library

`package:just_game_engine_cli/just_game_engine_cli.dart` holds the toolkit the commands use, for a game's own scripts and tests. A script that reads a game on disk:

```dart tool/check_release.dart
import 'package:just_game_engine_cli/just_game_engine_cli.dart';

void main() {
  final project = JustProject('.');
  final rules = project.releaseRules(); // the editor's packages + each store item's
  final reachable = project.editorReachableFrom('lib/main.dart', rules: rules);
  if (reachable.isNotEmpty) throw StateError('The editor would ship: $reachable');
}
```

- **On every platform, the web included**, the text-based checks work: `GameSet` (the engine's packages at versions that work together), `GameTemplate`, `GameEntries`, `ReleaseRules`, `ReleaseImports`, `ReleaseBuild` and `FormatsCheck`.
- **Where `dart:io` is**, the `GameProject` extension on `JustProject` reads a game on disk: `releaseRules()`, `editorReachableFrom()`, `checkReleaseBuild()`, `checkFormats()` and `editorIsOpen()`.
- **To write a plugin of your own**, build on `just_core_cli`: a package with a `just_plugin.json` and a `bin/just_plugin.dart` adds commands. Its repository has an example plugin that adds `just hello`.
''',
  ),
];
