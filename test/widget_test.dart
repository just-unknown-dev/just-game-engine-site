import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_game_engine_site/app/core/theme/app_palette.dart';
import 'package:just_game_engine_site/app/core/theme/app_theme.dart';
import 'package:just_game_engine_site/app/core/theme/theme_cubit.dart';
import 'package:just_game_engine_site/app/core/widgets/code_block.dart';
import 'package:just_game_engine_site/app/core/widgets/code_highlighter.dart';
import 'package:just_game_engine_site/app/core/widgets/markdown_view.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  // Tests have no network: render with the fallback font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('CodeBlock', () {
    testWidgets('renders the code and a copy button', (tester) async {
      await tester.pumpWidget(_app(const CodeBlock(code: 'void main() {}')));
      expect(find.textContaining('main', findRichText: true), findsWidgets);
      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('shows the title in the header', (tester) async {
      await tester.pumpWidget(
        _app(const CodeBlock(code: 'x', title: 'lib/main.dart')),
      );
      expect(find.text('lib/main.dart'), findsOneWidget);
    });
  });

  group('CodeHighlighter', () {
    const base = TextStyle();

    test('colours Dart keywords and types', () {
      final spans = CodeHighlighter(
        'dart',
        base: base,
      ).line('final e = Engine();');
      final keyword = spans.firstWhere((s) => s.text == 'final');
      final type = spans.firstWhere((s) => s.text == 'Engine');
      expect(keyword.style?.color, CodeHighlighter.keyword);
      expect(type.style?.color, CodeHighlighter.type);
    });

    test('colours a shell command and its comment', () {
      final spans = CodeHighlighter(
        'bash',
        base: base,
      ).line('just game run   # with the editor');
      expect(spans.first.style?.color, CodeHighlighter.command);
      expect(spans.last.style?.color, CodeHighlighter.comment);
    });

    test('colours YAML keys', () {
      final spans = CodeHighlighter(
        'yaml',
        base: base,
      ).line('  just_game_engine: ^2.0.0-dev.2');
      expect(
        spans.any(
          (s) =>
              s.text == 'just_game_engine' &&
              s.style?.color == CodeHighlighter.type,
        ),
        isTrue,
      );
    });
  });

  group('MarkdownView', () {
    const source = '''
## Install it

Add **the engine** with `flutter pub add`. See [the docs](/docs/ecs).

- one
- two
  continued

### Details

```dart lib/main.dart
void main() {}
```

> **Note:** a callout.

| Name | Value |
|---|---|
| `a \\| b` | 1 |

## Next part
''';

    test('outline lists the ## headings with slugs', () {
      final outline = MarkdownView.outline(source);
      expect(outline.map((h) => h.text), ['Install it', 'Next part']);
      expect(outline.map((h) => h.slug), ['install-it', 'next-part']);
    });

    testWidgets('renders every block kind', (tester) async {
      await tester.pumpWidget(_app(const MarkdownView(source)));
      expect(find.text('Install it'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('lib/main.dart'), findsOneWidget);
      expect(find.byType(CodeBlock), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(
        find.textContaining('two continued', findRichText: true),
        findsOneWidget,
      );
    });

    test('slugify makes URL-friendly ids', () {
      expect(slugify('Engine & lifecycle'), 'engine-lifecycle');
      expect(slugify('`GameWidget` options'), 'gamewidget-options');
    });
  });

  group('Theme', () {
    test('the dark palette keeps the brand coral', () {
      expect(AppPalette.dark.accent, const Color(0xFFF5746F));
      expect(AppPalette.dark.isDark, isTrue);
      expect(AppPalette.light.isDark, isFalse);
    });

    test('both themes carry their palette', () {
      expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
      expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
    });

    test('ThemeCubit starts dark and toggles', () {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.dark);
      cubit.toggle();
      expect(cubit.state, ThemeMode.light);
      cubit.toggle();
      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });
  });
}
