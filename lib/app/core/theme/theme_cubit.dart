import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_storage.dart';

/// The site's light/dark choice. Dark is the default; a visitor's choice is
/// saved and restored on their next visit.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({ThemeMode? initial})
    : super(initial ?? _fromStorage(ThemeStorage.read()));

  static ThemeMode _fromStorage(String? value) =>
      value == 'light' ? ThemeMode.light : ThemeMode.dark;

  bool get isDark => state == ThemeMode.dark;

  void toggle() => set(isDark ? ThemeMode.light : ThemeMode.dark);

  void set(ThemeMode mode) {
    if (mode == state) return;
    ThemeStorage.write(mode == ThemeMode.light ? 'light' : 'dark');
    emit(mode);
  }
}
