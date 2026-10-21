import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/docs/docs_index.dart';
import '../modules/cli/views/cli_view.dart';
import '../modules/docs/views/docs_view.dart';
import '../modules/editor/views/editor_view.dart';
import '../modules/features/views/features_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/roadmap/views/roadmap_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: TransitionsBuilders.fadeIn,
    duration: const Duration(milliseconds: 180),
    reverseDuration: const Duration(milliseconds: 120),
  );

  static String _title(String page) => '$page · Just Game Engine';

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      initial: true,
      title: (_, _) => 'Just Game Engine · A Flutter game engine',
    ),
    AutoRoute(
      page: FeaturesRoute.page,
      path: '/features',
      title: (_, _) => _title('Features'),
    ),
    AutoRoute(
      page: EditorRoute.page,
      path: '/editor',
      title: (_, _) => _title('Level editor'),
    ),
    AutoRoute(
      page: CliRoute.page,
      path: '/cli',
      title: (_, _) => _title('The just CLI'),
    ),
    RedirectRoute(path: '/docs', redirectTo: '/docs/introduction'),
    AutoRoute(
      page: DocsRoute.page,
      path: '/docs/:section',
      title: (_, data) => _title(
        '${DocsIndex.byId(data.params.optString('section') ?? '').title} docs',
      ),
    ),
    AutoRoute(
      page: RoadmapRoute.page,
      path: '/roadmap',
      title: (_, _) => _title('Roadmap'),
    ),
    RedirectRoute(path: '/examples', redirectTo: '/'),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
