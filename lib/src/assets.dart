part of gamedev_helpers;

Future<Map<String, String>> _loadAchievements(String libName) {
  return HttpRequest.getString('assets/$libName/achievements.json').then(_processAssets);
}

Future<Map<String, List<Polygon>>> _loadPolygons(String libName, String name) {
  return HttpRequest.getString('assets/$libName/img/$name.polygons.json').then(_processAssets).then(_createPolygonMap);
}

Future<SpriteSheet> _loadSpritesheet(String libName, String name) {
  String imgPath = 'assets/$libName/img/$name.png';
  return HttpRequest.getString('assets/$libName/img/$name.json')
      .then(_processAssets).then((assets) => _createSpriteSheet(imgPath, assets));
}

Future<Map<String, List<Polygon>>> _createPolygonMap(Map<String, List<Map<String, List<double>>>> polygons) {
  var result = new Map<String, List<Polygon>>();
  polygons.forEach((bodyId, pointMaps) {
    var polygonList = new List<Polygon>();
    pointMaps.forEach((pointMap) => polygonList.add(new Polygon(pointMap['shape'])));
    result[bodyId] = polygonList;
  });
  return new Future.value(result);
}

Future<SpriteSheet> _createSpriteSheet(String imgPath, Map<String, Map<String, Map<String, dynamic>>> assets) {
  var completer = new Completer<SpriteSheet>();
  var img = new ImageElement();
  img.onLoad.listen((_) {
    var sprites = new Map<String, Sprite>();
    assets['frames'].forEach((assetName, assetData) {
      sprites[assetName] = new Sprite(assetData);
    });
    var sheet = new SpriteSheet(img, sprites);
    completer.complete(sheet);
  });
  img.src = imgPath;
  return completer.future;
}

class LayeredSpriteSheet {
  List<SpriteSheet> sheets;
  LayeredSpriteSheet(SpriteSheet initialSpriteSheet) {
    sheets = new List<SpriteSheet>();
    sheets.add(initialSpriteSheet);
  }
  void add(SpriteSheet sheet) => sheets.insert(0, sheet);
  SpriteSheet getLayerFor(String spriteId) => sheets.where((sheet) => sheet.sprites.containsKey(spriteId)).first;
}

class SpriteSheet {
  final ImageElement image;
  final Map<String, Sprite> sprites;
  SpriteSheet(this.image, this.sprites);
}

class Sprite {
  Rectangle<int> src;
  Rectangle<int> dst;
  Vector2 offset;
  Sprite(Map<String, dynamic> singleAsset) {
    _Asset asset = new _Asset(singleAsset);
    src = asset.frame;
    var cx, cy;
    if (asset.trimmed) {
      cx = -(asset.sourceSize.x ~/ 2 - asset.spriteSourceSize.left);
      cy = -(asset.sourceSize.y ~/ 2 - asset.spriteSourceSize.top);
    } else {
      cx = -asset.frame.width ~/ 2;
      cy = -asset.frame.height ~/ 2;
    }

    dst = new Rectangle<int>(cx, cy, src.width, src.height);
    offset = new Vector2(cx.toDouble(), cy.toDouble());
  }
}

class Polygon {
  List<Vector2> vertices;
  Polygon(List<double> points) {
    vertices = new List(points.length ~/ 2);
    for (int i = 0; i < points.length; i+=2) {
      vertices[i ~/ 2] = new Vector2(points[i].toDouble(), points[i+1].toDouble());
    }
  }
}

class _Asset {
  Rectangle frame;
  bool trimmed;
  Rectangle spriteSourceSize;
  Point sourceSize;
  _Asset(Map<String, dynamic> asset) : frame = _createRectangle(asset["frame"]),
                                      trimmed = asset["trimmed"],
                                      spriteSourceSize = _createRectangle(asset["spriteSourceSize"]),
                                      sourceSize = _createPoint(asset["sourceSize"]);
}

_createRectangle(Map<String, int> rect) => new Rectangle(rect['x'], rect['y'],
    rect['w'], rect['h']);

_createPoint(Map<String, int> rect) => new Point(rect['w'], rect['h']);


Future<Map<String, dynamic>> _processAssets(String assetJson) {
  return new Future.value(JSON.decode(assetJson));
}