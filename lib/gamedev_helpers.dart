library gamedev_helpers;

import 'dart:async';
export 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';
import 'dart:web_gl';
import 'dart:typed_data';
import 'dart:js' as js;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
export 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/client/assets.dart';
part 'src/client/game_base.dart';
part 'src/client/rendering.dart';

part 'src/client/dartemis/systems/analytics.dart';
part 'src/client/dartemis/systems/debugging.dart';
part 'src/client/dartemis/systems/input.dart';
part 'src/client/dartemis/systems/rendering_context2d.dart';
part 'src/client/dartemis/systems/rendering_webgl.dart';

class GameHelper {
  final String _libName;
  AudioContext _audioContext;
  GameHelper(this._libName, this._audioContext);

  /// Loads achievements.json.
  /// Format {name: desciption, otherName: otherDescription}
  Future<Map<String, String>> loadAchievements() => _loadAchievements(_libName);

  /// Loads img/[name].polygons.json. File has to be in PhysicsEditor format.
  Future<Map<String, List<Polygon>>> loadPolygons(String name) =>
      _loadPolygons(_libName, name);

  /// Loads img/[name].png and img/[name].json.
  Future<SpriteSheet> loadSpritesheet(String name) =>
      _loadSpritesheet(_libName, name);

  /// Loads music/[name].ogg or music/[name].mp3 depending on browser support.
  Future<AudioBuffer> loadMusic(String name) => _loadMusic(_audioContext, _libName, name);

  /// Loads shader/[vShaderFile].vert and shader/[fShaderFile].frag.
  Future<ShaderSource> loadShader(String vShaderFile, String fShaderFile) =>
      _loadShader(_libName, vShaderFile, fShaderFile);
}