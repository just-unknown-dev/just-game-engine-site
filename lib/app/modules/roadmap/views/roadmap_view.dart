import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/roadmap_data.dart';
import '../../../core/constants/site.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/layout.dart';
import '../cubit/roadmap_cubit.dart';
import '../cubit/roadmap_state.dart';

@RoutePage()
class RoadmapView extends StatefulWidget {
  const RoadmapView({super.key});

  @override
  State<RoadmapView> createState() => _RoadmapViewState();
}

class _RoadmapViewState extends State<RoadmapView> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'roadmap'},
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoadmapCubit(),
      child: const AppScaffold(children: [_Header(), _Timeline()]),
    );
  }
}

const double _timelineWidth = 860;

Color _statusColor(AppPalette p, RoadmapStatus status) => switch (status) {
  RoadmapStatus.shipped => p.success,
  RoadmapStatus.inProgress => p.accent,
  RoadmapStatus.next => p.info,
};

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobileOrSmaller;
    return GlowBackdrop(
      child: PageSection(
        top: compact ? 48 : 80,
        bottom: 8,
        maxWidth: _timelineWidth,
        child: const SectionHeading(
          eyebrow: 'Roadmap',
          title: 'Where Just Game Engine is going.',
          subtitle:
              'Built from the changelogs of the engine, editor and CLI. '
              'Shipped items carry their release dates; the rest is work in '
              'progress or planned next.',
          large: true,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        final filters = [
          RoadmapState.all,
          for (final s in RoadmapStatus.values) s.label,
        ];
        final statuses =
            [
              RoadmapStatus.inProgress,
              RoadmapStatus.next,
              RoadmapStatus.shipped,
            ].where(
              (s) =>
                  state.filterStatus == RoadmapState.all ||
                  s.label == state.filterStatus,
            );

        return PageSection(
          top: 32,
          maxWidth: _timelineWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in filters)
                    ChoiceChip(
                      label: Text(f),
                      selected: f == state.filterStatus,
                      showCheckmark: false,
                      onSelected: (_) =>
                          context.read<RoadmapCubit>().filterByStatus(f),
                      labelStyle: t.label.copyWith(
                        fontSize: 13.5,
                        color: f == state.filterStatus
                            ? p.accentText
                            : p.textSecondary,
                      ),
                      backgroundColor: p.surface,
                      selectedColor: p.accentSoft,
                      side: BorderSide(
                        color: f == state.filterStatus
                            ? p.accent.withValues(alpha: 0.5)
                            : p.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
              for (final status in statuses) ...[
                const SizedBox(height: 44),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statusColor(p, status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(status.label, style: t.h2.copyWith(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 20),
                for (final item in RoadmapData.items)
                  if (item.status == status) _TimelineRow(item: item),
              ],
              const SizedBox(height: 40),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton.secondary(
                    label: 'Engine changelog',
                    url: Links.engineChangelog,
                  ),
                  AppButton.secondary(
                    label: 'Suggest something',
                    url: Links.engineIssues,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final RoadmapItem item;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final color = _statusColor(p, item.status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 26),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: p.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                ),
                Expanded(child: Container(width: 2, color: p.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HoverCard(
                url: item.url,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.icon, size: 20, color: color),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.title, style: t.h4)),
                        const SizedBox(width: 12),
                        Pill(label: item.when, dot: false, color: color),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.description, style: t.bodySmall),
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in item.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: p.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: t.caption.copyWith(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
