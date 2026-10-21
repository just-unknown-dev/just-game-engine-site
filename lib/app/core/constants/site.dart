/// Versions shown across the site. Update these when a package is released.
abstract final class Versions {
  /// The 2.0 preview the site leads with.
  static const engine = '2.0.0-dev.2';

  /// The latest stable 1.x release, for people not ready to migrate.
  static const engineStable = '1.6.1';

  static const editor = '0.1.0-dev.1';
  static const gameCli = '0.1.2';
  static const coreCli = '0.1.1';

  /// The oldest Flutter the engine supports.
  static const flutter = '3.47.1';

  static const engineConstraint = '^$engine';
}

/// Every external link in one place.
abstract final class Links {
  static const org = 'https://github.com/just-unknown-dev';

  static const engineRepo = '$org/just-game-engine';
  static const editorRepo = '$org/just-game-engine-editor';
  static const gameCliRepo = '$org/just-game-engine-cli';
  static const coreCliRepo = '$org/just-core-cli';

  static const engineChangelog = '$engineRepo/blob/main/CHANGELOG.md';
  static const engineMigration = '$engineRepo/blob/main/MIGRATION.md';
  static const engineIssues = '$engineRepo/issues';

  static const enginePub = 'https://pub.dev/packages/just_game_engine';
  static const editorPub = 'https://pub.dev/packages/just_game_engine_editor';
  static const gameCliPub = 'https://pub.dev/packages/just_game_engine_cli';
  static const coreCliPub = 'https://pub.dev/packages/just_core_cli';
  static const publisher =
      'https://pub.dev/publishers/justunknown.com/packages';

  static const apiReference =
      'https://pub.dev/documentation/just_game_engine/latest/';

  /// The live examples, still written for 1.x.
  static const examples = 'https://examples.engine.justunknown.com/';

  static const discord = 'https://discord.gg/VXFxVj4Y';
  static const company = 'https://justunknown.com';
}
