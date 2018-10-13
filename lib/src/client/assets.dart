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
  final String musicPath =
      'packages/$libName/assets/music/$name.$fileExtension';
  return HttpRequest.request(musicPath, responseType: 'arraybuffer')
      .then((request) async => audioContext.decodeAudioData(request.response));
}

Future<Map<String, List<Polygon>>> _createPolygonMap(
    Map<String, List<Map<String, List<double>>>> polygons) {
  final result = <String, List<Polygon>>{};
  polygons.forEach((bodyId, pointMaps) {
    final polygonList = <Polygon>[];
    pointMaps
        .forEach((pointMap) => polygonList.add(Polygon(pointMap['shape'])));
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

Future<ShaderSource> _loadShader(
    String libName, String vShaderFile, String fShaderFile) {
  final List<Future> loaders = [
    HttpRequest.getString('packages/$libName/assets/shader/$vShaderFile.vert'),
    HttpRequest.getString('packages/$libName/assets/shader/$fShaderFile.frag')
  ];
  return Future.wait(loaders)
      .then((shaders) => ShaderSource(shaders[0], shaders[1]));
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
  Sprite(_FrameValue singleAsset) {
    final _Asset asset = _Asset(singleAsset);
    src = asset.frame;
    var cx, cy;
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
    for (int i = 0; i < points.length; i += 2) {
      vertices[i ~/ 2] =
          Vector2(points[i].toDouble(), points[i + 1].toDouble());
    }
  }
}

class _Asset {
  Rectangle frame;
  bool trimmed;
  Rectangle spriteSourceSize;
  Point sourceSize;
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
    Future.value(json.decode(assetJson));

Future<Map<String, List<Map<String, List<double>>>>> _processPolygonAssets(
        String assetJson) =>
    Future.value(json.decode(assetJson));

Future<_AssetJson> _processAssets(String assetJson) =>
    Future.value(_AssetJson.fromJson(json.decode(assetJson)));

class _AssetJson {
  Map<String, _FrameValue> frames;
  _Meta meta;

  _AssetJson({
    this.frames,
    this.meta,
  });

  factory _AssetJson.fromJson(Map<String, dynamic> json) => new _AssetJson(
        frames: new Map.from(json["frames"]).map((k, v) =>
            new MapEntry<String, _FrameValue>(k, _FrameValue.fromJson(v))),
        meta: _Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "frames": new Map.from(frames)
            .map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "meta": meta.toJson(),
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

  factory _FrameValue.fromJson(Map<String, dynamic> json) => new _FrameValue(
        frame: _SpriteSourceSizeClass.fromJson(json["frame"]),
        rotated: json["rotated"],
        trimmed: json["trimmed"],
        spriteSourceSize:
            _SpriteSourceSizeClass.fromJson(json["spriteSourceSize"]),
        sourceSize: _Size.fromJson(json["sourceSize"]),
      );

  Map<String, dynamic> toJson() => {
        "frame": frame.toJson(),
        "rotated": rotated,
        "trimmed": trimmed,
        "spriteSourceSize": spriteSourceSize.toJson(),
        "sourceSize": sourceSize.toJson(),
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

  factory _SpriteSourceSizeClass.fromJson(Map<String, dynamic> json) =>
      new _SpriteSourceSizeClass(
        x: json["x"] ?? 0,
        y: json["y"] ?? 0,
        w: json["w"],
        h: json["h"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "w": w,
        "h": h,
      };
}

class _Size {
  int w;
  int h;

  _Size({
    this.w,
    this.h,
  });

  factory _Size.fromJson(Map<String, dynamic> json) => new _Size(
        w: json["w"],
        h: json["h"],
      );

  Map<String, dynamic> toJson() => {
        "w": w,
        "h": h,
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

  factory _Meta.fromJson(Map<String, dynamic> json) => new _Meta(
        app: json["app"],
        version: json["version"],
        image: json["image"],
        format: json["format"],
        size: _Size.fromJson(json["size"]),
        scale: json["scale"],
        smartupdate: json["smartupdate"],
      );

  Map<String, dynamic> toJson() => {
        "app": app,
        "version": version,
        "image": image,
        "format": format,
        "size": size.toJson(),
        "scale": scale,
        "smartupdate": smartupdate,
      };
}
