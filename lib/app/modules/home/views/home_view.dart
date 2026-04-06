import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/engine_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_nav_bar.dart';
import 'widgets/animated_background.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Fix 5: Move analytics to initState (runs only once)
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': 'home'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppNavBar(),
            _HeroSection(),
            _ComparisonSection(),
            _InstallSection(),
            AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = context.isMobileOrSmaller;

    return SizedBox(
      height: size.height - 64, // minus nav bar
      width: size.width,
      child: AnimatedStudioBackground(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: isMobile ? 100 : 150,
                      child: JustUnknownDynamicIcon(
                        gap: isMobile ? 3 : 4,
                        size: isMobile
                            ? const Size(40, 40)
                            : const Size(60, 60),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Just Game Engine',
                      style: GoogleFonts.majorMonoDisplay(
                        fontSize: isMobile ? 24 : 42,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: isMobile ? 1 : 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A comprehensive 2D game engine built for Flutter',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: isMobile ? 14 : 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // ── CTA Buttons ───────────────────────────
                    isMobile
                        ? Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(200, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'docs_button_tapped',
                                  );
                                  context.router.pushPath(
                                    '/docs/getting-started',
                                  );
                                },
                                child: const Text('Get Started'),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  minimumSize: const Size(200, 48),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'examples_button_tapped',
                                  );
                                  await launchUrl(
                                    Uri.parse(
                                      'https://examples.engine.justunknown.com/',
                                    ),
                                    webOnlyWindowName: '_blank',
                                  );
                                },
                                child: const Text('Examples'),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(160, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'docs_button_tapped',
                                  );
                                  context.router.pushPath(
                                    '/docs/getting-started',
                                  );
                                },
                                child: const Text('Get Started'),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  minimumSize: const Size(140, 50),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'examples_button_tapped',
                                  );
                                  await launchUrl(
                                    Uri.parse(
                                      'https://examples.engine.justunknown.com/',
                                    ),
                                    webOnlyWindowName: '_blank',
                                  );
                                },
                                child: const Text('Examples'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            // Fix 4: Optimized Lottie rendering
            Positioned(
              left: size.width / 2 - (isMobile ? 40 : 60),
              bottom: isMobile ? 20 : 30,
              child: SizedBox(
                height: isMobile ? 80 : 120,
                width: isMobile ? 80 : 120,
                child: Lottie.asset(
                  'assets/animations/arrow_down.json',
                  frameRate: FrameRate.max,
                  options: LottieOptions(enableMergePaths: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comparison Section (vs Flame)
// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 40 : 64,
      ),
      child: Column(
        children: [
          Text(
            'why just game engine ?',
            style: isMobile
                ? AppTextStyles.displayMedium.copyWith(fontSize: 24)
                : AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'A modern alternative to Flame — purpose-built for developers who want explicit control.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 14 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;

              // Group cards into rows for equal height
              final items = EngineData.flameComparison;
              final rows = <List<ComparisonPoint>>[];
              for (var i = 0; i < items.length; i += crossAxisCount) {
                rows.add(items.skip(i).take(crossAxisCount).toList());
              }

              return Column(
                children: rows.map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: row.asMap().entries.map((entry) {
                          final isLast = entry.key == row.length - 1;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: isLast ? 0 : 20),
                              child: _ComparisonCard(point: entry.value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatefulWidget {
  final ComparisonPoint point;
  const _ComparisonCard({required this.point});

  @override
  State<_ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<_ComparisonCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.surfaceBright : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering
                ? AppColors.accent.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.point.icon, color: AppColors.accent, size: 28),
            const SizedBox(height: 12),
            Text(widget.point.title, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.point.description, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Install Section
// ─────────────────────────────────────────────────────────────────────────────

class _InstallSection extends StatelessWidget {
  const _InstallSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 40 : 64,
      ),
      child: Column(
        children: [
          Text(
            'get started',
            style: isMobile
                ? AppTextStyles.displayMedium.copyWith(fontSize: 24)
                : AppTextStyles.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add the package to your Flutter project in seconds.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 14 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _InstallSnippet(),
        ],
      ),
    );
  }
}

class _InstallSnippet extends StatefulWidget {
  @override
  State<_InstallSnippet> createState() => _InstallSnippetState();
}

class _InstallSnippetState extends State<_InstallSnippet> {
  bool _copied = false;
  static const _command = 'flutter pub add just_game_engine';

  Future<void> _copy() async {
    await Clipboard.setData(const ClipboardData(text: _command));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.codeBorder),
      ),
      child: Row(
        children: [
          Text(
            '\$ ',
            style: AppTextStyles.code.copyWith(color: AppColors.textMuted),
          ),
          Expanded(child: Text(_command, style: AppTextStyles.code)),
          IconButton(
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 18,
              color: _copied ? AppColors.success : AppColors.textMuted,
            ),
            onPressed: _copy,
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JU Logo Icon Grid (preserved from original)
// ─────────────────────────────────────────────────────────────────────────────

class JustUnknownDynamicIcon extends StatelessWidget {
  final double gap;
  final Size size;
  const JustUnknownDynamicIcon({
    super.key,
    required this.gap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(milliseconds: 300);
    const Curve curve = Curves.easeIn;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedIconWidget(
              name: 'just_icon',
              duration: duration,
              curve: curve,
              size: size,
              imageUrl: 'assets/icons/j.png',
            ),
            SizedBox(width: gap),
            AnimatedIconWidget(
              name: 'unknown_icon',
              duration: duration,
              curve: curve,
              size: size,
              imageUrl: 'assets/icons/u.png',
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedIconWidget(
              name: 'unknown_box_icon',
              duration: duration,
              curve: curve,
              size: size,
              imageUrl: 'assets/icons/plus.png',
            ),
            SizedBox(width: gap),
            AnimatedIconWidget(
              name: 'unknown_box_icon',
              duration: duration,
              curve: curve,
              size: size,
              imageUrl: 'assets/icons/cross.png',
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedIconWidget extends StatefulWidget {
  const AnimatedIconWidget({
    super.key,
    required this.name,
    required this.duration,
    required this.curve,
    required this.size,
    required this.imageUrl,
  });

  final String name;
  final Duration duration;
  final Curve curve;
  final Size size;
  final String imageUrl;

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget> {
  double sizeFactor = 1.0;

  Future<void> _animateSize(double from, double to) async {
    setState(() => sizeFactor = to);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => sizeFactor = from);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _animateSize(0.9, 0.7);
        FirebaseAnalytics.instance.logEvent(
          name: 'game_studio_icon_tapped',
          parameters: {'icon_name': widget.name},
        );
      },
      onHover: (bool hovering) {
        setState(() => sizeFactor = hovering ? 0.9 : 1.0);
      },
      child: AnimatedContainer(
        height: widget.size.height * sizeFactor,
        width: widget.size.width * sizeFactor,
        duration: widget.duration,
        curve: widget.curve,
        child: Image.asset(widget.imageUrl),
      ),
    );
  }
}
