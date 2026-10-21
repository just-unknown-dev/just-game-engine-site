import 'doc_models.dart';

/// The Audio & content pages: audio, assets, localization and dialogue.
const List<DocPage> audioContentDocs = [
  DocPage(
    id: 'audio',
    title: 'Audio',
    group: DocGroups.audioContent,
    summary:
        'Play music and sound effects through engine.music and engine.sfx, '
        'attach sounds to entities, place them in 3D, and start audio '
        'correctly on the web.',
    keywords: [
      'AudioEngine',
      'MusicManager',
      'SoundEffectManager',
      'AudioSourceComponent',
      'AudioStreamComponent',
      'AudioSystem',
      'AudioListenerComponent',
      'AudioChannel',
      'AudioEffect',
      'AudioRolloff',
      'deferAudioUntilInput',
      'just_audio_engine',
    ],
    body: r'''
Audio comes from `just_audio_engine`. `engine.music` plays one music track, `engine.sfx` plays sound effects, and `engine.audio` is the `AudioEngine` underneath, with channels, effects and 3D sound. For sounds that belong to things in the world, put an `AudioSourceComponent` on an entity.

Paths are asset paths, so list your audio folder under `flutter: assets:` in `pubspec.yaml`.

## Music and sound effects

```dart lib/sounds.dart
import 'package:just_game_engine/just_game_engine.dart';

Future<void> startMusic(Engine engine) =>
    engine.music.play('assets/audio/theme.ogg', volume: 0.6, fadeIn: true);

Future<void> playJump(Engine engine) async {
  await engine.sfx.play('assets/audio/jump.wav', volume: 0.8);
}

Future<void> stopMusic(Engine engine) => engine.music.stop(fadeOut: true);
```

- `engine.music` (a `MusicManager`) has `play` (looping by default; `fadeIn` with `fadeDuration`, 2 s by default), `pause`, `resume`, `stop` (with `fadeOut`), `setChannelVolume` and `isPlaying`. Playing a new track fades the current one out over a second.
- `engine.sfx` (a `SoundEffectManager`) has `play`, which takes `volume`, `loop`, `pan`, `pitch`, `speed`, `effects` and `channel` and returns an id (null when the file could not load), plus `stop(id)`, `stopAll()`, `setVolume(id, volume)` and `setChannelVolume`.
- `engine.audio` adds `setMasterVolume`, `mute`, `unmute`, `toggleMute`, `preload(paths)` to load sounds before a level starts, and `unloadSource(path)` to free one you no longer need.

## Channels and effects

Every sound plays on an `AudioChannel`: `master`, `music`, `sfx`, `voice` or `ambient`. A channel's volume scales every sound on it, and each channel is backed by an `AudioBus` in `engine.audio.busGraph`.

```dart
engine.music.setChannelVolume(0.5);
engine.sfx.setChannelVolume(0.8);
engine.audio.setChannelVolume(AudioChannel.ambient, 0.4);
```

Effects are applied per voice when playback starts. Pass them as `effects:` to `engine.sfx.play`, `AudioSystem.playOneShot` or an `AudioSourceComponent`: `AudioEffect.reverb(roomSize: 0.8)`, `AudioEffect.lowpass(frequency: 800)`, `AudioEffect.highpass`, `AudioEffect.eq` and `AudioEffect.delay`. `AudioEffectType` also lists `bandpass`, `distortion` and `chorus`, which you build with `AudioEffect(type, params: {...})`.

## Sounds on entities

`AudioSourceComponent` is data; `AudioSystem`, a default system, plays it. A source starts as soon as the system sees it (`playOnAdd`, true by default), stops when the component or its entity goes, and pauses while the entity is switched off.

```dart lib/world_sounds.dart
/// A looping sound placed in the world: full volume within 50 units,
/// fading to silence at 800, muffled towards the far end.
Entity addWaterfall(World world) => world.createEntityWithComponents([
  TransformComponent(position: Vector3(600, 100, 0)),
  AudioSourceComponent(
    clipPath: 'assets/audio/waterfall.ogg',
    loop: true,
    channel: AudioChannel.ambient,
    is3d: true,
    minDistance: 50,
    maxDistance: 800,
    farCutoff: 1500,
  ),
], name: 'Waterfall');

/// From a system: played once, with nothing added to an entity.
void playCoin(World world, Entity coin) =>
    world.getSystem<AudioSystem>()?.playOneShot(
      'assets/audio/coin.wav',
      position: coin.getComponent<TransformComponent>()?.position,
    );

/// A third-person game hears from the player, facing like the camera.
void hearFrom(Entity player) =>
    player.addComponent(AudioListenerComponent(faceCamera: true));
```

Control a source with `play()` (from the start), `pause()`, `resume()` and `stop()`. Each asks `AudioSystem` to act at its next update and never changes the component's saved fields, so a scene saved while a sound plays still starts it next time. A source's `volume` is followed while it plays; `pan`, `loop`, `pitch`, `speed` and `effects` are read when it starts.

For long music or ambience, use `AudioStreamComponent(path: ...)`, which streams the file instead of loading it whole. It loops on the `music` channel by default, can fade in over `fadeInDuration`, and has the same `play`, `pause`, `resume` and `stop`.

## 3D sound and the listener

With `is3d: true` a source is heard from where its entity is, relative to the listener:

| Field | Default | What it does |
|---|---|---|
| `minDistance` | 1 | Full volume within this distance. |
| `maxDistance` | 50 | Silent at and beyond it (unless `rolloff` is `AudioRolloff.none`). |
| `rolloff` | `AudioRolloff.inverse` | How the sound fades between the two: `inverse`, `linear` or `none`. |
| `farCutoff` | 0 | Low-pass cutoff in Hz the sound is muffled to at `maxDistance`; 0 keeps it clear. |
| `dopplerLevel` | 0 | How much movement bends the pitch; 1 is the real-world effect for a world in metres. |

Distances are in world units: pixels in a 2D game, metres in 3D. A 2D game usually needs larger distances than the defaults, as in the waterfall above. A 3D source is not also panned, so its `pan` is ignored.

`AudioListenerComponent` marks the entity that hears. It hears from the entity's position and faces the way the entity's rotation turns the world's forward (+Z) and up (−Y). `atCamera: true` hears from the output camera's position instead, and `faceCamera: true` faces the way the camera does. Only the first listener counts; with none, `AudioSystem` hears from the camera.

## Audio on the web

Browsers keep audio silent until the player interacts with the page. On the web the engine therefore starts audio at the first key or pointer press instead of in `initialize()`. `EngineConfig(deferAudioUntilInput: ...)` changes this: null (the default) means on the web only, true means everywhere and false means never.

- A sound you play before then starts the audio engine early, and the browser may keep it silent.
- A one-shot asked for before audio has started is dropped, not queued.
- A "click to start" screen is a simple way to make sure the first press happens before your music.

When the app goes to the background, `GameWidget` pauses the music and the world's sounds and mutes the rest, and restores exactly that when the app returns. You can do the same yourself with `engine.suspendAudio()` and `engine.resumeAudio()`. See [Platforms](/docs/platforms) for other web differences.

## Known limitations

These wait on `just_audio_engine`:

- `AudioStreamComponent.channel` is handed to the stream, but the channel's volume does not apply to it.
- A playing sound's pitch, pan, speed and loop cannot change until it plays again.
- A stream that plays to its end still reports `isPlaying`.
''',
  ),
  DocPage(
    id: 'assets',
    title: 'Assets & storage',
    group: DocGroups.audioContent,
    summary:
        'Load images, JSON, text and sounds through engine.assets, group and '
        'reference-count them, and keep data between runs with engine.cache.',
    keywords: [
      'AssetManager',
      'GameAssetBundle',
      'AssetScope',
      'AssetType',
      'ImageAsset',
      'JsonAsset',
      'CacheManager',
      'MemoryScope',
      'MemoryProfiler',
      'just_storage',
    ],
    body: r'''
`engine.assets` is the engine's `AssetManager`: it loads, caches and releases images, sounds, text, JSON and binary files. `engine.cache` is its `CacheManager`, which keeps strings, JSON and binary data between runs.

## The asset manager

Each engine has its own `AssetManager`, reading from the Flutter asset bundle. It is ready as soon as the engine is made, before `initialize()`. Every file it loads must be listed under `flutter: assets:` in `pubspec.yaml`, by itself or through its folder; a folder entry does not include its subfolders.

```dart lib/level_data.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:just_game_engine/just_game_engine.dart';

Future<void> loadLevelData(Engine engine) async {
  final waves = await engine.assets.loadJson('assets/data/waves.json');
  final sky = await engine.assets.loadImage('assets/images/sky.png');
  debugPrint('${(waves.data as List).length} waves; sky ${sky.width}x${sky.height}');

  // Later, anywhere: the same asset, already loaded.
  final again = engine.assets.getImage('assets/images/sky.png');
  debugPrint('still loaded: ${again?.isLoaded}');
}
```

- `loadImage`, `loadAudio`, `loadText`, `loadJson` and `loadBinary` load one file each; `load(path, type)` takes an `AssetType`, and `loadMultiple(paths, type)` loads several in parallel.
- Loading a path that is already loaded returns the cached asset. `getImage`, `getJson` and `get<T>(path)` return what is loaded, or null.
- `ImageAsset` has `image` (a `dart:ui` image), `width` and `height`; `JsonAsset` has the decoded `data`; `TextAsset` has `content`.
- `unload(path)` unloads every type loaded at that path, and `unloadAll()` everything.
- `totalMemoryUsage`, `assetCount` and `getCacheStats()` say what is loaded.

Image, audio, text, JSON and binary loaders are built in. The atlas loader is registered the first time `SpriteAtlas.fromAsset` runs. Fonts, shaders and models have no loader until you add one with `registerLoader(type, loader)`; loading one before that throws an `AssetLoadException`. Engine loaders that need the asset manager take it as a parameter, for example `Sprite.fromAsset(path, assets: engine.assets)`; see [Sprites](/docs/sprites).

## Groups and reference counting

A `GameAssetBundle` is a named group of assets that load and unload together. It was called `AssetBundle` in 1.x, which clashed with Flutter's class of that name.

When several screens or levels share assets, count references instead. `acquire(path, type)` loads or reuses an asset and adds one to its count; `release(path)` takes one away and unloads the asset when the count reaches zero. An `AssetScope` releases everything it acquired in one `dispose()` call, which suits one scope per level or screen.

```dart lib/level_assets.dart
final menuAssets = GameAssetBundle(
  name: 'menu',
  assetPaths: ['assets/images/title.png', 'assets/audio/menu.ogg'],
  assetTypes: [AssetType.image, AssetType.audio],
);

Future<void> showMenu(Engine engine) => menuAssets.load(engine.assets);
void leaveMenu(Engine engine) => menuAssets.unload(engine.assets);

/// One scope per level: leaving the level releases what it used.
Future<AssetScope> enterLevel(Engine engine) async {
  final scope = AssetScope(engine.assets);
  await scope.acquireImage('assets/images/cave_background.png');
  await scope.acquireJson('assets/data/cave_waves.json');
  return scope; // call scope.dispose() when the level ends
}
```

`engine.assets.createScope()` makes a `MemoryScope` from `just_memory` instead. Pass it to `acquireImageScoped(path, scope)` and the other `...Scoped` methods, and register any clean-up of your own with `scope.own(callback)`. Disposing the scope runs everything it owns, newest first.

## Tests and other bundles

The asset manager reads from the engine context's bundle, Flutter's `rootBundle` unless you say otherwise. To load from a bundle of your own, for example in a test, make the engine with `Engine(context: EngineContext(bundle: myBundle))`. A context you pass in is yours to dispose. See [Testing](/docs/testing).

## The cache

`engine.cache` stores small amounts of data between runs: settings, progress, downloaded content.

```dart lib/settings.dart
Future<void> saveVolume(Engine engine, double volume) =>
    engine.cache.setJson('settings', {'musicVolume': volume});

Future<double> loadVolume(Engine engine) async {
  final json = await engine.cache.getJson('settings');
  if (json is Map && json['musicVolume'] is num) {
    return (json['musicVolume'] as num).toDouble();
  }
  return 1.0;
}
```

- `setString` and `getString`, `setJson` and `getJson`, and `setBinary` and `getBinary` (a `Uint8List`) store and read values. Any string is a valid key.
- `remove(key)` deletes one entry. `clearAll()` deletes the cache's own entries only: the rest of the store, including players' key bindings, is left alone.
- Strings and JSON go to the engine's key-value store under the `just_game_engine.cache/` prefix; binary data goes to a database of its own.
- Where the key-value store cannot be opened (a test, a headless run), everything stays in memory for the run (`isUsingMemoryFallback`). If only the database fails, binary data stays in memory (`isBinaryInMemory`).

## The engine's storage file

The engine keeps its data apart from your app's. On desktop and mobile its key-value store is `<application support>/just_game_engine/just_storage.json`, beside the `just_storage.json` your app opens with `JustStorage.standard()`, not inside it: two writers on one file could drop each other's keys. On the web it is browser storage under the engine's own `just_game_engine/` key prefix.

On the first launch of 2.0, the engine moves the keys it left in the shared file in 1.x into its own store, and removes the copies of bundle assets that 1.x cached. Assets from the bundle are never copied into the cache, so an app update's new images show at once.

## Memory diagnostics

The engine re-exports the `just_memory` diagnostics it uses: `MemoryProfiler`, `PoolManager` and the snapshot types. `engine.cache.captureProfile()` returns a `MemoryProfileSnapshot`, and `engine.assets.getCacheStats()` reports loaded assets by type and their memory use. For the profiling tools and stats overlays, see [Debugging](/docs/debugging).
''',
  ),
  DocPage(
    id: 'localization',
    title: 'Localization',
    group: DocGroups.audioContent,
    summary:
        'Translate your game with a LocalizationManager on '
        'engine.context.localization: string files per locale, namespaces, '
        'fallbacks, plurals, selects and widgets that follow the locale.',
    keywords: [
      'LocalizationManager',
      'LocaleStringTable',
      'LocalizationScope',
      'LocalizedText',
      'LocalizationBuilder',
      'LocaleSelector',
      'L10nContext',
      'StringInterpolator',
      'i18n',
    ],
    body: r'''
A `LocalizationManager` holds your string tables and the current locale. Set it as `engine.context.localization` and every `GameWidget` showing the engine provides it to the widgets drawn over the game, and the dialogue system can use the same strings.

## String files

Strings are JSON files, one per locale (and per namespace, if you use them). Keys can be flat or nested; nested keys are joined with dots, so `{"ui": {"back": "Back"}}` gives the key `ui.back`. List the folder under `flutter: assets:`.

```json assets/l10n/ui_en.json
{
  "ui": {
    "start_game": "Start game",
    "back": "Back"
  },
  "hud.greeting": "Welcome back, {name}!",
  "hud.coins": "{count, plural, =0{No coins} =1{One coin} other{{count} coins}}",
  "hud.arrived": "{who, select, male{He arrived} female{She arrived} other{They arrived}}"
}
```

## Set up the manager

```dart lib/l10n.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show Locale;
import 'package:just_game_engine/just_game_engine.dart';

Future<void> setUpLocalization(Engine engine) async {
  final l10n = LocalizationManager(); // falls back to English
  await l10n.loadAll(
    const [Locale('en'), Locale('fr')],
    'assets/l10n/ui_{locale}.json',
    ns: 'ui',
  );
  l10n.setLocale(const Locale('fr'));
  engine.context.localization = l10n; // before building the GameWidget

  debugPrint(l10n.t('ui.back'));
  debugPrint(l10n.t('hud.coins', args: {'count': 3}));
  debugPrint(l10n.tr('hud.greeting', {'name': 'Aria'}));
}
```

- `load(locale, path, ns: ...)` loads one file; `loadAll(locales, template, ns: ...)` loads one per locale, replacing `{locale}` with the locale's tag (`en`, `fr_CA`, `zh_Hans`). A missing file is skipped quietly; a file that is there but malformed is logged.
- `registerMap(locale, strings)` and `register(locale, table)` add strings from code, for tests or downloaded content.
- `t(key, args: ..., locale: ..., ns: ...)` looks a key up; `tr(key, args)` is the short form. `has(key)` and `raw(key)` read without filling anything in.
- `setLocale(locale)` switches language and notifies `localeChanged`, a signal the widgets below listen to.

## Namespaces

A namespace keeps one area's strings in tables of their own: `ui` for menus, `game` for gameplay, `dialogue` for lines (`LocalizationManager.dialogueNamespace`). Without `ns:` strings go to `LocalizationManager.defaultNamespace`.

A namespace does not prefix keys. `t('ui.back')` searches every namespace, the default one first and then the others in the order they were loaded; `t('ui.back', ns: 'ui')` searches only `ui`. Files loaded for the same locale and namespace merge, and a key in a later file replaces the same key from an earlier one.

## Fallbacks

For a key looked up in `fr_CA`, the manager tries the `fr_CA` tables, then `fr`, then the fallback locale (`en` unless you pass `LocalizationManager(fallbackLocale: ...)`), and finally returns the key itself, so missing strings are obvious on screen. A locale with a script keeps its own tables: `zh_Hans_CN` falls back to `zh_Hans`, then `zh`, and its file is named like `ui_zh_Hans.json`.

## Variables, plurals and selects

`{name}` is replaced by the `name` argument. Two ICU-style forms choose text by an argument:

- `{count, plural, =0{...} =1{...} one{...} other{...}}`: an exact `=N` wins, then `one` for exactly 1, then `other`. A count with a fraction matches only an `=N` equal to it, so 1.5 takes `other`. There are no `few` or `many` categories.
- `{who, select, male{...} female{...} other{...}}`: the branch named by the argument's value, else `other`.

Variables inside a branch are filled in too, as in `other{{count} coins}`. Forms are resolved one level deep: a plural inside a plural is not.

## In widgets

The widgets are in `package:just_game_engine/widgets.dart`. Under a `GameWidget` they find the engine's manager themselves; elsewhere, wrap your widgets in `LocalizationScope(manager: l10n, child: ...)`.

```dart lib/menu.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/widgets.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const LocalizedText('ui.start_game'),
      LocalizationBuilder(
        builder: (context, l10n) =>
            Text(l10n.t('hud.coins', args: {'count': 3})),
      ),
      const LocaleSelector(
        locales: [Locale('en'), Locale('fr')],
        labels: {'en': 'English', 'fr': 'Français'},
      ),
    ],
  );
}
```

- `LocalizedText(key, args: ..., ns: ..., style: ...)` is a `Text` that rebuilds when the locale changes.
- `LocalizationBuilder` rebuilds its subtree on every locale change and hands you the manager.
- `LocaleSelector` shows a tappable label for each locale and switches to it.
- `context.t(key)` and `context.tr(key, args)` (the `L10nContext` extension) look a key up in the nearest scope. They do not rebuild when the locale changes, so use them inside a `LocalizationBuilder`.
- `LocalizationScope.of(context)` returns the manager itself.

Strings resolved once stay as they were when the locale changes: for example, `SubtitleTrack.localized` resolves its cues when it is made. See [Dialogue & subtitles](/docs/dialogue).
''',
  ),
  DocPage(
    id: 'dialogue',
    title: 'Dialogue & subtitles',
    group: DocGroups.audioContent,
    summary:
        'Write branching dialogue in Yarn Spinner 2.x, run it with '
        'DialogueManager and DialogueRunner, show it with the ready-made '
        'widgets, and time subtitles with SubtitleController.',
    keywords: [
      'DialogueManager',
      'DialogueRunner',
      'DialogueSystem',
      'DialogueComponent',
      'DialogueTriggerComponent',
      'DialogueBoxWidget',
      'DialogueChoicesWidget',
      'DialogueLocalizer',
      'YarnParser',
      'SubtitleController',
      'SubtitleTrack',
      'SubtitleOverlay',
      'Yarn Spinner',
    ],
    body: r'''
Dialogue is written in Yarn Spinner 2.x `.yarn` files. A `DialogueManager` loads them and runs them; each running conversation is a `DialogueRunner` that reports its lines and choices through signals; `DialogueBoxWidget` and `DialogueChoicesWidget` show them. Timed subtitles for cutscenes and voice-over use a `SubtitleController`.

## Write a script

A file holds one or more nodes. Each node has a `title:` header, `---`, its lines, and `===`.

```text assets/dialogue/innkeeper.yarn
title: Start
---
<<declare $visits = 0>>
Innkeeper: Welcome to the inn! #line:inn_welcome
<<if $visits > 0>>
Innkeeper: Back again, {$playerName}?
<<endif>>
<<set $visits = $visits + 1>>
-> I need a room. <<if $gold >= 10>>
    <<set $gold = $gold - 10>>
    <<play_sound coin>>
    Innkeeper: Up the stairs, second door.
-> Just looking.
    <<jump Goodbye>>
===
title: Goodbye
---
Innkeeper: Safe travels.
===
```

The parser supports:

- lines with an optional `Character:` prefix, and `#line:key`, `#audio:key` and other `#tags`;
- `{$name}` variables in lines;
- `->` options with indented bodies, made conditional with `<<if ...>>` after the text or an `#if` tag;
- `<<if>>`, `<<elseif>>`, `<<else>>` and `<<endif>>`;
- `<<jump Node>>`, `<<stop>>`, `<<set $name = value>>` (or `to`) and `<<declare $name = value>>`;
- your own commands, such as `<<play_sound coin>>`, and `// comments`.

Expressions support literals, `$variables`, arithmetic, comparisons (also as `eq`, `gt` and the other Yarn words), `and`, `or`, `xor` and `not`, and your own predicates written `[name]`. Yarn functions such as `visited("Shop")` are not supported, and a bare word without `$` is an error: the condition counts as false and a debug build logs it. A malformed file throws a `YarnParseException` that names the line.

## Load and run dialogue

```dart lib/dialogue.dart
import 'package:just_game_engine/just_game_engine.dart';

Future<DialogueManager> setUpDialogue(Engine engine) async {
  final narrative = DialogueManager(
    // Read #line: keys from the engine's strings, in the dialogue namespace.
    localizer: DialogueLocalizer(manager: engine.context.localization),
  );
  await narrative.loadGraph('assets/dialogue/innkeeper.yarn'); // id: innkeeper

  narrative.globalVariables
    ..set('playerName', 'Aria')
    ..set('gold', 25);
  narrative.conditions.register(
    'hasKey',
    (vars) => vars.get<bool>('key') ?? false,
  );
  narrative.commands.register('play_sound', (ctx) async {
    engine.world.getSystem<AudioSystem>()?.playOneShot(
      'assets/audio/${ctx.arg(0)}.wav',
    );
  });
  return narrative;
}
```

- `loadGraph(path)` registers a file under its name without the extension; `parseAndRegister(source, id: ...)` takes Yarn text.
- `createRunner(graphId)` makes a runner; `runner.start('Start')` runs it from a node. `startDialogue(graphId: ..., startNode: ...)` does both and returns the runner.
- Drive a runner with `advance()` after a line, `selectChoice(index)` for an option and `stop()` to end early. `isRunning` says whether it is still going.
- `runner.signals` holds `currentLine` (a `DialogueLine` with `character`, `text`, `lineKey`, `audioKey` and `tags`), `choices` (each `DialogueChoice` has `index`, `text` and `isAvailable`), `isDialogueActive`, `activeSpeaker` and `activeNodeTitle`. They are `ValueListenable`s, so `ValueListenableBuilder` works with them.
- `globalVariables` is shared by every runner of the manager. Names are read without the `$` and ignore case. Save them with `toMap()` and restore them with `loadFromMap(map)`.
- Command names ignore case; a command's arguments are in `ctx.args`, with `ctx.arg(0)` for one of them.

## Show it on screen

`DialogueBoxWidget` shows the current line with a typewriter effect: the first tap finishes the line, the next calls `onTap`. It hides itself when there is no line. `DialogueChoicesWidget` lists the options and calls `selectChoice` when one is tapped, showing unavailable options greyed out unless `showUnavailable: false`. Both are in `package:just_game_engine/widgets.dart`.

```dart lib/talk.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine/widgets.dart';

Widget talkScreen(Engine engine, DialogueRunner runner) => GameWidget(
  engine: engine,
  overlay: Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogueChoicesWidget(runner: runner),
          DialogueBoxWidget(runner: runner, onTap: runner.advance),
        ],
      ),
    ),
  ),
);
```

> **Note:** The box starts listening to its runner when it is first built and shows the lines presented after that. Build it before you call `runner.start`.

The box also takes `typewriterSpeed`, `portraitBuilder` (a widget for the speaking character), `textStyle`, `characterNameStyle`, `boxDecoration` and `height`. Overlays and layers are covered in [GameWidget](/docs/game-widget).

## NPCs and trigger zones

Add `DialogueSystem(manager: narrative)` to the world for dialogue tied to entities; it is not a default system. It finds the player by tag (`player` unless you pass `playerTag`).

- `DialogueComponent(graphId: ..., startNode: ..., interactionRadius: 64)` on an NPC. The system sets `isInteractable` while the player is within the radius and `isInDialogue` while the NPC's runner runs. Start the conversation yourself, for example on an interact action: `narrative.createRunnerForEntity(npc.id, graphId)`, then `start(startNode)` on the runner it returns.
- `DialogueTriggerComponent(graphId: ..., triggerRadius: 64, triggerOnce: true)` on an invisible entity starts its dialogue as the player steps inside. A repeating trigger fires again only after the player leaves and comes back.
- Both take `autoAdvance` and `autoAdvanceDelay` (seconds per line) for cutscene-style monologues; choices still wait for the player.

`narrative.isAnyDialogueActive` and `narrative.activeGraphId` are signals for pausing gameplay or hiding the HUD while someone talks.

## Localized lines

A line tagged `#line:key` is looked up under that key in the `dialogue` namespace; when the key is missing, the line's own text is shown. Give the manager a `DialogueLocalizer` that uses the engine's `LocalizationManager`, as above, so dialogue follows the same locale as the rest of the game. Then load the strings with `l10n.load(locale, path, ns: LocalizationManager.dialogueNamespace)`, or call `localizer.loadLocale(locale)`, which reads `<basePath>_<locale>.json` (`basePath` is `assets/data/dialogue` unless you pass one) and falls back to the bare language and then English. A `DialogueManager()` made without a localizer uses a manager of its own, not the engine's. See [Localization](/docs/localization).

## Subtitles

A `SubtitleTrack` is a list of `SubtitleCue`s (`start`, `end` in seconds, and `text`), in time order. A `SubtitleController` plays a track: you tell it the elapsed time with `update(seconds)` and it sets its `currentText` signal. `SubtitleOverlay`, from `widgets.dart`, draws the current text in a dark panel over its child.

```dart lib/subtitles.dart
final subtitles = SubtitleController(
  track: const SubtitleTrack([
    SubtitleCue(start: 0.5, end: 2.5, text: 'Wake up.'),
    SubtitleCue(start: 3.0, end: 6.0, text: 'The ship is sinking.'),
  ]),
);

/// Moves the subtitles on with the game's time, so pausing pauses them.
class SubtitleClockSystem extends System {
  SubtitleClockSystem(this.controller);

  final SubtitleController controller;
  double _elapsed = 0;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _elapsed += deltaTime;
    controller.update(_elapsed);
  }
}

// engine.world.addSystem(SubtitleClockSystem(subtitles));
// SubtitleOverlay(controller: subtitles, child: GameWidget(engine: engine))
```

`SubtitleTrack.localized(entries: [(start: 0.5, end: 2.5, key: 'intro.wake')], l10n: l10n)` builds cues from localization keys, resolved once with the current locale. `reset()` clears the text, and `totalDuration` is the end of the last cue.
''',
  ),
];
