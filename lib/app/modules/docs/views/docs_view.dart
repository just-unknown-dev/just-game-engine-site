import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/engine_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/code_block.dart';
import '../cubit/docs_cubit.dart';
import '../cubit/docs_state.dart';

@RoutePage()
class DocsView extends StatelessWidget {
  final String? section;
  const DocsView({super.key, @PathParam('section') this.section});

  @override
  Widget build(BuildContext context) {
    final initialSection = section ?? 'getting-started';
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': 'docs', 'section': initialSection},
    );
    return BlocProvider(
      create: (_) => DocsCubit(initialSection: initialSection),
      child: const Scaffold(body: _DocsLayout()),
    );
  }
}

class _DocsLayout extends StatelessWidget {
  const _DocsLayout();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileOrSmaller;

    return BlocBuilder<DocsCubit, DocsState>(
      builder: (context, state) {
        // Mobile layout: content with FAB to show sidebar
        if (isMobile) {
          return Scaffold(
            body: _DocsContent(sectionId: state.currentSection, isMobile: true),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: () => _showDocsSidebar(context, state.currentSection),
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),
          );
        }

        // Desktop layout: side-by-side
        return Row(
          children: [
            // ── Sidebar ──────────────────────────────────
            _DocsSidebar(currentSection: state.currentSection),
            // ── Divider ──────────────────────────────────
            const VerticalDivider(width: 1, color: AppColors.border),
            // ── Content ──────────────────────────────────
            Expanded(
              child: _DocsContent(
                sectionId: state.currentSection,
                isMobile: false,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDocsSidebar(BuildContext context, String currentSection) {
    final cubit = context.read<DocsCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => _MobileDocsSidebar(
            currentSection: currentSection,
            scrollController: scrollController,
            parentContext: context,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Sidebar (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _MobileDocsSidebar extends StatelessWidget {
  final String currentSection;
  final ScrollController scrollController;
  final BuildContext parentContext;

  const _MobileDocsSidebar({
    required this.currentSection,
    required this.scrollController,
    required this.parentContext,
  });

  static const _sidebarSections = _DocsSidebar._sidebarSections;

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
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (q) => parentContext.read<DocsCubit>().search(q),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search docs...',
              hintStyle: AppTextStyles.bodySmall,
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // Section list
        Expanded(
          child: BlocBuilder<DocsCubit, DocsState>(
            builder: (context, state) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  for (final group in _sidebarSections)
                    _buildMobileGroup(context, group, state),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileGroup(
    BuildContext context,
    _SidebarGroup group,
    DocsState state,
  ) {
    final filteredItems = state.searchQuery.isEmpty
        ? group.items
        : group.items
              .where(
                (item) => item.label.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                ),
              )
              .toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Text(
            group.title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...filteredItems.map((item) {
          final isActive = currentSection == item.id;
          return ListTile(
            dense: true,
            title: Text(
              item.label,
              style: isActive
                  ? AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    )
                  : AppTextStyles.bodyMedium,
            ),
            trailing: isActive
                ? Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              parentContext.read<DocsCubit>().navigateToSection(item.id);
              FirebaseAnalytics.instance.logEvent(
                name: 'docs_section_viewed',
                parameters: {'section': item.id},
              );
            },
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _DocsSidebar extends StatelessWidget {
  final String currentSection;
  const _DocsSidebar({required this.currentSection});

  static const _sidebarSections = [
    _SidebarGroup('Getting Started', [
      _SidebarItem('getting-started', 'Quick Start'),
    ]),
    _SidebarGroup('Core Systems', [
      _SidebarItem('core', 'Core Engine'),
      _SidebarItem('math', 'Math Module'),
      _SidebarItem('memory', 'Memory Management'),
    ]),
    _SidebarGroup('Visual', [
      _SidebarItem('rendering', 'Rendering Engine'),
      _SidebarItem('parallax', 'Parallax Background System'),
      _SidebarItem('sprites', 'Sprite System'),
      _SidebarItem('sprite-atlas', 'Sprite Atlas'),
      _SidebarItem('animation', 'Animation System'),
      _SidebarItem('particles', 'Particle Effects'),
      _SidebarItem('post-processing', 'Post-Processing'),
    ]),
    _SidebarGroup('Gameplay', [
      _SidebarItem('physics', 'Physics Engine'),
      _SidebarItem('raycasting', 'Ray Casting & Tracing'),
      _SidebarItem('scene-graph', 'Scene Graph'),
      _SidebarItem('ecs', 'Entity-Component System'),
      _SidebarItem('input', 'Input Management'),
      _SidebarItem('deterministic-effects', 'Deterministic Effects'),
      _SidebarItem('narrative', 'Narrative & Dialogue'),
    ]),
    _SidebarGroup('Utilities', [
      _SidebarItem('assets', 'Asset Management'),
      _SidebarItem('audio', 'Audio Engine'),
      _SidebarItem('tiledmap', 'Tiled Map Support'),
      _SidebarItem('localization', 'Localization'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.bgDark,
      child: Column(
        children: [
          // ── Search ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) => context.read<DocsCubit>().search(q),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search docs...',
                hintStyle: AppTextStyles.bodySmall,
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
          // ── Section list ───────────────────────────
          Expanded(
            child: BlocBuilder<DocsCubit, DocsState>(
              buildWhen: (prev, curr) =>
                  prev.searchQuery != curr.searchQuery ||
                  prev.currentSection != curr.currentSection,
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (final group in _sidebarSections)
                      _buildGroup(context, group, state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    _SidebarGroup group,
    DocsState state,
  ) {
    final filteredItems = state.searchQuery.isEmpty
        ? group.items
        : group.items
              .where(
                (item) => item.label.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                ),
              )
              .toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Text(
            group.title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...filteredItems.map((item) {
          final isActive = state.currentSection == item.id;
          return _SidebarItemWidget(
            item: item,
            isActive: isActive,
            onTap: () {
              context.read<DocsCubit>().navigateToSection(item.id);
              FirebaseAnalytics.instance.logEvent(
                name: 'docs_section_viewed',
                parameters: {'section': item.id},
              );
            },
          );
        }),
      ],
    );
  }
}

class _SidebarGroup {
  final String title;
  final List<_SidebarItem> items;
  const _SidebarGroup(this.title, this.items);
}

class _SidebarItem {
  final String id;
  final String label;
  const _SidebarItem(this.id, this.label);
}

class _SidebarItemWidget extends StatefulWidget {
  final _SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent.withOpacity(0.1)
                : _hovering
                ? AppColors.surfaceVariant
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.isActive ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.item.label,
            style: widget.isActive
                ? AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)
                : AppTextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────────────────────────────────────

class _DocsContent extends StatelessWidget {
  final String sectionId;
  final bool isMobile;

  const _DocsContent({required this.sectionId, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (sectionId == 'getting-started') {
      return _GettingStartedContent(isMobile: isMobile);
    }

    final subsystem = EngineData.subsystems
        .where((s) => s.id == sectionId)
        .firstOrNull;
    if (subsystem == null) {
      return Center(
        child: Text('Section not found', style: AppTextStyles.headlineMedium),
      );
    }

    return _SubsystemContent(subsystem: subsystem, isMobile: isMobile);
  }
}

class _GettingStartedContent extends StatelessWidget {
  final bool isMobile;

  const _GettingStartedContent({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 48),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Getting Started',
                  style: AppTextStyles.displayMedium.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 24),
                _RichDocsText(content: EngineData.gettingStartedContent),
                const SizedBox(height: 24),
                CodeBlock(
                  code: EngineData.gettingStartedCode,
                  title: 'main.dart',
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Text content ─────────────────────────────
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Getting Started',
                        style: AppTextStyles.displayMedium,
                      ),
                      const SizedBox(height: 24),
                      _RichDocsText(content: EngineData.gettingStartedContent),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // ── Code example ─────────────────────────────
                Expanded(
                  flex: 4,
                  child: CodeBlock(
                    code: EngineData.gettingStartedCode,
                    title: 'main.dart',
                  ),
                ),
              ],
            ),
    );
  }
}

class _SubsystemContent extends StatelessWidget {
  final EngineSubsystem subsystem;
  final bool isMobile;

  const _SubsystemContent({required this.subsystem, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  subsystem.icon,
                  color: AppColors.accent,
                  size: isMobile ? 24 : 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subsystem.name,
                      style: isMobile
                          ? AppTextStyles.displayMedium.copyWith(fontSize: 20)
                          : AppTextStyles.displayMedium,
                    ),
                    Text(subsystem.category, style: AppTextStyles.label),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Mobile: stacked layout
          if (isMobile) ...[
            _RichDocsText(content: subsystem.docsContent),
            const SizedBox(height: 24),
            CodeBlock(code: subsystem.codeExample, title: subsystem.codeTitle),
            const SizedBox(height: 32),
            Text(
              'Features',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...subsystem.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: AppTextStyles.bodyMedium)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'API Reference',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _ApiReferenceTable(classes: subsystem.apiClasses),
          ] else ...[
            // Desktop: side-by-side layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RichDocsText(content: subsystem.docsContent),
                      const SizedBox(height: 32),

                      // ── Features ──────────────────────────
                      Text('Features', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 12),
                      ...subsystem.features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(f, style: AppTextStyles.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── API Reference ─────────────────────
                      Text(
                        'API Reference',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      _ApiReferenceTable(classes: subsystem.apiClasses),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // ── Code example ─────────────────────────
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      CodeBlock(
                        code: subsystem.codeExample,
                        title: subsystem.codeTitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple rich text renderer for docs content (handles **bold** and `code`).
class _RichDocsText extends StatelessWidget {
  final String content;
  const _RichDocsText({required this.content});

  @override
  Widget build(BuildContext context) {
    final paragraphs = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final para in paragraphs) ...[
          if (para.startsWith('•'))
            ...para
                .split('\n')
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: AppColors.accent),
                        ),
                        Expanded(
                          child: _buildRichLine(line.replaceFirst('• ', '')),
                        ),
                      ],
                    ),
                  ),
                )
          else if (para.startsWith('```'))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CodeBlock(
                code: para.replaceAll(RegExp(r'```\w*\n?'), '').trim(),
                showLineNumbers: false,
                title: 'dart',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRichLine(para),
            ),
        ],
      ],
    );
  }

  Widget _buildRichLine(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`)');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: AppTextStyles.bodyLarge,
          ),
        );
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.replaceAll('**', ''),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.replaceAll('`', ''),
            style: AppTextStyles.code.copyWith(
              backgroundColor: AppColors.codeBg,
              color: AppColors.accentLight,
            ),
          ),
        );
      }
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(text: text.substring(lastEnd), style: AppTextStyles.bodyLarge),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

/// Table showing API classes for a subsystem.
class _ApiReferenceTable extends StatelessWidget {
  final List<ApiClass> classes;
  const _ApiReferenceTable({required this.classes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Class',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Data rows
          ...classes.map(
            (c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      c.name,
                      style: AppTextStyles.code.copyWith(
                        color: AppColors.accentLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(c.description, style: AppTextStyles.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
