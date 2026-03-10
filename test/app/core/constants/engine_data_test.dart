import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/core/constants/engine_data.dart';

void main() {
  group('EngineData', () {
    test('contains all 11 subsystems', () {
      expect(EngineData.subsystems, hasLength(11));
    });

    test('each subsystem has required fields populated', () {
      for (final sub in EngineData.subsystems) {
        expect(sub.id, isNotEmpty, reason: '${sub.name} has empty id');
        expect(sub.name, isNotEmpty, reason: '${sub.id} has empty name');
        expect(
          sub.shortDescription,
          isNotEmpty,
          reason: '${sub.id} has empty shortDescription',
        );
        expect(sub.features, isNotEmpty, reason: '${sub.id} has no features');
        expect(
          sub.codeExample,
          isNotEmpty,
          reason: '${sub.id} has empty codeExample',
        );
        expect(
          sub.docsContent,
          isNotEmpty,
          reason: '${sub.id} has empty docsContent',
        );
      }
    });

    test('subsystem ids are unique', () {
      final ids = EngineData.subsystems.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('subsystem categories are valid', () {
      const validCategories = {
        'Core Systems',
        'Visual',
        'Gameplay',
        'Utilities',
      };
      for (final sub in EngineData.subsystems) {
        expect(
          validCategories,
          contains(sub.category),
          reason: '${sub.id} has invalid category: ${sub.category}',
        );
      }
    });

    test('gettingStartedContent is not empty', () {
      expect(EngineData.gettingStartedContent, isNotEmpty);
    });

    test('gettingStartedCode is not empty', () {
      expect(EngineData.gettingStartedCode, isNotEmpty);
    });

    test('examples list is not empty', () {
      expect(EngineData.examples, isNotEmpty);
    });

    test('each example has required fields', () {
      for (final ex in EngineData.examples) {
        expect(ex.id, isNotEmpty, reason: 'Example has empty id');
        expect(ex.title, isNotEmpty, reason: '${ex.id} has empty title');
        expect(
          ex.description,
          isNotEmpty,
          reason: '${ex.id} has empty description',
        );
        expect(ex.code, isNotEmpty, reason: '${ex.id} has empty code');
      }
    });

    test('example ids are unique', () {
      final ids = EngineData.examples.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('flameComparison list is not empty', () {
      expect(EngineData.flameComparison, isNotEmpty);
    });

    test('each comparison point has required fields', () {
      for (final cp in EngineData.flameComparison) {
        expect(cp.title, isNotEmpty);
        expect(cp.description, isNotEmpty);
      }
    });
  });
}
