import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_nav_bar.dart';

/// Shared scaffold that wraps all pages with a persistent nav bar and footer.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool showFooter;

  const AppScaffold({super.key, required this.child, this.showFooter = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppNavBar(),
          Expanded(
            child: showFooter
                ? CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: child),
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [AppFooter()],
                        ),
                      ),
                    ],
                  )
                : child,
          ),
        ],
      ),
    );
  }
}
