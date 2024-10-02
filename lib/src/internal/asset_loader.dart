import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';

import 'package:asset_data/asset_data.dart';
import 'package:http/browser_client.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:web/web.dart';

import '../shader.dart';
import '../sprite_sheet.dart';

Future<Map<String, String>> loadAchievements(String libName) => BrowserClient()
    .get(Uri(path: 'packages/$libName/assets/achievements.json'))
    .then((value) => value.body)
    .then(_processAchievementAssets);

Future<Map<String, List<Polygon>>> loadPolygons(String libName, String name) =>
    BrowserClient()
        .get(Uri(path: 'packages/$libName/assets/img/$name.polygons.json'))
        .then((value) => value.body)
        .then(_processPolygonAssets)
        .then(_createPolygonMap);

Future<SpriteSheet> loadSpritesheet(
  JsonAsset spriteSheetJson,
  BinaryAsset spriteSheetImg,
) {
  final assets =
      _AssetJson.fromJson(spriteSheetJson.json() as Map<String, dynamic>);
  final imgType = spriteSheetImg.assetId.split('.').last;
  final imgPath =
      'data:image/$imgType;base64,${base64Encode(spriteSheetImg.decode().toList())}';
  return _createSpriteSheet(imgPath, assets);
}

Future<AudioBuffer> loadMusic(
  AudioContext audioContext,
  String libName,
  String name,
) {
  const goodAnswer = ['probably', 'maybe'];
  final audio = HTMLAudioElement();
  var fileExtension = 'ogg';
  if (goodAnswer.contains(audio.canPlayType('audio/ogg'))) {
    fileExtension = 'ogg';
  } else if (goodAnswer
          .contains(audio.canPlayType('audio/mpeg; codecs="mp3"')) ||
      goodAnswer.contains(audio.canPlayType('audio/mp3'))) {
    fileExtension = 'mp3';
  }
  final musicPath = 'packages/$libName/assets/music/$name.$fileExtension';
  return BrowserClient()
      .get(Uri(path: musicPath), headers: {'responseType': 'arraybuffer'}).then(
    (response) async =>
        // ignore: avoid_as
        audioContext.decodeAudioData(response as JSArrayBuffer).toDart,
  );
}

Future<Map<String, List<Polygon>>> _createPolygonMap(
  Map<String, List<Map<String, List<double>>>> polygons,
) {
  final result = <String, List<Polygon>>{};
  polygons.forEach((bodyId, pointMaps) {
    final polygonList = <Polygon>[];
    for (final pointMap in pointMaps) {
      polygonList.add(Polygon(pointMap['shape']!));
    }
    result[bodyId] = polygonList;
  });
  return Future.value(result);
}

Future<SpriteSheet> _createSpriteSheet(String imgPath, _AssetJson assets) {
  final completer = Completer<SpriteSheet>();
  final img = HTMLImageElement()..src = imgPath;
  img.onLoad.listen((_) {
    final sprites = <String, Sprite>{};
    assets.frames.forEach((assetName, assetData) {
      final spriteData = _SpriteData(assetData);
      sprites[assetName] = Sprite(
        spriteData.src,
        spriteData.dst,
        spriteData.offset,
        spriteData.trimmed,
      );
    });
    final sheet = SpriteSheet(img, sprites);
    completer.complete(sheet);
  });
  return completer.future;
}

ShaderSource loadShader(TextAsset vShaderFile, TextAsset fShaderFile) =>
    ShaderSource(vShaderFile, fShaderFile);

class Polygon {
  List<Vector2> vertices;

  Polygon(List<double> points)
      : vertices = [
          for (var i = 0; i < points.length; i += 2)
            Vector2(points[i], points[i + 1]),
        ];
}

class _SpriteData {
  Rectangle<int> src;
  Rectangle<int> dst;
  Vector2 offset;
  Vector2 trimmed;

  factory _SpriteData(_FrameValue singleAsset) {
    final asset = _Asset(singleAsset);
    final src = asset.frame;
    int cx;
    int cy;
    if (asset.trimmed) {
      cx = -(asset.sourceSize.x ~/ 2 - asset.spriteSourceSize.left);
      cy = -(asset.sourceSize.y ~/ 2 - asset.spriteSourceSize.top);
    } else {
      cx = -asset.frame.width ~/ 2;
      cy = -asset.frame.height ~/ 2;
    }

    final dst = Rectangle<int>(cx, cy, src.width, src.height);
    final offset = Vector2(cx.toDouble(), cy.toDouble());
    final trimmed = Vector2(
      asset.spriteSourceSize.left.toDouble(),
      asset.spriteSourceSize.top.toDouble(),
    );
    return _SpriteData.internal(src, dst, offset, trimmed);
  }

  _SpriteData.internal(this.src, this.dst, this.offset, this.trimmed);
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
  String assetJson,
) =>
    Future.value(
      json.decode(assetJson) as Map<String, List<Map<String, List<double>>>>,
    );

class _AssetJson {
  Map<String, _FrameValue> frames;
  _Meta meta;

  _AssetJson({
    required this.frames,
    required this.meta,
  });

  factory _AssetJson.fromJson(Map<String, dynamic> json) => _AssetJson(
        frames:
            Map<String, Map<String, dynamic>>.from(json['frames'] as Map).map(
          (k, v) => MapEntry<String, _FrameValue>(k, _FrameValue.fromJson(v)),
        ),
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
    required this.frame,
    required this.rotated,
    required this.trimmed,
    required this.spriteSourceSize,
    required this.sourceSize,
  });

  factory _FrameValue.fromJson(Map<String, dynamic> json) => _FrameValue(
        frame: _SpriteSourceSizeClass.fromJson(
          Map<String, int>.from(json['frame'] as Map),
        ),
        rotated: json['rotated'] as bool,
        trimmed: json['trimmed'] as bool,
        spriteSourceSize: _SpriteSourceSizeClass.fromJson(
          Map<String, int>.from(json['spriteSourceSize'] as Map),
        ),
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
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory _SpriteSourceSizeClass.fromJson(Map<String, int> json) =>
      _SpriteSourceSizeClass(
        x: json['x'] ?? 0,
        y: json['y'] ?? 0,
        w: json['w']!,
        h: json['h']!,
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
    required this.w,
    required this.h,
  });

  factory _Size.fromJson(Map<String, int> json) => _Size(
        w: json['w']!,
        h: json['h']!,
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
    required this.app,
    required this.version,
    required this.image,
    required this.format,
    required this.size,
    required this.scale,
    required this.smartupdate,
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
