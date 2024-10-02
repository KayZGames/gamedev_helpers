import 'dart:math';

import 'package:web/web.dart';

// originally part of CanvasQuery
final Pattern _whitespacePattern = RegExp(r'\s+');

/// Writes [text] at [x], [y] and wraps at [maxWidth].
void wrappedText(
  CanvasRenderingContext2D ctx,
  String text,
  int x,
  int y,
  num maxWidth,
) {
  final regexp = RegExp(r'(\d+)');
  final h = int.parse(regexp.firstMatch(ctx.font)!.group(0)!) * 2;
  final lines = _getLines(ctx, text, maxWidth);

  for (var i = 0; i < lines.length; i++) {
    final oy = (y + i * h * 0.6).toInt();
    final line = lines[i];
    ctx
      ..strokeText(line, x, oy)
      ..fillText(line, x, oy);
  }
}

/// Returns a [Rectangle] with the size of a given [text]. If [maxWidth]
/// is given, the [text] will be wrapped.
Rectangle textBoundaries(
  CanvasRenderingContext2D ctx,
  String text, [
  num? maxWidth,
]) {
  final regexp = RegExp(r'(\d+)');
  final h = int.parse(regexp.firstMatch(ctx.font)!.group(0)!) * 2;
  final lines = _getLines(ctx, text, maxWidth);
  maxWidth ??= ctx.measureText(text).width;
  return Rectangle(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
}

/// Splits the [text] at [maxWidth] and returns a list of lines.
List<String> _getLines(
  CanvasRenderingContext2D ctx,
  String text, [
  num? maxWidth,
]) {
  final words = text.split(_whitespacePattern);

  var ox = 0.0;

  var lines = List<String>.from(['']);
  final spaceWidth = ctx.measureText(' ').width;
  if (maxWidth != null) {
    final totalMaxWidth = maxWidth + spaceWidth;
    var line = 0;
    for (var i = 0; i < words.length; i++) {
      final word = '${words[i]} ';
      final wordWidth = ctx.measureText(word).width;

      if (ox + wordWidth > totalMaxWidth) {
        lines.add('');
        line++;
        ox = 0.0;
      }
      lines[line] = '${lines[line]}$word';

      ox += wordWidth;
    }
  } else {
    lines = [text];
  }
  return lines;
}
