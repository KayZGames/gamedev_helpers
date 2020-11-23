import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'dart:web_audio';

import 'package:aspen_assets/aspen_assets.dart';
import 'package:vector_math/vector_math_64.dart';

import '../shader.dart';
import '../sprite_sheet.dart';

Future<Map<String, String>> loadAchievements(String libName) =>
    HttpRequest.getString('packages/$libName/assets/achievements.json')
        .then(_processAchievementAssets);

Future<Map<String, List<Polygon>>> loadPolygons(String libName, String name) =>
    HttpRequest.getString('packages/$libName/assets/img/$name.polygons.json')
        .then(_processPolygonAssets)
        .then(_createPolygonMap);

Future<SpriteSheet> loadSpritesheet(String libName, String name) {
  final imgPath = 'packages/$libName/assets/img/$name.png';
  return HttpRequest.getString('packages/$libName/assets/img/$name.json')
      .then(_processAssets)
      .then((assets) => _createSpriteSheet(imgPath, assets));
}

Future<AudioBuffer> loadMusic(
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
  final img = ImageElement(src: imgPath);
  img.onLoad.listen((_) {
    final sprites = <String, Sprite>{};
    assets.frames.forEach((assetName, assetData) {
      final spriteData = _SpriteData(assetData);
      sprites[assetName] = Sprite(spriteData.src, spriteData.dst,
          spriteData.offset, spriteData.trimmed);
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

  Polygon(List<double> points) {
    vertices = List(points.length ~/ 2);
    for (var i = 0; i < points.length; i += 2) {
      vertices[i ~/ 2] =
          Vector2(points[i].toDouble(), points[i + 1].toDouble());
    }
  }
}

class _SpriteData {
  Rectangle<int> src;
  Rectangle<int> dst;
  Vector2 offset;
  Vector2 trimmed;

  _SpriteData(_FrameValue singleAsset) {
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
