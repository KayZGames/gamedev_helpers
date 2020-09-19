library gamedev_helpers;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_audio';
import 'dart:web_gl';

import 'package:aspen_assets/aspen_assets.dart';
import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'src/assets.dart';

export 'dart:async';

export 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'gamedev_helpers.g.dart';
part 'src/client/assets.dart';
part 'src/client/dartemis/components.dart';
part 'src/client/dartemis/systems/animation_system.dart';
part 'src/client/dartemis/systems/debugging.dart';
part 'src/client/dartemis/systems/input.dart';
part 'src/client/dartemis/systems/rendering_context2d.dart';
part 'src/client/dartemis/systems/rendering_webgl.dart';
part 'src/client/game_base.dart';
part 'src/client/rendering.dart';

class GameHelper {
  final String _libName;
  final AudioContext _audioContext;
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
  Future<AudioBuffer> loadMusic(String name) =>
      _loadMusic(_audioContext, _libName, name);

  /// Loads shader/[vShaderAsset] and shader/[fShaderAsset].
  ShaderSource loadShader(TextAsset vShaderAsset, TextAsset fShaderAsset) =>
      _loadShader(vShaderAsset, fShaderAsset);
}
