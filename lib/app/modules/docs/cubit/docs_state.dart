import 'package:equatable/equatable.dart';

/// State for the Docs page.
class DocsState extends Equatable {
  final String currentSection;
  final String searchQuery;
  final Set<String> expandedApiSections;

  const DocsState({
    this.currentSection = 'getting-started',
    this.searchQuery = '',
    this.expandedApiSections = const {},
  });

  DocsState copyWith({
    String? currentSection,
    String? searchQuery,
    Set<String>? expandedApiSections,
  }) {
    return DocsState(
      currentSection: currentSection ?? this.currentSection,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedApiSections: expandedApiSections ?? this.expandedApiSections,
    );
  }

  @override
  List<Object?> get props => [currentSection, searchQuery, expandedApiSections];
}
