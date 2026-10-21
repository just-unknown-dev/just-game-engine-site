import 'package:web/web.dart' as web;

// Storage can be unavailable (private windows, blocked site data); the site
// then simply falls back to the default theme.

String? readTheme(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void writeTheme(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}
}
