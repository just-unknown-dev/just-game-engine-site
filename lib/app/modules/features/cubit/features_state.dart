import 'package:equatable/equatable.dart';

/// State for the Features page: which category is shown.
class FeaturesState extends Equatable {
  const FeaturesState({this.filterCategory = all});

  static const all = 'All';

  final String filterCategory;

  FeaturesState copyWith({String? filterCategory}) =>
      FeaturesState(filterCategory: filterCategory ?? this.filterCategory);

  @override
  List<Object?> get props => [filterCategory];
}
