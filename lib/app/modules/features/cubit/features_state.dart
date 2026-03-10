import 'package:equatable/equatable.dart';

/// State for the Features page.
class FeaturesState extends Equatable {
  final String? selectedSubsystemId;
  final String filterCategory;

  const FeaturesState({this.selectedSubsystemId, this.filterCategory = 'All'});

  FeaturesState copyWith({
    String? selectedSubsystemId,
    String? filterCategory,
    bool clearSelection = false,
  }) {
    return FeaturesState(
      selectedSubsystemId: clearSelection
          ? null
          : (selectedSubsystemId ?? this.selectedSubsystemId),
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }

  @override
  List<Object?> get props => [selectedSubsystemId, filterCategory];
}
