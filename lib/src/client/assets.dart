part of gamedev_helpers;

Future<Map<String, String>> _loadAchievements(String libName) =>
    HttpRequest.getString('packages/$libName/assets/achievements.json')
        .then(_processAchievementAssets);

Future<Map<String, List<Polygon>>> _loadPolygons(String libName, String name) =>
    HttpRequest.getString('packages/$libName/assets/img/$name.polygons.json')
        .then(_processPolygonAssets)
        .then(_createPolygonMap);

Future<SpriteSheet> _loadSpritesheet(String libName, String name) {
  final imgPath = 'packages/$libName/assets/img/$name.png';
  return HttpRequest.getString('packages/$libName/assets/img/$name.json')
      .then(_processAssets)
      .then((assets) => _createSpriteSheet(imgPath, assets));
}

Future<AudioBuffer> _loadMusic(
    AudioContext audioContext, String libName, String name) {
  const goodAnswer = ['probably', 'maybe'];
  final audio = AudioElement();
  var fileExtension = 'ogg';
  if (goodAnswer.contains(audio.canPlayType('audio/ogg'))) {
    fileExtension = 'ogg';
  } else if (goodAnswer
          .contains(audio.canPlayType('audio/mpeg; codecs="mp3"')) ||
      goodAnswer.contains(audio.canPlayType('audio/mp3'))) {
    fileExtension = 'mp3';
  }
  final musicPath = 'packages/$libName/assets/music/$name.$fileExtension';
  return HttpRequest.request(musicPath, responseType: 'arraybuffer')
      .then((request) async =>
          // ignore: avoid_as
          audioContext.decodeAudioData(request.response as ByteBuffer));
}

Future<Map<String, List<Polygon>>> _createPolygonMap(
    Map<String, List<Map<String, List<double>>>> polygons) {
  final result = <String, List<Polygon>>{};
  polygons.forEach((bodyId, pointMaps) {
    final polygonList = <Polygon>[];
    for (final pointMap in pointMaps) {
      polygonList.add(Polygon(pointMap['shape']));
    }
    result[bodyId] = polygonList;
  });
  return Future.value(result);
}

Future<SpriteSheet> _createSpriteSheet(String imgPath, _AssetJson assets) {
  final completer = Completer<SpriteSheet>();
  final img = ImageElement();
  img.onLoad.listen((_) {
    final sprites = <String, Sprite>{};
    assets.frames.forEach((assetName, assetData) {
      sprites[assetName] = Sprite(assetData);
    });
    final sheet = SpriteSheet(img, sprites);
    completer.complete(sheet);
  });
  img.src = imgPath;
  return completer.future;
}

ShaderSource _loadShader(TextAsset vShaderFile, TextAsset fShaderFile) =>
    ShaderSource(vShaderFile.text, fShaderFile.text);

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

  Sprite(_FrameValue singleAsset) {
    final asset = _Asset(singleAsset);
    src = asset.frame;
    int cx, cy;
    if (asset.trimmed) {
      cx = -(asset.sourceSize.x ~/ 2 - asset.spriteSourceSize.left);
      cy = -(asset.sourceSize.y ~/ 2 - asset.spriteSourceSize.top);
    } else {
      cx = -asset.frame.width ~/ 2;
      cy = -asset.frame.height ~/ 2;
    }

    dst = Rectangle<int>(cx, cy, src.width, src.height);
    offset = Vector2(cx.toDouble(), cy.toDouble());
    trimmed = Vector2(asset.spriteSourceSize.left.toDouble(),
        asset.spriteSourceSize.top.toDouble());
  }
}

class Polygon {
  List<Vector2> vertices;

  Polygon(List<double> points) {
    vertices = List(points.length ~/ 2);
    for (var i = 0; i < points.length; i += 2) {
      vertices[i ~/ 2] =
          Vector2(points[i].toDouble(), points[i + 1].toDouble());
    }
  }
}

class _Asset {
  Rectangle<int> frame;
  bool trimmed;
  Rectangle<int> spriteSourceSize;
  Point<int> sourceSize;

  _Asset(_FrameValue asset)
      : frame = _createRectangle(asset.frame),
        trimmed = asset.trimmed,
        spriteSourceSize = _createRectangle(asset.spriteSourceSize),
        sourceSize = _createPoint(asset.sourceSize);
}

Rectangle<int> _createRectangle(_SpriteSourceSizeClass rect) =>
    Rectangle(rect.x, rect.y, rect.w, rect.h);

Point<int> _createPoint(_Size size) => Point(size.w, size.h);

Future<Map<String, String>> _processAchievementAssets(String assetJson) =>
    Future.value(json.decode(assetJson) as Map<String, String>);

Future<Map<String, List<Map<String, List<double>>>>> _processPolygonAssets(
        String assetJson) =>
    Future.value(
        json.decode(assetJson) as Map<String, List<Map<String, List<double>>>>);

Future<_AssetJson> _processAssets(String assetJson) => Future.value(
    _AssetJson.fromJson(json.decode(assetJson) as Map<String, dynamic>));

class _AssetJson {
  Map<String, _FrameValue> frames;
  _Meta meta;

  _AssetJson({
    this.frames,
    this.meta,
  });

  factory _AssetJson.fromJson(Map<String, dynamic> json) => _AssetJson(
        frames: Map<String, Map<String, dynamic>>.from(json['frames'] as Map)
            .map((k, v) =>
                MapEntry<String, _FrameValue>(k, _FrameValue.fromJson(v))),
        meta: _Meta.fromJson(json['meta'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'frames': Map<String, _FrameValue>.from(frames)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        'meta': meta.toJson(),
      };
}

class _FrameValue {
  _SpriteSourceSizeClass frame;
  bool rotated;
  bool trimmed;
  _SpriteSourceSizeClass spriteSourceSize;
  _Size sourceSize;

  _FrameValue({
    this.frame,
    this.rotated,
    this.trimmed,
    this.spriteSourceSize,
    this.sourceSize,
  });

  factory _FrameValue.fromJson(Map<String, dynamic> json) => _FrameValue(
        frame: _SpriteSourceSizeClass.fromJson(
            Map<String, int>.from(json['frame'] as Map)),
        rotated: json['rotated'] as bool,
        trimmed: json['trimmed'] as bool,
        spriteSourceSize: _SpriteSourceSizeClass.fromJson(
            Map<String, int>.from(json['spriteSourceSize'] as Map)),
        sourceSize:
            _Size.fromJson(Map<String, int>.from(json['sourceSize'] as Map)),
      );

  Map<String, dynamic> toJson() => {
        'frame': frame.toJson(),
        'rotated': rotated,
        'trimmed': trimmed,
        'spriteSourceSize': spriteSourceSize.toJson(),
        'sourceSize': sourceSize.toJson(),
      };
}

class _SpriteSourceSizeClass {
  int x;
  int y;
  int w;
  int h;

  _SpriteSourceSizeClass({
    this.x,
    this.y,
    this.w,
    this.h,
  });

  factory _SpriteSourceSizeClass.fromJson(Map<String, int> json) =>
      _SpriteSourceSizeClass(
        x: json['x'] ?? 0,
        y: json['y'] ?? 0,
        w: json['w'],
        h: json['h'],
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'w': w,
        'h': h,
      };
}

class _Size {
  int w;
  int h;

  _Size({
    this.w,
    this.h,
  });

  factory _Size.fromJson(Map<String, int> json) => _Size(
        w: json['w'],
        h: json['h'],
      );

  Map<String, dynamic> toJson() => {
        'w': w,
        'h': h,
      };
}

class _Meta {
  String app;
  String version;
  String image;
  String format;
  _Size size;
  String scale;
  String smartupdate;

  _Meta({
    this.app,
    this.version,
    this.image,
    this.format,
    this.size,
    this.scale,
    this.smartupdate,
  });

  factory _Meta.fromJson(Map<String, dynamic> json) => _Meta(
        app: json['app'] as String,
        version: json['version'] as String,
        image: json['image'] as String,
        format: json['format'] as String,
        size: _Size.fromJson(Map<String, int>.from(json['size'] as Map)),
        scale: json['scale'] as String,
        smartupdate: json['smartupdate'] as String,
      );

  Map<String, dynamic> toJson() => {
        'app': app,
        'version': version,
        'image': image,
        'format': format,
        'size': size.toJson(),
        'scale': scale,
        'smartupdate': smartupdate,
      };
}
