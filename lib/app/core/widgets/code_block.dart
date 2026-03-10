import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A styled code block with syntax highlighting for Dart code.
///
/// Supports copy-to-clipboard, optional title, and optional line numbers.
class CodeBlock extends StatefulWidget {
  final String code;
  final String? title;
  final bool showLineNumbers;
  final bool showCopyButton;

  const CodeBlock({
    super.key,
    required this.code,
    this.title,
    this.showLineNumbers = true,
    this.showCopyButton = true,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.code.split('\n');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        border: Border.all(color: AppColors.codeBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────
          if (widget.title != null || widget.showCopyButton)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                border: Border(bottom: BorderSide(color: AppColors.codeBorder)),
              ),
              child: Row(
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: AppTextStyles.codeSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  const Spacer(),
                  if (widget.showCopyButton)
                    InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _copied ? Icons.check : Icons.copy,
                              size: 14,
                              color: _copied
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _copied ? 'Copied!' : 'Copy',
                              style: AppTextStyles.codeSmall.copyWith(
                                color: _copied
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // ── Code body ─────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < lines.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showLineNumbers)
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.codeSmall.copyWith(
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      if (widget.showLineNumbers) const SizedBox(width: 16),
                      _SyntaxHighlightedLine(line: lines[i]),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple Dart syntax highlighter.
class _SyntaxHighlightedLine extends StatelessWidget {
  final String line;
  const _SyntaxHighlightedLine({required this.line});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _highlight(line), style: AppTextStyles.code),
    );
  }

  static const _keywords = {
    'import',
    'export',
    'class',
    'extends',
    'implements',
    'with',
    'abstract',
    'final',
    'const',
    'var',
    'void',
    'int',
    'double',
    'String',
    'bool',
    'dynamic',
    'Future',
    'async',
    'await',
    'return',
    'if',
    'else',
    'for',
    'while',
    'do',
    'switch',
    'case',
    'break',
    'continue',
    'new',
    'this',
    'super',
    'null',
    'true',
    'false',
    'static',
    'late',
    'required',
    'override',
    'enum',
    'mixin',
    'typedef',
    'is',
    'as',
    'in',
    'get',
    'set',
    'part',
    'library',
    'show',
    'hide',
    'factory',
    'operator',
  };

  static const _builtInTypes = {
    'Widget',
    'BuildContext',
    'State',
    'StatelessWidget',
    'StatefulWidget',
    'MaterialApp',
    'Scaffold',
    'Container',
    'Column',
    'Row',
    'Text',
    'Offset',
    'Size',
    'Color',
    'Colors',
    'EdgeInsets',
    'BoxDecoration',
    'BorderRadius',
    'Icon',
    'Engine',
    'GameLoop',
    'TimeManager',
    'SystemManager',
    'RenderingEngine',
    'Camera',
    'CircleRenderable',
    'RectangleRenderable',
    'LineRenderable',
    'TextRenderable',
    'CustomRenderable',
    'Sprite',
    'SpriteSheet',
    'NineSliceSprite',
    'SpriteAnimation',
    'PositionTween',
    'RotationTween',
    'ScaleTween',
    'OpacityTween',
    'ColorTween',
    'AnimationSequence',
    'AnimationGroup',
    'Easings',
    'ParticleEmitter',
    'Particle',
    'ParticleEffects',
    'PhysicsEngine',
    'PhysicsBody',
    'SceneEditor',
    'Scene',
    'SceneNode',
    'World',
    'Entity',
    'Component',
    'System',
    'TransformComponent',
    'VelocityComponent',
    'RenderableComponent',
    'PhysicsBodyComponent',
    'HealthComponent',
    'MovementSystem',
    'RenderSystem',
    'PhysicsSystemECS',
    'InputManager',
    'KeyboardInput',
    'MouseInput',
    'TouchInput',
    'ControllerInput',
    'AssetManager',
    'ImageAsset',
    'AudioAsset',
    'TextAsset',
    'JsonAsset',
    'BinaryAsset',
    'AssetBundle',
    'AudioEngine',
    'AudioClip',
    'SoundEffectManager',
    'MusicManager',
    'AudioMixer',
    'AudioChannel',
    'GameWidget',
    'LogicalKeyboardKey',
    'MouseButton',
    'GamepadButton',
  };

  List<TextSpan> _highlight(String text) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    // Handle comments
    if (text.trimLeft().startsWith('//')) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(color: AppColors.textMuted.withOpacity(0.6)),
        ),
      ];
    }

    // Handle strings
    final regex = RegExp(
      r"""('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*"|\b\w+\b|[^\w\s]|\s+)""",
    );

    for (final match in regex.allMatches(text)) {
      final token = match.group(0)!;

      if (token.startsWith("'") || token.startsWith('"')) {
        _flushBuffer(buffer, spans);
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: Color(0xFFCE9178)),
          ),
        );
      } else if (_keywords.contains(token)) {
        _flushBuffer(buffer, spans);
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: Color(0xFF569CD6)),
          ),
        );
      } else if (_builtInTypes.contains(token)) {
        _flushBuffer(buffer, spans);
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: Color(0xFF4EC9B0)),
          ),
        );
      } else if (RegExp(r'^\d+\.?\d*$').hasMatch(token)) {
        _flushBuffer(buffer, spans);
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: Color(0xFFB5CEA8)),
          ),
        );
      } else if (token == '(' ||
          token == ')' ||
          token == '{' ||
          token == '}' ||
          token == '[' ||
          token == ']') {
        _flushBuffer(buffer, spans);
        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(color: AppColors.textMuted),
          ),
        );
      } else {
        buffer.write(token);
      }
    }
    _flushBuffer(buffer, spans);
    return spans;
  }

  void _flushBuffer(StringBuffer buffer, List<TextSpan> spans) {
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString()));
      buffer.clear();
    }
  }
}
