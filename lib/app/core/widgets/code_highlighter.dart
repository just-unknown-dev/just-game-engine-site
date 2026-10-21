import 'package:flutter/painting.dart';

/// A small line-by-line syntax colourer for the languages the docs use.
///
/// It is deliberately simple: it colours keywords, types, strings, numbers,
/// comments and keys well enough to read, without a full parser.
class CodeHighlighter {
  CodeHighlighter(String language, {required this.base})
    : language = language.toLowerCase();

  final String language;
  final TextStyle base;

  static const keyword = Color(0xFFC792EA);
  static const type = Color(0xFF7FD6C2);
  static const string = Color(0xFFE6C07B);
  static const number = Color(0xFFF78C6C);
  static const comment = Color(0xFF6C7491);
  static const function = Color(0xFF82AAFF);
  static const annotation = Color(0xFFFFCB6B);
  static const punctuation = Color(0xFF9AA3C2);
  static const command = Color(0xFFF5746F);

  static const _dartKeywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'base',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'sealed',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'when',
    'while',
    'with',
    'yield',
    'int',
    'double',
    'num',
    'bool',
  };

  static const _shellCommands = {
    'flutter',
    'dart',
    'just',
    'ju',
    'cd',
    'sudo',
    'apt',
    'git',
    'mkdir',
  };

  static final _dartToken = RegExp(
    r"(//.*$)"
    r"|('(?:[^'\\]|\\.)*'?|"
    r'"(?:[^"\\]|\\.)*"?)'
    r"|(@\w+)"
    r"|(\b\d+(?:\.\d+)?\b)"
    r"|([A-Za-z_$][\w$]*)"
    r"|(\s+)"
    r"|(.)",
  );

  static final _jsonToken = RegExp(
    r'("(?:[^"\\]|\\.)*"\s*:)'
    r'|("(?:[^"\\]|\\.)*")'
    r'|(\b-?\d+(?:\.\d+)?\b)'
    r'|(\btrue\b|\bfalse\b|\bnull\b)'
    r'|(\s+|.)',
  );

  List<TextSpan> line(String text) {
    switch (language) {
      case 'dart':
        return _dart(text);
      case 'yaml':
      case 'yml':
        return _yaml(text);
      case 'bash':
      case 'sh':
      case 'shell':
        return _shell(text);
      case 'json':
        return _json(text);
      default:
        return _plain(text);
    }
  }

  TextSpan _span(String text, Color color, {bool italic = false}) => TextSpan(
    text: text,
    style: TextStyle(color: color, fontStyle: italic ? FontStyle.italic : null),
  );

  List<TextSpan> _dart(String text) {
    final spans = <TextSpan>[];
    for (final m in _dartToken.allMatches(text)) {
      final token = m.group(0)!;
      if (m.group(1) != null) {
        spans.add(_span(token, comment, italic: true));
      } else if (m.group(2) != null) {
        spans.add(_span(token, string));
      } else if (m.group(3) != null) {
        spans.add(_span(token, annotation));
      } else if (m.group(4) != null) {
        spans.add(_span(token, number));
      } else if (m.group(5) != null) {
        if (_dartKeywords.contains(token)) {
          spans.add(_span(token, keyword));
        } else if (RegExp(r'^_?[A-Z]').hasMatch(token)) {
          spans.add(_span(token, type));
        } else if (_followedByParen(text, m.end)) {
          spans.add(_span(token, function));
        } else {
          spans.add(TextSpan(text: token));
        }
      } else if (m.group(7) != null && '(){}[]<>;,.=:?!'.contains(token)) {
        spans.add(_span(token, punctuation));
      } else {
        spans.add(TextSpan(text: token));
      }
    }
    return spans;
  }

  bool _followedByParen(String text, int end) {
    var i = end;
    while (i < text.length && text[i] == ' ') {
      i++;
    }
    return i < text.length && (text[i] == '(' || text[i] == '<');
  }

  List<TextSpan> _yaml(String text) {
    final hash = _commentStart(text);
    final codePart = hash == -1 ? text : text.substring(0, hash);
    final spans = <TextSpan>[];
    final key = RegExp(r'^(\s*-?\s*)([\w.\-/]+)(:)(.*)$').firstMatch(codePart);
    if (key != null) {
      spans
        ..add(TextSpan(text: key.group(1)))
        ..add(_span(key.group(2)!, type))
        ..add(_span(key.group(3)!, punctuation))
        ..addAll(_yamlValue(key.group(4)!));
    } else {
      spans.addAll(_yamlValue(codePart));
    }
    if (hash != -1) {
      spans.add(_span(text.substring(hash), comment, italic: true));
    }
    return spans;
  }

  List<TextSpan> _yamlValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return [TextSpan(text: value)];
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(trimmed) ||
        trimmed == 'true' ||
        trimmed == 'false') {
      return [_span(value, number)];
    }
    return [_span(value, string)];
  }

  List<TextSpan> _shell(String text) {
    final hash = _commentStart(text);
    final codePart = hash == -1 ? text : text.substring(0, hash);
    final spans = <TextSpan>[];
    final words = RegExp(r'(\s+)|([^\s]+)').allMatches(codePart);
    var first = true;
    for (final w in words) {
      final token = w.group(0)!;
      if (w.group(1) != null) {
        spans.add(TextSpan(text: token));
        continue;
      }
      if (first && _shellCommands.contains(token)) {
        spans.add(_span(token, command));
      } else if (token.startsWith('-')) {
        spans.add(_span(token, keyword));
      } else if (token == '|' || token == '&&' || token == ';') {
        spans.add(_span(token, punctuation));
        first = true;
        continue;
      } else {
        spans.add(TextSpan(text: token));
      }
      first = false;
    }
    if (hash != -1) {
      spans.add(_span(text.substring(hash), comment, italic: true));
    }
    return spans;
  }

  List<TextSpan> _json(String text) {
    final spans = <TextSpan>[];
    for (final m in _jsonToken.allMatches(text)) {
      final token = m.group(0)!;
      if (m.group(1) != null) {
        spans.add(_span(token, type));
      } else if (m.group(2) != null) {
        spans.add(_span(token, string));
      } else if (m.group(3) != null || m.group(4) != null) {
        spans.add(_span(token, number));
      } else {
        spans.add(TextSpan(text: token));
      }
    }
    return spans;
  }

  List<TextSpan> _plain(String text) {
    final hash = _commentStart(text);
    if (hash == -1) return [TextSpan(text: text)];
    return [
      TextSpan(text: text.substring(0, hash)),
      _span(text.substring(hash), comment, italic: true),
    ];
  }

  /// Index of a `#` that starts a comment (at the line start or after
  /// whitespace, outside quotes), or -1.
  int _commentStart(String text) {
    var inSingle = false;
    var inDouble = false;
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == "'" && !inDouble) inSingle = !inSingle;
      if (c == '"' && !inSingle) inDouble = !inDouble;
      if (c == '#' && !inSingle && !inDouble) {
        if (i == 0 || text[i - 1] == ' ' || text[i - 1] == '\t') return i;
      }
    }
    return -1;
  }
}
