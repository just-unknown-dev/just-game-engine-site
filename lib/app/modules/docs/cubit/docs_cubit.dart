import 'package:flutter_bloc/flutter_bloc.dart';

import 'docs_state.dart';

/// Cubit managing the Docs page state.
class DocsCubit extends Cubit<DocsState> {
  DocsCubit({String initialSection = 'getting-started'})
    : super(DocsState(currentSection: initialSection));

  void navigateToSection(String sectionId) {
    emit(state.copyWith(currentSection: sectionId));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleApiSection(String sectionId) {
    final expanded = Set<String>.from(state.expandedApiSections);
    if (expanded.contains(sectionId)) {
      expanded.remove(sectionId);
    } else {
      expanded.add(sectionId);
    }
    emit(state.copyWith(expandedApiSections: expanded));
  }
}
