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
import '../cubit/roadmap_cubit.dart';
import '../cubit/roadmap_state.dart';

@RoutePage()
class RoadmapView extends StatelessWidget {
  const RoadmapView({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': 'roadmap'},
    );
    return BlocProvider(
      create: (_) => RoadmapCubit(),
      child: const AppScaffold(child: _RoadmapBody()),
    );
  }
}

class _RoadmapBody extends StatelessWidget {
  const _RoadmapBody();

  static const _statuses = ['All', 'Completed', 'In Progress', 'Planned'];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        final filtered = state.filterStatus == 'All'
            ? EngineData.roadmapItems
            : EngineData.roadmapItems
                  .where((item) => item.status == state.filterStatus)
                  .toList();

        // Group items by quarter
        final groupedByQuarter = <String, List<RoadmapItem>>{};
        for (final item in filtered) {
          groupedByQuarter.putIfAbsent(item.quarter, () => []).add(item);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: isMobile ? 24 : 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'roadmap',
                subtitle:
                    'Our development timeline — see what\'s coming next for Just Game Engine.',
              ),
              // ── Filter chips ───────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses.map((status) {
                  final isSelected = state.filterStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      context.read<RoadmapCubit>().filterByStatus(status);
                    },
                    selectedColor: _getStatusColor(status).withOpacity(0.2),
                    labelStyle: isSelected
                        ? AppTextStyles.label.copyWith(
                            color: _getStatusColor(status),
                          )
                        : AppTextStyles.label,
                    side: BorderSide(
                      color: isSelected
                          ? _getStatusColor(status)
                          : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // ── Timeline ───────────────────────────────────
              ...groupedByQuarter.entries.map((entry) {
                return _QuarterSection(
                  quarter: entry.key,
                  items: entry.value,
                  isMobile: isMobile,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.accent;
      case 'Planned':
        return AppColors.textMuted;
      default:
        return AppColors.accent;
    }
  }
}

class _QuarterSection extends StatelessWidget {
  final String quarter;
  final List<RoadmapItem> items;
  final bool isMobile;

  const _QuarterSection({
    required this.quarter,
    required this.items,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quarter header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            quarter,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Items
        ...items.map((item) => _RoadmapCard(item: item, isMobile: isMobile)),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _RoadmapCard extends StatefulWidget {
  final RoadmapItem item;
  final bool isMobile;

  const _RoadmapCard({required this.item, required this.isMobile});

  @override
  State<_RoadmapCard> createState() => _RoadmapCardState();
}

class _RoadmapCardState extends State<_RoadmapCard> {
  bool _hovering = false;

  Color get _statusColor {
    switch (widget.item.status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.accent;
      case 'Planned':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: _hovering ? AppColors.surfaceBright : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering ? _statusColor.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.item.icon, color: _statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: widget.isMobile
                              ? AppTextStyles.headlineSmall.copyWith(
                                  fontSize: 16,
                                )
                              : AppTextStyles.headlineSmall,
                        ),
                      ),
                      _StatusBadge(
                        status: widget.item.status,
                        color: _statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.item.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.label.copyWith(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: AppTextStyles.label.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}
