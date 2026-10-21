import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_type.dart';
import 'code_highlighter.dart';

/// A dark code panel with syntax colours, a header and a copy button.
/// Code panels stay dark in the light theme too.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.language = 'dart',
    this.title,
    this.showLineNumbers = false,
    this.showHeader = true,
  });

  final String code;

  /// `dart`, `yaml`, `bash`, `json` or `text`.
  final String language;
  final String? title;
  final bool showLineNumbers;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final lines = code.trimRight().split('\n');
    final highlighter = CodeHighlighter(language, base: t.code);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.codeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.codeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              decoration: BoxDecoration(
                color: p.codeHeader,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                border: Border(bottom: BorderSide(color: p.codeBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? language,
                      overflow: TextOverflow.ellipsis,
                      style: t.code.copyWith(fontSize: 12, color: p.codeMuted),
                    ),
                  ),
                  CopyButton(text: code.trimRight()),
                ],
              ),
            ),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lines.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showLineNumbers)
                          SizedBox(
                            width: 34,
                            child: Text(
                              '${i + 1}',
                              textAlign: TextAlign.right,
                              style: t.code.copyWith(
                                color: p.codeMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        if (showLineNumbers) const SizedBox(width: 18),
                        Text.rich(
                          TextSpan(
                            children: highlighter.line(lines[i]),
                            style: t.code,
                          ),
                          softWrap: false,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A one-line shell command with a `$` prompt and a copy button.
class CommandLine extends StatelessWidget {
  const CommandLine(this.command, {super.key, this.prompt = r'$'});

  final String command;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = context.type;
    final highlighter = CodeHighlighter('bash', base: t.code);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
      decoration: BoxDecoration(
        color: p.codeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.codeBorder),
      ),
      child: Row(
        children: [
          Text('$prompt ', style: t.code.copyWith(color: p.codeMuted)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(children: highlighter.line(command), style: t.code),
                softWrap: false,
              ),
            ),
          ),
          CopyButton(text: command),
        ],
      ),
    );
  }
}

/// Copies [text] and briefly shows a check mark.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.text});

  final String text;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: _copy,
      tooltip: _copied ? 'Copied' : 'Copy',
      visualDensity: VisualDensity.compact,
      iconSize: 16,
      style: IconButton.styleFrom(
        hoverColor: Colors.white.withValues(alpha: 0.06),
      ),
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.content_copy_rounded,
        color: _copied ? const Color(0xFF4ADE80) : p.codeMuted,
      ),
    );
  }
}
