/// Barrel file for engine data - re-exports all data modules.
///
/// This file maintains backward compatibility with existing imports.
/// Data is now organized into separate modules:
/// - [engine_models.dart] - Model classes (EngineSubsystem, ApiClass, etc.)
/// - [subsystems_data.dart] - All 11 subsystem definitions
/// - [examples_data.dart] - Code examples
/// - [roadmap_data.dart] - Roadmap items
/// - [home_data.dart] - Home page data (comparison, getting started)

export 'engine_models.dart';
export 'examples_data.dart';
export 'home_data.dart';
export 'roadmap_data.dart';
export 'subsystems_data.dart';

import 'examples_data.dart';
import 'engine_models.dart';
import 'home_data.dart';
import 'roadmap_data.dart';
import 'subsystems_data.dart';

/// Central data accessor for backward compatibility.
///
/// Aggregates data from all modules for easy access.
abstract final class EngineData {
  /// All engine subsystems.
  static const List<EngineSubsystem> subsystems = SubsystemsData.subsystems;

  /// Getting started documentation content.
  static const String gettingStartedContent = HomeData.gettingStartedContent;

  /// Getting started code example.
  static const String gettingStartedCode = HomeData.gettingStartedCode;

  /// Code examples for the Examples page.
  static const List<EngineExample> examples = ExamplesData.examples;

  /// Flame comparison points for the Home page.
  static const List<ComparisonPoint> flameComparison = HomeData.flameComparison;

  /// Roadmap items for the Roadmap page.
  static const List<RoadmapItem> roadmapItems = RoadmapData.roadmapItems;
}
