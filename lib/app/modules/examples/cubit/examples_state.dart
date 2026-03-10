import 'package:equatable/equatable.dart';

/// State for the Examples page.
class ExamplesState extends Equatable {
  final String selectedExampleId;

  const ExamplesState({this.selectedExampleId = 'basic-setup'});

  ExamplesState copyWith({String? selectedExampleId}) {
    return ExamplesState(
      selectedExampleId: selectedExampleId ?? this.selectedExampleId,
    );
  }

  @override
  List<Object?> get props => [selectedExampleId];
}
