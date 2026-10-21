import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/core/constants/features_data.dart';
import 'package:just_game_engine_site/app/modules/features/cubit/features_cubit.dart';
import 'package:just_game_engine_site/app/modules/features/cubit/features_state.dart';
import 'package:just_game_engine_site/app/modules/roadmap/cubit/roadmap_cubit.dart';
import 'package:just_game_engine_site/app/modules/roadmap/cubit/roadmap_state.dart';

void main() {
  group('FeaturesCubit', () {
    test('starts showing every category', () {
      final cubit = FeaturesCubit();
      expect(cubit.state, const FeaturesState());
      expect(cubit.state.filterCategory, FeaturesState.all);
      cubit.close();
    });

    blocTest<FeaturesCubit, FeaturesState>(
      'filterByCategory picks one category',
      build: FeaturesCubit.new,
      act: (cubit) => cubit.filterByCategory(FeatureCategory.graphics),
      expect: () => [
        const FeaturesState(filterCategory: FeatureCategory.graphics),
      ],
    );

    blocTest<FeaturesCubit, FeaturesState>(
      'filterByCategory can go back to all',
      build: FeaturesCubit.new,
      seed: () => const FeaturesState(filterCategory: FeatureCategory.core),
      act: (cubit) => cubit.filterByCategory(FeaturesState.all),
      expect: () => [const FeaturesState()],
    );
  });

  group('RoadmapCubit', () {
    blocTest<RoadmapCubit, RoadmapState>(
      'filterByStatus picks one status',
      build: RoadmapCubit.new,
      act: (cubit) => cubit.filterByStatus('Shipped'),
      expect: () => [const RoadmapState(filterStatus: 'Shipped')],
    );
  });
}
