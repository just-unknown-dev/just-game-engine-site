import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/engine_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../cubit/features_cubit.dart';
import '../cubit/features_state.dart';

@RoutePage()
class FeaturesView extends StatelessWidget {
  const FeaturesView({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': 'features'},
    );
    return BlocProvider(
      create: (_) => FeaturesCubit(),
      child: const AppScaffold(child: _FeaturesBody()),
    );
  }
}

class _FeaturesBody extends StatelessWidget {
  const _FeaturesBody();

  static const _categories = [
    'All',
    'Core Systems',
    'Visual',
    'Gameplay',
    'Utilities',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return BlocBuilder<FeaturesCubit, FeaturesState>(
      builder: (context, state) {
        final filtered = state.filterCategory == 'All'
            ? EngineData.subsystems
            : EngineData.subsystems
                  .where((s) => s.category == state.filterCategory)
                  .toList();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: isMobile ? 24 : 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'features',
                subtitle:
                    '11 major subsystems — everything you need to build games with Flutter.',
              ),
              // ── Filter chips ───────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = state.filterCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      context.read<FeaturesCubit>().filterByCategory(cat);
                    },
                    selectedColor: AppColors.accent.withOpacity(0.2),
                    labelStyle: isSelected
                        ? AppTextStyles.label.copyWith(color: AppColors.accent)
                        : AppTextStyles.label,
                    side: BorderSide(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // ── Feature cards grid ─────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                      ? 2
                      : 1;

                  // Group cards into rows for equal height
                  final rows = <List<EngineSubsystem>>[];
                  for (var i = 0; i < filtered.length; i += crossAxisCount) {
                    rows.add(filtered.skip(i).take(crossAxisCount).toList());
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
                                  padding: EdgeInsets.only(
                                    right: isLast ? 0 : 20,
                                  ),
                                  child: _FeatureCard(subsystem: entry.value),
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
      },
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final EngineSubsystem subsystem;
  const _FeatureCard({required this.subsystem});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hovering ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.surfaceBright : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: () {
            context.router.pushPath('/docs/${widget.subsystem.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon + Category ──────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.subsystem.icon,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subsystem.name,
                            style: AppTextStyles.headlineSmall,
                          ),
                          Text(
                            widget.subsystem.category,
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: _hovering ? AppColors.accent : AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Description ──────────────────────────
                Text(
                  widget.subsystem.shortDescription,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // ── Feature bullets ──────────────────────
                ...widget.subsystem.features
                    .take(4)
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
