import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/modules/docs/cubit/docs_cubit.dart';
import 'package:just_game_engine_site/app/modules/docs/cubit/docs_state.dart';

void main() {
  group('DocsCubit', () {
    test('starts on the introduction', () {
      final cubit = DocsCubit();
      expect(cubit.state, const DocsState(currentSection: 'introduction'));
      expect(cubit.state.searchQuery, '');
      cubit.close();
    });

    test('accepts a custom initial section', () {
      final cubit = DocsCubit(initialSection: 'ecs');
      expect(cubit.state.currentSection, 'ecs');
      cubit.close();
    });

    blocTest<DocsCubit, DocsState>(
      'navigateToSection changes the page',
      build: DocsCubit.new,
      act: (cubit) => cubit.navigateToSection('physics-2d'),
      expect: () => [const DocsState(currentSection: 'physics-2d')],
    );

    blocTest<DocsCubit, DocsState>(
      'search keeps the page and sets the query',
      build: DocsCubit.new,
      act: (cubit) => cubit.search('sprite'),
      expect: () => [
        const DocsState(currentSection: 'introduction', searchQuery: 'sprite'),
      ],
    );

    blocTest<DocsCubit, DocsState>(
      'clearSearch empties the query',
      build: DocsCubit.new,
      seed: () =>
          const DocsState(currentSection: 'ecs', searchQuery: 'component'),
      act: (cubit) => cubit.clearSearch(),
      expect: () => [const DocsState(currentSection: 'ecs')],
    );
  });

  group('DocsState', () {
    test('supports value comparison', () {
      expect(
        const DocsState(currentSection: 'a'),
        const DocsState(currentSection: 'a'),
      );
      expect(
        const DocsState(currentSection: 'a'),
        isNot(const DocsState(currentSection: 'b')),
      );
    });

    test('copyWith keeps fields it is not given', () {
      const state = DocsState(currentSection: 'audio', searchQuery: 'bus');
      final updated = state.copyWith(searchQuery: 'stream');
      expect(updated.currentSection, 'audio');
      expect(updated.searchQuery, 'stream');
    });
  });
}
