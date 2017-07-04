part of gamedev_helpers;

Future<Map<String, String>> _loadAchievements(String libName) => HttpRequest
    .getString('packages/$libName/assets/achievements.json')
    .then(_processAchievementAssets);

Future<Map<String, List<Polygon>>> _loadPolygons(String libName, String name) =>
    HttpRequest
        .getString('packages/$libName/assets/img/$name.polygons.json')
        .then(_processPolygonAssets)
        .then(_createPolygonMap);

Future<SpriteSheet> _loadSpritesheet(String libName, String name) {
  final imgPath = 'packages/$libName/assets/img/$name.png';
  return HttpRequest
      .getString('packages/$libName/assets/img/$name.json')
      .then(_processAssets)
      .then((assets) => _createSpriteSheet(imgPath, assets));
}

Future<AudioBuffer> _loadMusic(
    AudioContext audioContext, String libName, String name) {
  const goodAnswer = const ['probably', 'maybe'];
  final audio = new AudioElement();
  var fileExtension = 'ogg';
  if (goodAnswer.contains(audio.canPlayType('audio/ogg'))) {
    fileExtension = 'ogg';
  } else if (goodAnswer
          .contains(audio.canPlayType('audio/mpeg; codecs="mp3"')) ||
      goodAnswer.contains(audio.canPlayType('audio/mp3'))) {
    fileExtension = 'mp3';
  }
  final String musicPath =
      'packages/$libName/assets/music/$name.$fileExtension';
  return HttpRequest
      .request(musicPath, responseType: 'arraybuffer')
      .then((request) async => audioContext.decodeAudioData(request.response));
}

Future<Map<String, List<Polygon>>> _createPolygonMap(
    Map<String, List<Map<String, List<double>>>> polygons) {
  final result = <String, List<Polygon>>{};
  polygons.forEach((bodyId, pointMaps) {
    final polygonList = <Polygon>[];
    pointMaps
        .forEach((pointMap) => polygonList.add(new Polygon(pointMap['shape'])));
    result[bodyId] = polygonList;
  });
  return new Future.value(result);
}

Future<SpriteSheet> _createSpriteSheet(
    String imgPath, Map<String, Map<String, Map<String, dynamic>>> assets) {
  final completer = new Completer<SpriteSheet>();
  final img = new ImageElement();
  img.onLoad.listen((_) {
    final sprites = <String, Sprite>{};
    assets['frames'].forEach((assetName, assetData) {
      sprites[assetName] = new Sprite(assetData);
    });
    final sheet = new SpriteSheet(img, sprites);
    completer.complete(sheet);
  });
  img.src = imgPath;
  return completer.future;
}

Future<ShaderSource> _loadShader(
    String libName, String vShaderFile, String fShaderFile) {
  final List<Future> loaders = [
    HttpRequest.getString('packages/$libName/assets/shader/$vShaderFile.vert'),
    HttpRequest.getString('packages/$libName/assets/shader/$fShaderFile.frag')
  ];
  return Future
      .wait(loaders)
      .then((shaders) => new ShaderSource(shaders[0], shaders[1]));
}

class ShaderSource {
  String vShader;
  String fShader;
  ShaderSource(this.vShader, this.fShader);
}

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
  Sprite operator [](String name) => sprites[name];
}

class Sprite {
  Rectangle<int> src;
  Rectangle<int> dst;
  Vector2 offset;
  Vector2 trimmed;
  Sprite(Map<String, dynamic> singleAsset) {
    final _Asset asset = new _Asset(singleAsset);
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
    trimmed = new Vector2(asset.spriteSourceSize.left.toDouble(),
        asset.spriteSourceSize.top.toDouble());
  }
}

class Polygon {
  List<Vector2> vertices;
  Polygon(List<double> points) {
    vertices = new List(points.length ~/ 2);
    for (int i = 0; i < points.length; i += 2) {
      vertices[i ~/ 2] =
          new Vector2(points[i].toDouble(), points[i + 1].toDouble());
    }
  }
}

class _Asset {
  Rectangle frame;
  bool trimmed;
  Rectangle spriteSourceSize;
  Point sourceSize;
  _Asset(Map<String, dynamic> asset)
      : frame = _createRectangle(asset["frame"]),
        trimmed = asset["trimmed"],
        spriteSourceSize = _createRectangle(asset["spriteSourceSize"]),
        sourceSize = _createPoint(asset["sourceSize"]);
}

Rectangle<int> _createRectangle(Map<String, int> rect) =>
    new Rectangle(rect['x'], rect['y'], rect['w'], rect['h']);

Point<int> _createPoint(Map<String, int> rect) =>
    new Point(rect['w'], rect['h']);

Future<Map<String, String>> _processAchievementAssets(String assetJson) =>
    new Future.value(JSON.decode(assetJson));

Future<Map<String, List<Map<String, List<double>>>>> _processPolygonAssets(
        String assetJson) =>
    new Future.value(JSON.decode(assetJson));

Future<Map<String, dynamic>> _processAssets(String assetJson) =>
    new Future.value(JSON.decode(assetJson));
