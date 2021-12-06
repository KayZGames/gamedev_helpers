import 'dart:web_audio';

import 'package:asset_data/asset_data.dart';

import 'internal/asset_loader.dart' as assets;
import 'shader.dart';
import 'sprite_sheet.dart';

class GameHelper {
  final String _libName;
  // ignore: use_late_for_private_fields_and_variables
  final AudioContext? _audioContext;
  GameHelper(this._libName, this._audioContext);

  /// Loads achievements.json.
  /// Format {name: desciption, otherName: otherDescription}
  Future<Map<String, String>> loadAchievements() =>
      assets.loadAchievements(_libName);

  /// Loads img/[name].polygons.json. File has to be in PhysicsEditor format.
  Future<Map<String, List<assets.Polygon>>> loadPolygons(String name) =>
      assets.loadPolygons(_libName, name);

  /// Loads image based on [spriteSheetJson] and [spriteSheetImg] created using
  /// assert_data and asset_builder.
  Future<SpriteSheet> loadSpritesheet(
    JsonAsset spriteSheetJson,
    BinaryAsset spriteSheetImg,
  ) =>
      assets.loadSpritesheet(spriteSheetJson, spriteSheetImg);

  /// Loads music/[name].ogg or music/[name].mp3 depending on browser support.
  Future<AudioBuffer> loadMusic(String name) =>
      assets.loadMusic(_audioContext!, _libName, name);

  /// Loads shader/[vShaderAsset] and shader/[fShaderAsset].
  ShaderSource loadShader(TextAsset vShaderAsset, TextAsset fShaderAsset) =>
      assets.loadShader(vShaderAsset, fShaderAsset);
}
