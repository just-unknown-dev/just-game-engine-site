import 'theme_storage_stub.dart'
    if (dart.library.js_interop) 'theme_storage_web.dart'
    as impl;

/// Where the visitor's theme choice is kept between visits.
///
/// On the web this is `localStorage` under [key]; `web/index.html` reads the
/// same key before Flutter starts, so the loading screen matches. Elsewhere
/// (tests) nothing is kept.
abstract final class ThemeStorage {
  static const key = 'jge:theme';

  /// 'light', 'dark', or null when nothing was saved.
  static String? read() => impl.readTheme(key);

  static void write(String value) => impl.writeTheme(key, value);
}
