import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_nav_bar.dart';

/// A page: the nav bar fixed at the top, then [children] and the footer in
/// one scroll view.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.children, this.controller});

  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppNavBar(),
          Expanded(
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverList.list(children: children),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AppFooter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
