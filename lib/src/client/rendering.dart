part of gamedev_helpers;

// originally part of CanvasQuery
final Pattern _whitespacePattern = new RegExp((r'\s+'));
/**
 * Writes [text] at [x], [y] and wraps at [maxWidth].
 *
 * The [nlCallback] will be called before a line is written.
 */
void wrappedText(
    CanvasRenderingContext2D ctx, String text, int x, int y, num maxWidth) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  var lines = _getLines(ctx, text, maxWidth);

  for (var i = 0; i < lines.length; i++) {
    var oy = (y + i * h * 0.6).toInt();
    var line = lines[i];
    ctx.strokeText(line, x, oy);
    ctx.fillText(line, x, oy);
  }
}

/**
 * Returns a [Rectangle] with the size of a given [text]. If [maxWidth]
 * is given, the [text] will be wrapped.
 */
Rectangle textBoundaries(CanvasRenderingContext2D ctx, String text,
                         [num maxWidth]) {
  var regexp = new RegExp(r"(\d+)");
  var h = int.parse(regexp.firstMatch(ctx.font).group(0)) * 2;
  List<String> lines = _getLines(ctx, text, maxWidth);
  if (null == maxWidth) {
    maxWidth = ctx.measureText(text).width;
  }
  return new Rectangle(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
}

/**
 * Splits the [text] at [maxWidth] and returns a list of lines.
 */
List<String> _getLines(CanvasRenderingContext2D ctx, String text,
                      [num maxWidth]) {
  var words = text.split(_whitespacePattern);

  var ox = 0;

  var lines = new List<String>.from([""]);
  var spaceWidth = ctx.measureText(" ").width;
  if (null != maxWidth) {
    maxWidth += spaceWidth;
    var line = 0;
    for (var i = 0; i < words.length; i++) {
      var word = "${words[i]} ";
      var wordWidth = ctx.measureText(word).width;

      if (ox + wordWidth > maxWidth) {
        lines.add("");
        line++;
        ox = 0;
      }
      lines[line] = "${lines[line]}$word";

      ox += wordWidth;
    }
  } else {
    lines = [text];
  }
  return lines;
}