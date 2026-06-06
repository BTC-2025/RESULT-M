import 'package:flutter/material.dart';

class RichTextContent extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const RichTextContent({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;

    return Text.rich(
      TextSpan(
        children: _parseInlineMarkdown(_normalizeBlocks(text), baseStyle),
      ),
      maxLines: maxLines,
      overflow: overflow,
      style: baseStyle,
    );
  }

  String _normalizeBlocks(String source) {
    return source
        .replaceAll(RegExp(r'^- ', multiLine: true), '• ')
        .replaceAll(RegExp(r'^> ', multiLine: true), '“');
  }

  List<TextSpan> _parseInlineMarkdown(String source, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|_[^_]+_|`[^`]+`)');
    var currentIndex = 0;

    for (final match in pattern.allMatches(source)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: source.substring(currentIndex, match.start)));
      }

      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: baseStyle.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      } else if (token.startsWith('_')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Colors.black.withValues(alpha: 0.06),
            ),
          ),
        );
      }
      currentIndex = match.end;
    }

    if (currentIndex < source.length) {
      spans.add(TextSpan(text: source.substring(currentIndex)));
    }

    return spans;
  }
}
