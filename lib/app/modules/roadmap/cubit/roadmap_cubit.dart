import 'package:flutter_bloc/flutter_bloc.dart';

import 'roadmap_state.dart';

/// Cubit managing the Roadmap page state.
class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit() : super(const RoadmapState());

  void filterByStatus(String status) {
    emit(state.copyWith(filterStatus: status));
  }
}
