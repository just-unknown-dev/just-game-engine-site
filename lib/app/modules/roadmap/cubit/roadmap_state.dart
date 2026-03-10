import 'package:equatable/equatable.dart';

/// State for the Roadmap page.
class RoadmapState extends Equatable {
  final String filterStatus;

  const RoadmapState({this.filterStatus = 'All'});

  RoadmapState copyWith({String? filterStatus}) {
    return RoadmapState(filterStatus: filterStatus ?? this.filterStatus);
  }

  @override
  List<Object?> get props => [filterStatus];
}
