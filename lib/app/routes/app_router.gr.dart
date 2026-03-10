// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DocsView]
class DocsRoute extends PageRouteInfo<DocsRouteArgs> {
  DocsRoute({Key? key, String? section, List<PageRouteInfo>? children})
    : super(
        DocsRoute.name,
        args: DocsRouteArgs(key: key, section: section),
        rawPathParams: {'section': section},
        initialChildren: children,
      );

  static const String name = 'DocsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DocsRouteArgs>(
        orElse: () => DocsRouteArgs(section: pathParams.optString('section')),
      );
      return DocsView(key: args.key, section: args.section);
    },
  );
}

class DocsRouteArgs {
  const DocsRouteArgs({this.key, this.section});

  final Key? key;

  final String? section;

  @override
  String toString() {
    return 'DocsRouteArgs{key: $key, section: $section}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DocsRouteArgs) return false;
    return key == other.key && section == other.section;
  }

  @override
  int get hashCode => key.hashCode ^ section.hashCode;
}

/// generated route for
/// [ExamplesView]
class ExamplesRoute extends PageRouteInfo<void> {
  const ExamplesRoute({List<PageRouteInfo>? children})
    : super(ExamplesRoute.name, initialChildren: children);

  static const String name = 'ExamplesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExamplesView();
    },
  );
}

/// generated route for
/// [FeaturesView]
class FeaturesRoute extends PageRouteInfo<void> {
  const FeaturesRoute({List<PageRouteInfo>? children})
    : super(FeaturesRoute.name, initialChildren: children);

  static const String name = 'FeaturesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeaturesView();
    },
  );
}

/// generated route for
/// [HomeView]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeView();
    },
  );
}

/// generated route for
/// [RoadmapView]
class RoadmapRoute extends PageRouteInfo<void> {
  const RoadmapRoute({List<PageRouteInfo>? children})
    : super(RoadmapRoute.name, initialChildren: children);

  static const String name = 'RoadmapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RoadmapView();
    },
  );
}
