import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/engine_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/code_block.dart';
import '../cubit/examples_cubit.dart';
import '../cubit/examples_state.dart';

@RoutePage()
class ExamplesView extends StatelessWidget {
  const ExamplesView({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': 'examples'},
    );
    return BlocProvider(
      create: (_) => ExamplesCubit(),
      child: const Scaffold(body: _ExamplesLayout()),
    );
  }
}

class _ExamplesLayout extends StatelessWidget {
  const _ExamplesLayout();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return BlocBuilder<ExamplesCubit, ExamplesState>(
      builder: (context, state) {
        final selected = EngineData.examples
            .where((e) => e.id == state.selectedExampleId)
            .firstOrNull;

        // Mobile layout: full-screen viewer with FAB to show examples list
        if (isMobile) {
          return Scaffold(
            body: selected != null
                ? _ExampleViewer(example: selected, isMobile: true)
                : _MobileExamplesList(selectedId: state.selectedExampleId),
            floatingActionButton: selected != null
                ? FloatingActionButton(
                    backgroundColor: AppColors.accent,
                    onPressed: () => _showExamplesBottomSheet(
                      context,
                      state.selectedExampleId,
                    ),
                    child: const Icon(Icons.list, color: Colors.white),
                  )
                : null,
          );
        }

        // Desktop layout: side-by-side
        return Row(
          children: [
            // ── Left panel: example list ──────────────────
            _ExamplesList(selectedId: state.selectedExampleId),
            const VerticalDivider(width: 1, color: AppColors.border),
            // ── Right panel: code viewer ──────────────────
            Expanded(
              child: selected != null
                  ? _ExampleViewer(example: selected, isMobile: false)
                  : Center(
                      child: Text(
                        'Select an example',
                        style: AppTextStyles.headlineMedium,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showExamplesBottomSheet(BuildContext context, String selectedId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => _MobileExamplesSheet(
          selectedId: selectedId,
          scrollController: scrollController,
          parentContext: context,
        ),
      ),
    );
  }
}

/// Mobile examples list shown as bottom sheet
class _MobileExamplesSheet extends StatelessWidget {
  final String selectedId;
  final ScrollController scrollController;
  final BuildContext parentContext;

  const _MobileExamplesSheet({
    required this.selectedId,
    required this.scrollController,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.textMuted,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                'EXAMPLES',
                style: AppTextStyles.label.copyWith(
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text('Learn by code', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: EngineData.examples.length,
            itemBuilder: (context, index) {
              final example = EngineData.examples[index];
              final isSelected = example.id == selectedId;
              final subsystem = EngineData.subsystems
                  .where((s) => s.id == example.subsystemId)
                  .firstOrNull;

              return _ExampleTile(
                example: example,
                subsystem: subsystem,
                isSelected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  parentContext.read<ExamplesCubit>().selectExample(example.id);
                  FirebaseAnalytics.instance.logEvent(
                    name: 'example_viewed',
                    parameters: {'example_id': example.id},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Mobile examples list shown when no example is selected
class _MobileExamplesList extends StatelessWidget {
  final String selectedId;

  const _MobileExamplesList({required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXAMPLES',
                    style: AppTextStyles.label.copyWith(
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Learn by code', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: EngineData.examples.length,
                itemBuilder: (context, index) {
                  final example = EngineData.examples[index];
                  final isSelected = example.id == selectedId;
                  final subsystem = EngineData.subsystems
                      .where((s) => s.id == example.subsystemId)
                      .firstOrNull;

                  return _ExampleTile(
                    example: example,
                    subsystem: subsystem,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<ExamplesCubit>().selectExample(example.id);
                      FirebaseAnalytics.instance.logEvent(
                        name: 'example_viewed',
                        parameters: {'example_id': example.id},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamplesList extends StatelessWidget {
  final String selectedId;
  const _ExamplesList({required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXAMPLES',
                  style: AppTextStyles.label.copyWith(
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Learn by code', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: EngineData.examples.length,
              itemBuilder: (context, index) {
                final example = EngineData.examples[index];
                final isSelected = example.id == selectedId;
                final subsystem = EngineData.subsystems
                    .where((s) => s.id == example.subsystemId)
                    .firstOrNull;

                return _ExampleTile(
                  example: example,
                  subsystem: subsystem,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<ExamplesCubit>().selectExample(example.id);
                    FirebaseAnalytics.instance.logEvent(
                      name: 'example_viewed',
                      parameters: {'example_id': example.id},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatefulWidget {
  final EngineExample example;
  final EngineSubsystem? subsystem;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.example,
    required this.subsystem,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ExampleTile> createState() => _ExampleTileState();
}

class _ExampleTileState extends State<_ExampleTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent.withOpacity(0.1)
                : _hovering
                ? AppColors.surfaceVariant
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: widget.isSelected
                    ? AppColors.accent
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.subsystem != null)
                    Icon(
                      widget.subsystem!.icon,
                      size: 16,
                      color: widget.isSelected
                          ? AppColors.accent
                          : AppColors.textMuted,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.example.title,
                      style: widget.isSelected
                          ? AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            )
                          : AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (widget.subsystem != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subsystem!.name,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleViewer extends StatelessWidget {
  final EngineExample example;
  final bool isMobile;

  const _ExampleViewer({required this.example, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────
          Text(
            example.title,
            style: isMobile
                ? AppTextStyles.displayMedium.copyWith(fontSize: 24)
                : AppTextStyles.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            example.description,
            style: isMobile
                ? AppTextStyles.bodyLarge.copyWith(fontSize: 14)
                : AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 32),
          // ── Code ───────────────────────────────────────
          CodeBlock(code: example.code, title: '${example.id}.dart'),
        ],
      ),
    );
  }
}
