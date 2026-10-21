import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import '../utils/open_link.dart';
import 'code_block.dart';

/// A `##` heading of a document, for its "On this page" list.
class MarkdownHeading {
  const MarkdownHeading(this.text, this.slug);

  final String text;
  final String slug;
}

/// Renders the Markdown subset the docs are written in (see `DocPage`).
class MarkdownView extends StatelessWidget {
  const MarkdownView(this.source, {super.key, this.anchors = const {}});

  final String source;

  /// Keys to attach to `##` headings, by slug, so a page can scroll to them.
  final Map<String, GlobalKey> anchors;

  /// The `##` headings of [source], in order.
  static List<MarkdownHeading> outline(String source) => [
    for (final b in _parse(source))
      if (b is _Heading && b.level == 2) MarkdownHeading(b.text, b.slug),
  ];

  @override
  Widget build(BuildContext context) {
    final blocks = _parse(source);
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      children.add(_buildBlock(context, blocks[i], first: i == 0));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildBlock(
    BuildContext context,
    _Block block, {
    required bool first,
  }) {
    final t = context.type;
    final p = context.palette;
    switch (block) {
      case _Heading(:final level, :final text, :final slug):
        final style = level == 2
            ? t.h2.copyWith(fontSize: 26, letterSpacing: -0.4)
            : t.h3.copyWith(fontSize: 19);
        return Padding(
          key: level == 2 ? anchors[slug] : null,
          padding: EdgeInsets.only(
            top: first ? 0 : (level == 2 ? 44 : 30),
            bottom: level == 2 ? 14 : 10,
          ),
          child: InlineText(text, style: style),
        );
      case _Paragraph(:final text):
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: InlineText(text, style: t.body),
        );
      case _ListBlock(:final ordered, :final items):
        return Padding(
          padding: const EdgeInsets.only(bottom: 18, left: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 26,
                        child: ordered
                            ? Text(
                                '${i + 1}.',
                                style: t.body.copyWith(
                                  color: p.accentText,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  top: 11,
                                  left: 4,
                                ),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: p.accent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Expanded(child: InlineText(items[i], style: t.body)),
                    ],
                  ),
                ),
            ],
          ),
        );
      case _Code(:final language, :final title, :final code):
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 22),
          child: CodeBlock(code: code, language: language, title: title),
        );
      case _Callout(:final kind, :final text):
        final (color, icon) = switch (kind) {
          'warning' => (p.warning, Icons.warning_amber_rounded),
          'tip' => (p.success, Icons.lightbulb_outline_rounded),
          _ => (p.info, Icons.info_outline_rounded),
        };
        return Container(
          margin: const EdgeInsets.only(top: 2, bottom: 22),
          padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: p.isDark ? 0.08 : 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, para) in text.split('\n\n').indexed)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                        child: InlineText(
                          para,
                          style: t.bodySmall.copyWith(
                            fontSize: 15,
                            color: p.textPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case _Table(:final header, :final rows):
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 24),
          child: _MarkdownTable(header: header, rows: rows),
        );
    }
  }
}

class _MarkdownTable extends StatelessWidget {
  const _MarkdownTable({required this.header, required this.rows});

  final List<String> header;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final columns = header.length;

    TableRow row(List<String> cells, {required bool head, required int index}) {
      return TableRow(
        decoration: BoxDecoration(
          color: head
              ? p.surfaceAlt
              : (index.isOdd ? p.surface.withValues(alpha: 0.5) : null),
          border: head ? null : Border(top: BorderSide(color: p.border)),
        ),
        children: [
          for (var c = 0; c < columns; c++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: InlineText(
                c < cells.length ? cells[c] : '',
                style: head
                    ? t.label.copyWith(fontSize: 13.5)
                    : t.bodySmall.copyWith(fontSize: 14),
              ),
            ),
        ],
      );
    }

    final table = Table(
      defaultColumnWidth: const FlexColumnWidth(),
      columnWidths: columns >= 3
          ? const {0: FlexColumnWidth(0.8)}
          : const {0: FlexColumnWidth(0.6)},
      children: [
        row(header, head: true, index: 0),
        for (var i = 0; i < rows.length; i++)
          row(rows[i], head: false, index: i),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = columns * 170.0;
        final framed = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: table,
        );
        if (constraints.maxWidth >= minWidth) return framed;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: framed),
        );
      },
    );
  }
}

/// Text with the inline Markdown subset: `code`, **bold** and [links](url).
class InlineText extends StatefulWidget {
  const InlineText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<InlineText> {
  final _recognizers = <TapGestureRecognizer>[];

  static final _token = RegExp(
    r'(`[^`]+`)|(\*\*(.+?)\*\*)|(\[([^\]]+)\]\(([^)\s]+)\))',
  );

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  List<InlineSpan> _spans(String text, TextStyle style) {
    final p = context.palette;
    final t = context.type;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _token.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        final code = m.group(1)!;
        spans.add(
          TextSpan(
            text: ' ${code.substring(1, code.length - 1)} ',
            style: t.inlineCode.copyWith(
              fontSize: (style.fontSize ?? 16) * 0.86,
              color: p.textPrimary,
              backgroundColor: p.isDark
                  ? p.surfaceAlt
                  : p.textPrimary.withValues(alpha: 0.06),
            ),
          ),
        );
      } else if (m.group(2) != null) {
        spans.add(
          TextSpan(
            children: _spans(m.group(3)!, style),
            style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary),
          ),
        );
      } else {
        final label = m.group(5)!;
        final url = m.group(6)!;
        final recognizer = TapGestureRecognizer()
          ..onTap = () => openLink(context, url);
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            children: _spans(label, style),
            recognizer: recognizer,
            mouseCursor: SystemMouseCursors.click,
            style: TextStyle(
              color: p.accentText,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: p.accentText.withValues(alpha: 0.4),
            ),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    return Text.rich(
      TextSpan(children: _spans(widget.text, widget.style)),
      style: widget.style,
    );
  }
}

// ── Parsing ────────────────────────────────────────────────────────────────

sealed class _Block {
  const _Block();
}

class _Heading extends _Block {
  const _Heading(this.level, this.text, this.slug);
  final int level;
  final String text;
  final String slug;
}

class _Paragraph extends _Block {
  const _Paragraph(this.text);
  final String text;
}

class _ListBlock extends _Block {
  const _ListBlock(this.ordered, this.items);
  final bool ordered;
  final List<String> items;
}

class _Code extends _Block {
  const _Code(this.language, this.title, this.code);
  final String language;
  final String? title;
  final String code;
}

class _Callout extends _Block {
  const _Callout(this.kind, this.text);
  final String kind;
  final String text;
}

class _Table extends _Block {
  const _Table(this.header, this.rows);
  final List<String> header;
  final List<List<String>> rows;
}

final _bullet = RegExp(r'^\s{0,1}[-*] (.*)$');
final _numbered = RegExp(r'^\s{0,1}\d+\. (.*)$');
final _parseCache = <String, List<_Block>>{};

/// A URL-friendly id for a heading.
String slugify(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[`*\[\]()]'), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

List<_Block> _parse(String source) =>
    _parseCache.putIfAbsent(source, () => _parseUncached(source));

List<_Block> _parseUncached(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <_Block>[];
  final slugs = <String, int>{};
  var i = 0;

  bool startsBlock(String line) =>
      line.startsWith('```') ||
      line.startsWith('## ') ||
      line.startsWith('### ') ||
      line.startsWith('>') ||
      line.trimLeft().startsWith('|') ||
      _bullet.hasMatch(line) ||
      _numbered.hasMatch(line);

  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      i++;
      continue;
    }

    // Fenced code.
    if (trimmed.startsWith('```')) {
      final info = trimmed.substring(3).trim();
      final space = info.indexOf(' ');
      final language = (space == -1 ? info : info.substring(0, space)).trim();
      final title = space == -1 ? null : info.substring(space + 1).trim();
      final code = <String>[];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        code.add(lines[i]);
        i++;
      }
      i++; // closing fence
      blocks.add(
        _Code(
          language.isEmpty ? 'text' : language,
          title?.isEmpty ?? true ? null : title,
          code.join('\n'),
        ),
      );
      continue;
    }

    // Headings.
    if (line.startsWith('## ') || line.startsWith('### ')) {
      final level = line.startsWith('### ') ? 3 : 2;
      final text = line.substring(level + 1).trim();
      var slug = slugify(text);
      final seen = slugs[slug] ?? 0;
      slugs[slug] = seen + 1;
      if (seen > 0) slug = '$slug-$seen';
      blocks.add(_Heading(level, text, slug));
      i++;
      continue;
    }

    // Callouts.
    if (trimmed.startsWith('>')) {
      final parts = <String>[];
      final current = <String>[];
      while (i < lines.length && lines[i].trim().startsWith('>')) {
        final content = lines[i].trim().substring(1).trim();
        if (content.isEmpty) {
          if (current.isNotEmpty) parts.add(current.join(' '));
          current.clear();
        } else {
          current.add(content);
        }
        i++;
      }
      if (current.isNotEmpty) parts.add(current.join(' '));
      final text = parts.join('\n\n');
      final lower = text.toLowerCase();
      final kind = lower.startsWith('**warning')
          ? 'warning'
          : lower.startsWith('**tip')
          ? 'tip'
          : 'note';
      blocks.add(_Callout(kind, text));
      continue;
    }

    // Tables.
    if (trimmed.startsWith('|')) {
      final rows = <List<String>>[];
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        final cells = _splitRow(lines[i].trim());
        final isSeparator = cells.every(
          (c) => RegExp(r'^:?-{2,}:?$').hasMatch(c.trim()),
        );
        if (!isSeparator) rows.add(cells);
        i++;
      }
      if (rows.isNotEmpty) {
        blocks.add(_Table(rows.first, rows.skip(1).toList()));
      }
      continue;
    }

    // Lists.
    final bulletMatch = _bullet.firstMatch(line);
    final numberMatch = bulletMatch == null ? _numbered.firstMatch(line) : null;
    if (bulletMatch != null || numberMatch != null) {
      final ordered = numberMatch != null;
      final pattern = ordered ? _numbered : _bullet;
      final items = <String>[];
      while (i < lines.length) {
        final l = lines[i];
        final m = pattern.firstMatch(l);
        if (m != null) {
          items.add(m.group(1)!.trim());
          i++;
        } else if (l.startsWith('  ') &&
            l.trim().isNotEmpty &&
            items.isNotEmpty) {
          items[items.length - 1] = '${items.last} ${l.trim()}';
          i++;
        } else {
          break;
        }
      }
      blocks.add(_ListBlock(ordered, items));
      continue;
    }

    // Paragraph.
    final para = <String>[];
    while (i < lines.length &&
        lines[i].trim().isNotEmpty &&
        (para.isEmpty || !startsBlock(lines[i]))) {
      para.add(lines[i].trim());
      i++;
    }
    blocks.add(_Paragraph(para.join(' ')));
  }
  return blocks;
}

/// Splits a `| a | b |` row, keeping `|` inside backticks and `\|`.
List<String> _splitRow(String row) {
  var body = row;
  if (body.startsWith('|')) body = body.substring(1);
  if (body.endsWith('|') && !body.endsWith(r'\|')) {
    body = body.substring(0, body.length - 1);
  }
  final cells = <String>[];
  final cell = StringBuffer();
  var inCode = false;
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if (c == r'\' && i + 1 < body.length && body[i + 1] == '|') {
      cell.write('|');
      i++;
    } else if (c == '`') {
      inCode = !inCode;
      cell.write(c);
    } else if (c == '|' && !inCode) {
      cells.add(cell.toString().trim());
      cell.clear();
    } else {
      cell.write(c);
    }
  }
  cells.add(cell.toString().trim());
  return cells;
}
