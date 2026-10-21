import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/features_data.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/layout.dart';
import '../cubit/features_cubit.dart';
import '../cubit/features_state.dart';

@RoutePage()
class FeaturesView extends StatefulWidget {
  const FeaturesView({super.key});

  @override
  State<FeaturesView> createState() => _FeaturesViewState();
}

class _FeaturesViewState extends State<FeaturesView> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'features'},
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeaturesCubit(),
      child: const AppScaffold(children: [_Header(), _Areas(), _ToolsBand()]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobileOrSmaller;
    return GlowBackdrop(
      child: PageSection(
        top: compact ? 48 : 80,
        bottom: 8,
        child: const SectionHeading(
          eyebrow: 'Features',
          title: 'Every part of Just Game Engine 2.0.',
          subtitle:
              'Each area is a set of components and systems in one ECS world. '
              'Start with the default systems, add the rest as your game needs '
              'them, and opt into 3D.',
          large: true,
        ),
      ),
    );
  }
}

class _Areas extends StatelessWidget {
  const _Areas();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return BlocBuilder<FeaturesCubit, FeaturesState>(
      builder: (context, state) {
        final categories = [FeaturesState.all, ...FeatureCategory.all];
        final shown = state.filterCategory == FeaturesState.all
            ? FeatureCategory.all
            : [state.filterCategory];

        return PageSection(
          top: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(c),
                      selected: c == state.filterCategory,
                      showCheckmark: false,
                      onSelected: (_) =>
                          context.read<FeaturesCubit>().filterByCategory(c),
                      labelStyle: t.label.copyWith(
                        fontSize: 13.5,
                        color: c == state.filterCategory
                            ? p.accentText
                            : p.textSecondary,
                      ),
                      backgroundColor: p.surface,
                      selectedColor: p.accentSoft,
                      side: BorderSide(
                        color: c == state.filterCategory
                            ? p.accent.withValues(alpha: 0.5)
                            : p.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
              for (final category in shown) ...[
                const SizedBox(height: 48),
                Row(
                  children: [
                    Text(category, style: t.h2.copyWith(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(child: Divider(color: p.border)),
                  ],
                ),
                const SizedBox(height: 24),
                CardGrid(
                  children: [
                    for (final area in FeaturesData.areas)
                      if (area.category == category) _AreaCard(area: area),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area});

  final FeatureArea area;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;
    return HoverCard(
      url: area.docsPath,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(area.icon),
              const Spacer(),
              if (area.optIn) const Pill(label: 'Opt-in', dot: false),
            ],
          ),
          const SizedBox(height: 20),
          Text(area.name, style: t.h3.copyWith(fontSize: 19)),
          const SizedBox(height: 8),
          Text(area.summary, style: t.bodySmall),
          const SizedBox(height: 16),
          CheckList(area.highlights),
          const Spacer(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Read the docs',
                style: t.label.copyWith(fontSize: 14, color: p.accentText),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 15, color: p.accentText),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolsBand extends StatelessWidget {
  const _ToolsBand();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return PageSection(
      top: 0,
      child: Container(
        padding: EdgeInsets.all(context.isMobileOrSmaller ? 24 : 40),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.border),
        ),
        child: SplitRow(
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('More than an engine.', style: t.h2.copyWith(fontSize: 28)),
              const SizedBox(height: 10),
              Text(
                'Lay out levels in the editor, and let the CLI create, run, '
                'check and upgrade your game.',
                style: t.body,
              ),
            ],
          ),
          end: const Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              AppButton(
                label: 'The editor',
                url: '/editor',
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              AppButton.secondary(
                label: 'The CLI',
                url: '/cli',
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
