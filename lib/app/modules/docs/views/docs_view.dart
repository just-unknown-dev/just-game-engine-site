import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/docs/docs_index.dart';
import '../../../core/constants/site.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/markdown_view.dart';
import '../cubit/docs_cubit.dart';
import '../cubit/docs_state.dart';

/// `/docs/<section>`: the documentation, one page at a time.
@RoutePage()
class DocsView extends StatefulWidget {
  const DocsView({super.key, @PathParam('section') this.section});

  final String? section;

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late final DocsCubit _cubit;

  @override
  void initState() {
    super.initState();
    final id = DocsIndex.resolve(widget.section);
    _cubit = DocsCubit(initialSection: id);
    _logView(id);
    _fixUrl(id);
  }

  @override
  void didUpdateWidget(covariant DocsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) {
      final id = DocsIndex.resolve(widget.section);
      if (id != _cubit.state.currentSection) {
        _cubit.navigateToSection(id);
        _logView(id);
      }
      _fixUrl(id);
    }
  }

  /// Old or unknown ids show their new page; make the address bar agree.
  void _fixUrl(String id) {
    if (widget.section == id) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.router.replacePath('/docs/$id');
    });
  }

  void _logView(String id) {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'docs', 'section': id},
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Column(
          children: [
            const AppNavBar(maxWidth: kDocsWidth),
            const Expanded(child: _DocsLayout()),
          ],
        ),
      ),
    );
  }
}

/// Opens docs page [id] by changing the URL.
void _open(BuildContext context, String id) {
  context.router.navigatePath('/docs/$id');
}

/// Where the docs columns sit for a window width.
///
/// The columns are centred at [kDocsWidth] with the same side padding the
/// nav bar uses, so the logo lines up with the sidebar and the nav's last
/// icon with the "On this page" list.
class _DocsGrid {
  factory _DocsGrid(double windowWidth) {
    final width = math.min(windowWidth - 2 * _pad, kDocsWidth);
    final side = _pad + math.max((windowWidth - 2 * _pad - kDocsWidth) / 2, 0);
    return _DocsGrid._(side: side, showToc: width >= 1200);
  }

  const _DocsGrid._({required this.side, required this.showToc});

  static const _pad = 32.0;
  static const sidebarWidth = 264.0;
  static const tocWidth = 216.0;
  static const gap = 48.0;

  /// Space from each window edge to the grid.
  final double side;
  final bool showToc;

  /// The article's padding inside a scroll view as wide as the window, so
  /// the wheel scrolls it from anywhere outside the sidebar.
  EdgeInsets get articlePadding => EdgeInsets.fromLTRB(
    side + sidebarWidth + gap,
    48,
    side + (showToc ? tocWidth + gap : 0),
    72,
  );
}

class _DocsLayout extends StatelessWidget {
  const _DocsLayout();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final compact = context.isMobileOrSmaller;

    return BlocBuilder<DocsCubit, DocsState>(
      buildWhen: (a, b) => a.currentSection != b.currentSection,
      builder: (context, state) {
        final page = DocsIndex.byId(state.currentSection);

        if (compact) {
          return Column(
            children: [
              _MobileDocsBar(page: page),
              Expanded(
                child: _Article(key: ValueKey(page.id), page: page),
              ),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final grid = _DocsGrid(constraints.maxWidth);
            return Stack(
              children: [
                Positioned.fill(
                  child: _Article(
                    key: ValueKey(page.id),
                    page: page,
                    grid: grid,
                  ),
                ),
                Positioned(
                  left: grid.side,
                  top: 0,
                  bottom: 0,
                  width: _DocsGrid.sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.bg,
                      border: Border(right: BorderSide(color: p.border)),
                    ),
                    // The sidebar scrolls with the wheel; a scrollbar beside
                    // its border only adds noise.
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: const _Sidebar(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _Sidebar extends StatefulWidget {
  const _Sidebar({this.onNavigate, this.controller});

  /// Called after a page is picked (the mobile sheet closes itself).
  final VoidCallback? onNavigate;
  final ScrollController? controller;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: context.read<DocsCubit>().state.searchQuery,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _pick(String id) {
    widget.onNavigate?.call();
    _open(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;

    return BlocBuilder<DocsCubit, DocsState>(
      builder: (context, state) {
        final query = state.searchQuery.trim();
        final results = DocsIndex.search(query);

        return Column(
          children: [
            Padding(
              padding: widget.controller == null
                  // Desktop: flush with the grid's left edge (and the logo).
                  ? const EdgeInsets.fromLTRB(0, 40, 20, 12)
                  : const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: TextField(
                controller: _search,
                onChanged: context.read<DocsCubit>().search,
                style: t.bodySmall.copyWith(color: p.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search the docs',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: p.textMuted,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          iconSize: 17,
                          icon: Icon(Icons.close_rounded, color: p.textMuted),
                          onPressed: () {
                            _search.clear();
                            context.read<DocsCubit>().clearSearch();
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: widget.controller,
                padding: widget.controller == null
                    ? const EdgeInsets.fromLTRB(0, 0, 16, 40)
                    : const EdgeInsets.fromLTRB(10, 4, 10, 32),
                children: [
                  if (query.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                      child: Text(
                        results.isEmpty
                            ? 'No pages match "$query".'
                            : '${results.length} '
                                  '${results.length == 1 ? 'page' : 'pages'}',
                        style: t.caption,
                      ),
                    ),
                    for (final page in results)
                      _SidebarItem(
                        title: page.title,
                        subtitle: page.summary,
                        active: page.id == state.currentSection,
                        onTap: () => _pick(page.id),
                      ),
                  ] else
                    for (final (group, pages) in DocsIndex.grouped) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                        child: Text(
                          group.toUpperCase(),
                          style: t.eyebrow.copyWith(
                            fontSize: 11.5,
                            color: p.textMuted,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      for (final page in pages)
                        _SidebarItem(
                          title: page.title,
                          active: page.id == state.currentSection,
                          onTap: () => _pick(page.id),
                        ),
                    ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.title,
    required this.active,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    // Bring the open page into view when the sidebar first shows it.
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(context, alignment: 0.35);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return Semantics(
      selected: widget.active,
      button: true,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (h) => setState(() => _hover = h),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          decoration: BoxDecoration(
            color: widget.active
                ? p.accentSoft
                : (_hover ? p.surfaceAlt : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: t.bodySmall.copyWith(
                  height: 1.35,
                  fontWeight: widget.active ? FontWeight.w600 : FontWeight.w500,
                  color: widget.active
                      ? p.accentText
                      : (_hover ? p.textPrimary : p.textSecondary),
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  widget.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(fontSize: 12.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileDocsBar extends StatelessWidget {
  const _MobileDocsBar({required this.page});

  final DocPage page;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: p.bgElevated,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _showSheet(context),
            icon: Icon(Icons.menu_book_outlined, size: 18, color: p.accent),
            label: Text(
              'Browse docs',
              style: t.label.copyWith(fontSize: 14, color: p.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${page.group} / ${page.title}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: t.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final cubit = context.read<DocsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => BlocProvider.value(
        value: cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, controller) => _Sidebar(
            controller: controller,
            onNavigate: () => Navigator.of(sheet).pop(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article
// ─────────────────────────────────────────────────────────────────────────────

class _Article extends StatefulWidget {
  const _Article({super.key, required this.page, this.grid});

  final DocPage page;

  /// The desktop column grid; null on narrow screens.
  final _DocsGrid? grid;

  @override
  State<_Article> createState() => _ArticleState();
}

class _ArticleState extends State<_Article> {
  late final List<MarkdownHeading> _outline;
  late final Map<String, GlobalKey> _anchors;
  final _active = ValueNotifier<String?>(null);

  /// Each page scrolls on its own, from the top.
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _outline = MarkdownView.outline(widget.page.body);
    _anchors = {for (final h in _outline) h.slug: GlobalKey()};
    _active.value = _outline.isEmpty ? null : _outline.first.slug;
    _scroll.addListener(_trackActive);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    super.dispose();
  }

  /// Marks the last heading scrolled past the top as current.
  void _trackActive() {
    String? current = _outline.isEmpty ? null : _outline.first.slug;
    for (final h in _outline) {
      final box =
          _anchors[h.slug]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      if (y < AppNavBar.height + 120) current = h.slug;
    }
    _active.value = current;
  }

  void _jumpTo(String slug) {
    final ctx = _anchors[slug]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grid = widget.grid;
    final page = widget.page;

    final body = Scrollbar(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        padding:
            grid?.articlePadding ?? const EdgeInsets.fromLTRB(20, 28, 20, 64),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ArticleHeader(page: page),
                  const SizedBox(height: 36),
                  MarkdownView(page.body, anchors: _anchors),
                  const SizedBox(height: 40),
                  _PrevNext(id: page.id),
                  const SizedBox(height: 32),
                  const _ArticleFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (grid == null || !grid.showToc || _outline.isEmpty) return body;
    // The list sits over the scroll view at the grid's right edge, only as
    // tall as its content, so the wheel still scrolls the page below it.
    return Stack(
      children: [
        Positioned.fill(child: body),
        Positioned(
          top: 48,
          right: grid.side,
          width: _DocsGrid.tocWidth,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height - AppNavBar.height - 96,
            ),
            child: ValueListenableBuilder<String?>(
              valueListenable: _active,
              builder: (context, active, _) =>
                  _Toc(outline: _outline, active: active, onTap: _jumpTo),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader({required this.page});

  final DocPage page;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Docs', style: t.caption),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: p.textMuted,
              ),
            ),
            Text(
              page.group,
              style: t.caption.copyWith(
                color: p.accentText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          page.title,
          style: t.h1.copyWith(fontSize: context.isMobileOrSmaller ? 30 : 40),
        ),
        const SizedBox(height: 14),
        Text(page.summary, style: t.lead),
        if (page.id == DocsIndex.defaultId || page.id == 'installation') ...[
          const SizedBox(height: 20),
          const Pill(label: 'Written for ${Versions.engine}'),
        ],
      ],
    );
  }
}

class _Toc extends StatelessWidget {
  const _Toc({
    required this.outline,
    required this.active,
    required this.onTap,
  });

  final List<MarkdownHeading> outline;
  final String? active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ON THIS PAGE',
            style: t.eyebrow.copyWith(
              fontSize: 11.5,
              color: p.textMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          for (final h in outline)
            InkWell(
              onTap: () => onTap(h.slug),
              borderRadius: BorderRadius.circular(6),
              hoverColor: p.surfaceAlt,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: h.slug == active ? p.accent : p.border,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  h.text.replaceAll('`', ''),
                  style: t.caption.copyWith(
                    fontSize: 13.5,
                    height: 1.4,
                    color: h.slug == active ? p.accentText : p.textSecondary,
                    fontWeight: h.slug == active ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrevNext extends StatelessWidget {
  const _PrevNext({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final prev = DocsIndex.previous(id);
    final next = DocsIndex.next(id);

    Widget card(DocPage page, {required bool forward}) {
      final t = context.type;
      final p = context.palette;
      return HoverCard(
        onTap: () => _open(context, page.id),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: forward
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(forward ? 'Next' : 'Previous', style: t.caption),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!forward) ...[
                  Icon(Icons.arrow_back_rounded, size: 16, color: p.accentText),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    page.title,
                    overflow: TextOverflow.ellipsis,
                    style: t.label.copyWith(color: p.accentText),
                  ),
                ),
                if (forward) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: p.accentText,
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: prev == null
              ? const SizedBox.shrink()
              : card(prev, forward: false),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: next == null
              ? const SizedBox.shrink()
              : card(next, forward: true),
        ),
      ],
    );
  }
}

class _ArticleFooter extends StatelessWidget {
  const _ArticleFooter();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Something wrong or missing?', style: t.caption),
          const ArrowLink(label: 'Open an issue', url: Links.engineIssues),
          const ArrowLink(label: 'API reference', url: Links.apiReference),
          const ArrowLink(label: 'Ask on Discord', url: Links.discord),
        ],
      ),
    );
  }
}
