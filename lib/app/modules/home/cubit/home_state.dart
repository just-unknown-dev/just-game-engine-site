part of 'home_cubit.dart';

class HomeState {
  final int count;

  const HomeState({this.count = 0});

  HomeState copyWith({int? count}) => HomeState(count: count ?? this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HomeState && other.count == count;

  @override
  int get hashCode => count.hashCode;
}
