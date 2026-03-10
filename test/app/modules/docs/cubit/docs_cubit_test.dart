import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/modules/docs/cubit/docs_cubit.dart';
import 'package:just_game_engine_site/app/modules/docs/cubit/docs_state.dart';

void main() {
  group('DocsCubit', () {
    late DocsCubit cubit;

    setUp(() {
      cubit = DocsCubit();
    });

    tearDown(() => cubit.close());

    test('initial state defaults to getting-started', () {
      expect(cubit.state, const DocsState(currentSection: 'getting-started'));
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.expandedApiSections, isEmpty);
    });

    test('accepts custom initial section', () {
      final custom = DocsCubit(initialSection: 'rendering');
      expect(custom.state.currentSection, 'rendering');
      custom.close();
    });

    blocTest<DocsCubit, DocsState>(
      'navigateToSection emits state with new section',
      build: () => DocsCubit(),
      act: (cubit) => cubit.navigateToSection('physics'),
      expect: () => [const DocsState(currentSection: 'physics')],
    );

    blocTest<DocsCubit, DocsState>(
      'search emits state with search query',
      build: () => DocsCubit(),
      act: (cubit) => cubit.search('sprite'),
      expect: () => [
        const DocsState(
          currentSection: 'getting-started',
          searchQuery: 'sprite',
        ),
      ],
    );

    blocTest<DocsCubit, DocsState>(
      'toggleApiSection adds section when not expanded',
      build: () => DocsCubit(),
      act: (cubit) => cubit.toggleApiSection('core'),
      expect: () => [
        const DocsState(expandedApiSections: {'core'}),
      ],
    );

    blocTest<DocsCubit, DocsState>(
      'toggleApiSection removes section when already expanded',
      build: () => DocsCubit(),
      seed: () => const DocsState(expandedApiSections: {'core', 'rendering'}),
      act: (cubit) => cubit.toggleApiSection('core'),
      expect: () => [
        const DocsState(expandedApiSections: {'rendering'}),
      ],
    );

    blocTest<DocsCubit, DocsState>(
      'navigateToSection then search works sequentially',
      build: () => DocsCubit(),
      act: (cubit) {
        cubit.navigateToSection('ecs');
        cubit.search('component');
      },
      expect: () => [
        const DocsState(currentSection: 'ecs'),
        const DocsState(currentSection: 'ecs', searchQuery: 'component'),
      ],
    );
  });

  group('DocsState', () {
    test('supports value comparison', () {
      expect(const DocsState(), const DocsState());
    });

    test('different sections are not equal', () {
      expect(
        const DocsState(currentSection: 'core'),
        isNot(const DocsState(currentSection: 'physics')),
      );
    });

    test('copyWith returns new instance with updated values', () {
      const state = DocsState();
      final updated = state.copyWith(
        currentSection: 'rendering',
        searchQuery: 'test',
      );
      expect(updated.currentSection, 'rendering');
      expect(updated.searchQuery, 'test');
      expect(updated.expandedApiSections, isEmpty);
    });

    test('copyWith preserves unset fields', () {
      const state = DocsState(
        currentSection: 'physics',
        searchQuery: 'gravity',
        expandedApiSections: {'physics'},
      );
      final updated = state.copyWith(searchQuery: 'force');
      expect(updated.currentSection, 'physics');
      expect(updated.searchQuery, 'force');
      expect(updated.expandedApiSections, {'physics'});
    });

    test('props contains all fields', () {
      const state = DocsState(
        currentSection: 'core',
        searchQuery: 'query',
        expandedApiSections: {'a'},
      );
      expect(state.props, [
        'core',
        'query',
        {'a'},
      ]);
    });
  });
}
