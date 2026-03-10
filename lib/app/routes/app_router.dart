import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../modules/docs/views/docs_view.dart';
import '../modules/examples/views/examples_view.dart';
import '../modules/features/views/features_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/roadmap/views/roadmap_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/', initial: true),
    AutoRoute(page: FeaturesRoute.page, path: '/features'),
    AutoRoute(page: DocsRoute.page, path: '/docs/:section'),
    AutoRoute(page: ExamplesRoute.page, path: '/examples'),
    AutoRoute(page: RoadmapRoute.page, path: '/roadmap'),
  ];
}
