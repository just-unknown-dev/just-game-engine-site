import 'package:flutter/widgets.dart';

/// Breakpoints for responsive layouts.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Extension on BuildContext for easy responsive checks.
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Returns true if width is below tablet breakpoint (mobile-first).
  bool get isMobileOrSmaller => screenWidth < Breakpoints.tablet;
}

/// A widget that builds different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.tablet) {
      return desktop;
    } else if (width >= Breakpoints.mobile && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
