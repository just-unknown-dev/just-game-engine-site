import 'package:flutter_bloc/flutter_bloc.dart';

import 'features_state.dart';

/// Cubit managing the Features page's category filter.
class FeaturesCubit extends Cubit<FeaturesState> {
  FeaturesCubit() : super(const FeaturesState());

  void filterByCategory(String category) {
    emit(state.copyWith(filterCategory: category));
  }
}
