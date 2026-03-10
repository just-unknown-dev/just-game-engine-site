import 'package:flutter_bloc/flutter_bloc.dart';

import 'examples_state.dart';

/// Cubit managing the Examples page state.
class ExamplesCubit extends Cubit<ExamplesState> {
  ExamplesCubit() : super(const ExamplesState());

  void selectExample(String id) {
    emit(state.copyWith(selectedExampleId: id));
  }
}
