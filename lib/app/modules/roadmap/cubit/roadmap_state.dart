import 'package:equatable/equatable.dart';

/// State for the Roadmap page: which status is shown.
class RoadmapState extends Equatable {
  const RoadmapState({this.filterStatus = all});

  static const all = 'All';

  final String filterStatus;

  RoadmapState copyWith({String? filterStatus}) =>
      RoadmapState(filterStatus: filterStatus ?? this.filterStatus);

  @override
  List<Object?> get props => [filterStatus];
}
