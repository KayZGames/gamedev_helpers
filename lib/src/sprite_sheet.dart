import 'dart:html';

import 'package:vector_math/vector_math_64.dart';

class LayeredSpriteSheet {
  List<SpriteSheet> sheets;

  LayeredSpriteSheet(SpriteSheet initialSpriteSheet)
      : sheets = [initialSpriteSheet];

  void add(SpriteSheet sheet) => sheets.insert(0, sheet);

  SpriteSheet getLayerFor(String spriteId) =>
      sheets.where((sheet) => sheet.sprites.containsKey(spriteId)).first;
}

class SpriteSheet {
  final ImageElement image;
  final Map<String, Sprite> sprites;

  SpriteSheet(this.image, this.sprites);

  Sprite operator [](String name) {
    final sprite = sprites[name];
    if (sprite != null) {
      return sprite;
    }
    throw ArgumentError.value(
      name,
      'name',
      '''no sprite with name $name in map of sprites ${sprites.keys.join(', ')}''',
    );
  }
}

class Sprite {
  Rectangle<int> src;
  Rectangle<int> dst;
  Vector2 offset;
  Vector2 trimmed;

  Sprite(this.src, this.dst, this.offset, this.trimmed);
}
