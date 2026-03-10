import 'package:flutter_bloc/flutter_bloc.dart';

import 'features_state.dart';

/// Cubit managing the Features page state.
class FeaturesCubit extends Cubit<FeaturesState> {
  FeaturesCubit() : super(const FeaturesState());

  void selectSubsystem(String id) {
    emit(state.copyWith(selectedSubsystemId: id));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }

  void filterByCategory(String category) {
    emit(state.copyWith(filterCategory: category, clearSelection: true));
  }
}
