import 'doc_models.dart';
import 'docs_audio_content.dart';
import 'docs_core.dart';
import 'docs_flutter.dart';
import 'docs_gameplay.dart';
import 'docs_getting_started.dart';
import 'docs_graphics.dart';
import 'docs_tools.dart';

export 'doc_models.dart';

/// Every docs page, in sidebar order, with lookup, search and paging.
abstract final class DocsIndex {
  static const defaultId = 'introduction';

  static final List<DocPage> pages = [
    ...gettingStartedDocs,
    ...toolsDocs,
    ...coreDocs,
    ...graphicsDocs,
    ...gameplayDocs,
    ...audioContentDocs,
    ...flutterDocs,
  ];

  /// Section ids from the 1.x docs, so old links still land somewhere useful.
  static const aliases = {
    'getting-started': 'quick-start',
    'core': 'engine',
    'math': 'engine',
    'memory': 'assets',
    'parallax': 'rendering',
    'sprite-atlas': 'sprites',
    'animation': 'sprites',
    'post-processing': 'particles',
    'deterministic-effects': 'particles',
    'physics': 'physics-2d',
    'raycasting': 'physics-2d',
    'scene-graph': 'scenes',
    'narrative': 'dialogue',
    'tiledmap': 'level-maps',
  };

  static final Map<String, DocPage> _byId = {for (final p in pages) p.id: p};

  /// The page id to show for [id]: itself, its 1.x alias, or the default.
  static String resolve(String? id) {
    if (id == null || id.isEmpty) return defaultId;
    if (_byId.containsKey(id)) return id;
    final alias = aliases[id];
    return alias != null && _byId.containsKey(alias) ? alias : defaultId;
  }

  static DocPage byId(String id) => _byId[resolve(id)]!;

  /// Pages grouped for the sidebar, in [DocGroups.order].
  static List<(String, List<DocPage>)> get grouped => [
    for (final group in DocGroups.order)
      if (pages.any((p) => p.group == group))
        (group, pages.where((p) => p.group == group).toList()),
  ];

  static DocPage? previous(String id) {
    final i = pages.indexWhere((p) => p.id == id);
    return i > 0 ? pages[i - 1] : null;
  }

  static DocPage? next(String id) {
    final i = pages.indexWhere((p) => p.id == id);
    return i >= 0 && i < pages.length - 1 ? pages[i + 1] : null;
  }

  /// Pages matching [query], best first: title, then keywords, summary and
  /// body.
  static List<DocPage> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final scored = <(DocPage, int)>[];
    for (final page in pages) {
      var score = 0;
      if (page.title.toLowerCase().contains(q)) score += 8;
      if (page.keywords.any((k) => k.toLowerCase().contains(q))) score += 5;
      if (page.summary.toLowerCase().contains(q)) score += 3;
      if (page.group.toLowerCase().contains(q)) score += 2;
      if (page.body.toLowerCase().contains(q)) score += 1;
      if (score > 0) scored.add((page, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final (page, _) in scored) page];
  }
}
