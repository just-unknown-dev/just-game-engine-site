import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/modules/features/cubit/features_cubit.dart';
import 'package:just_game_engine_site/app/modules/features/cubit/features_state.dart';

void main() {
  group('FeaturesCubit', () {
    late FeaturesCubit cubit;

    setUp(() {
      cubit = FeaturesCubit();
    });

    tearDown(() => cubit.close());

    test('initial state is correct', () {
      expect(cubit.state, const FeaturesState());
      expect(cubit.state.selectedSubsystemId, isNull);
      expect(cubit.state.filterCategory, 'All');
    });

    blocTest<FeaturesCubit, FeaturesState>(
      'selectSubsystem emits state with selected id',
      build: () => FeaturesCubit(),
      act: (cubit) => cubit.selectSubsystem('rendering'),
      expect: () => [const FeaturesState(selectedSubsystemId: 'rendering')],
    );

    blocTest<FeaturesCubit, FeaturesState>(
      'clearSelection emits state with null selectedSubsystemId',
      build: () => FeaturesCubit(),
      seed: () => const FeaturesState(selectedSubsystemId: 'core'),
      act: (cubit) => cubit.clearSelection(),
      expect: () => [const FeaturesState(selectedSubsystemId: null)],
    );

    blocTest<FeaturesCubit, FeaturesState>(
      'filterByCategory emits state with new category and clears selection',
      build: () => FeaturesCubit(),
      seed: () => const FeaturesState(
        selectedSubsystemId: 'core',
        filterCategory: 'All',
      ),
      act: (cubit) => cubit.filterByCategory('Visual'),
      expect: () => [
        const FeaturesState(
          selectedSubsystemId: null,
          filterCategory: 'Visual',
        ),
      ],
    );

    blocTest<FeaturesCubit, FeaturesState>(
      'selectSubsystem then clearSelection works sequentially',
      build: () => FeaturesCubit(),
      act: (cubit) {
        cubit.selectSubsystem('physics');
        cubit.clearSelection();
      },
      expect: () => [
        const FeaturesState(selectedSubsystemId: 'physics'),
        const FeaturesState(selectedSubsystemId: null),
      ],
    );
  });

  group('FeaturesState', () {
    test('supports value comparison', () {
      expect(const FeaturesState(), const FeaturesState());
    });

    test('copyWith returns new instance with updated values', () {
      const state = FeaturesState(filterCategory: 'All');
      final updated = state.copyWith(filterCategory: 'Core Systems');
      expect(updated.filterCategory, 'Core Systems');
      expect(updated.selectedSubsystemId, isNull);
    });

    test('copyWith with clearSelection nullifies selectedSubsystemId', () {
      const state = FeaturesState(selectedSubsystemId: 'ecs');
      final cleared = state.copyWith(clearSelection: true);
      expect(cleared.selectedSubsystemId, isNull);
    });

    test('props contains all fields', () {
      const state = FeaturesState(
        selectedSubsystemId: 'core',
        filterCategory: 'Visual',
      );
      expect(state.props, ['core', 'Visual']);
    });
  });
}
