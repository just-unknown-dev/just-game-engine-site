import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/core/constants/docs/docs_index.dart';
import 'package:just_game_engine_site/app/core/constants/features_data.dart';
import 'package:just_game_engine_site/app/core/constants/roadmap_data.dart';

/// Site routes outside the docs that a page may link to.
const _siteRoutes = {'/', '/features', '/editor', '/cli', '/roadmap'};

void main() {
  final ids = DocsIndex.pages.map((p) => p.id).toList();

  group('DocsIndex', () {
    test('page ids are unique', () {
      expect(ids.toSet().length, ids.length);
    });

    test('every page has a title, summary, body and known group', () {
      for (final page in DocsIndex.pages) {
        expect(page.title, isNotEmpty, reason: page.id);
        expect(page.summary, isNotEmpty, reason: page.id);
        expect(page.body.trim(), isNotEmpty, reason: page.id);
        expect(DocGroups.order, contains(page.group), reason: page.id);
      }
    });

    test('pages do not use a # h1 (the title is the heading)', () {
      for (final page in DocsIndex.pages) {
        final h1 = RegExp(r'^# ', multiLine: true).hasMatch(
          // Ignore comments inside fenced code.
          page.body.replaceAll(RegExp(r'```[\s\S]*?```'), ''),
        );
        expect(h1, isFalse, reason: page.id);
      }
    });

    test('every internal link points at a real page', () {
      final link = RegExp(r'\]\((/[^)\s]*)\)');
      for (final page in DocsIndex.pages) {
        for (final m in link.allMatches(page.body)) {
          final path = m.group(1)!.split('#').first;
          if (path.startsWith('/docs/')) {
            expect(
              ids,
              contains(path.substring('/docs/'.length)),
              reason: '${page.id} links to $path',
            );
          } else {
            expect(_siteRoutes, contains(path), reason: '${page.id} → $path');
          }
        }
      }
    });

    test('code fences are closed', () {
      for (final page in DocsIndex.pages) {
        final fences = RegExp(
          r'^\s*```',
          multiLine: true,
        ).allMatches(page.body).length;
        expect(fences.isEven, isTrue, reason: page.id);
      }
    });

    test('1.x section ids resolve to pages that exist', () {
      for (final target in DocsIndex.aliases.values) {
        expect(ids, contains(target));
      }
      expect(DocsIndex.resolve('getting-started'), 'quick-start');
      expect(DocsIndex.resolve('nope'), DocsIndex.defaultId);
      expect(DocsIndex.resolve(null), DocsIndex.defaultId);
    });

    test('previous and next walk the sidebar order', () {
      expect(DocsIndex.previous(ids.first), isNull);
      expect(DocsIndex.next(ids.last), isNull);
      expect(DocsIndex.next(ids.first)?.id, ids[1]);
    });

    test('search ranks title matches first', () {
      final results = DocsIndex.search('physics');
      expect(results, isNotEmpty);
      expect(results.first.title.toLowerCase(), contains('physics'));
      expect(DocsIndex.search('   '), isEmpty);
    });
  });

  group('FeaturesData', () {
    test('every feature area has a docs page', () {
      for (final area in FeaturesData.areas) {
        expect(ids, contains(area.id), reason: area.name);
      }
    });

    test('every category is used', () {
      for (final c in FeatureCategory.all) {
        expect(FeaturesData.areas.any((a) => a.category == c), isTrue);
      }
    });

    test('home areas exist', () {
      expect(FeaturesData.home, hasLength(FeaturesData.homeIds.length));
    });
  });

  group('RoadmapData', () {
    test('every status has items', () {
      for (final s in RoadmapStatus.values) {
        expect(RoadmapData.items.any((i) => i.status == s), isTrue);
      }
    });

    test('internal links point at real pages', () {
      for (final item in RoadmapData.items) {
        final url = item.url;
        if (url == null || !url.startsWith('/')) continue;
        if (url.startsWith('/docs/')) {
          expect(ids, contains(url.substring('/docs/'.length)));
        } else {
          expect(_siteRoutes, contains(url));
        }
      }
    });
  });
}
