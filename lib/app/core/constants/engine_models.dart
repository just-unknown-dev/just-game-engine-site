import 'package:flutter/material.dart';

/// Subsystem data model used across Features, Docs, and Examples pages.
class EngineSubsystem {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final String shortDescription;
  final List<String> features;
  final List<ApiClass> apiClasses;
  final String codeExample;
  final String codeTitle;
  final String docsContent;

  const EngineSubsystem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.shortDescription,
    required this.features,
    required this.apiClasses,
    required this.codeExample,
    required this.codeTitle,
    required this.docsContent,
  });
}

/// API class reference used in docs.
class ApiClass {
  final String name;
  final String description;

  const ApiClass({required this.name, required this.description});
}

/// Code example model for the Examples page.
class EngineExample {
  final String id;
  final String title;
  final String description;
  final String code;
  final String subsystemId;

  const EngineExample({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.subsystemId,
  });
}

/// All subsystem categories.
abstract final class SubsystemCategory {
  static const String core = 'Core Systems';
  static const String visual = 'Visual';
  static const String gameplay = 'Gameplay';
  static const String utilities = 'Utilities';
}

/// A comparison point for the "vs Flame" section.
class ComparisonPoint {
  final String title;
  final String description;
  final IconData icon;

  const ComparisonPoint({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// A roadmap item for the Roadmap page.
class RoadmapItem {
  final String title;
  final String description;
  final String status; // 'Completed', 'In Progress', 'Planned'
  final String quarter;
  final IconData icon;
  final List<String> tags;

  const RoadmapItem({
    required this.title,
    required this.description,
    required this.status,
    required this.quarter,
    required this.icon,
    this.tags = const [],
  });
}
