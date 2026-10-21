import 'package:equatable/equatable.dart';

/// State for the Docs page: the page shown and the sidebar search.
class DocsState extends Equatable {
  const DocsState({required this.currentSection, this.searchQuery = ''});

  final String currentSection;
  final String searchQuery;

  DocsState copyWith({String? currentSection, String? searchQuery}) {
    return DocsState(
      currentSection: currentSection ?? this.currentSection,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [currentSection, searchQuery];
}
