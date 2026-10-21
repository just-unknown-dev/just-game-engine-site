import 'package:flutter_bloc/flutter_bloc.dart';

import 'docs_state.dart';

/// Cubit managing the Docs page: which page is open, and the search text.
///
/// The URL (`/docs/<id>`) is the source of truth; the view calls
/// [navigateToSection] when it changes.
class DocsCubit extends Cubit<DocsState> {
  DocsCubit({String initialSection = 'introduction'})
    : super(DocsState(currentSection: initialSection));

  void navigateToSection(String sectionId) {
    emit(state.copyWith(currentSection: sectionId));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() => search('');
}
