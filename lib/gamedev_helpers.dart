library gamedev_helpers;

import 'dart:async';
export 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';
import 'dart:js' as js;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
export 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:simple_audio/simple_audio.dart';

part 'src/client/assets.dart';
part 'src/client/audio.dart';
part 'src/client/game_base.dart';

part 'src/client/dartemis/systems/analytics.dart';
part 'src/client/dartemis/systems/debugging.dart';
part 'src/client/dartemis/systems/input.dart';
part 'src/client/dartemis/systems/rendering.dart';
part 'src/client/dartemis/systems/sound.dart';

class GameHelper {
  final String _libName;
  AudioHelper _audioHelper;
  GameHelper(this._libName);

  AudioHelper get audioHelper {
    if (null == _audioHelper) {
      _audioHelper = new AudioHelper(_libName);
    }
    return _audioHelper;
  }

  /// Loads achievements.json.
  /// Format {name: desciption, otherName: otherDescription}
  Future<Map<String, String>> loadAchievements() => _loadAchievements(_libName);
  /// Loads img/[name].polygons.json. File has to be in PhysicsEditor format.
  Future<Map<String, List<Polygon>>> loadPolygons(String name) =>
      _loadPolygons(_libName, name);
  /// Loads img/[name].png and img/[name].json.
  Future<SpriteSheet> loadSpritesheet(String name) =>
      _loadSpritesheet(_libName, name);
}

class AudioHelper {
  final String _libName;
  final AudioManager _audioManager;
  AudioHelper(String libName) : _libName = libName,
                                _audioManager = _createAudioManager(libName);

  /// Loads .ogg and .mp3 files with [names] from sfx-directory.
  Future<List<AudioClip>> loadAudioClips(List<String> names) =>
      _loadAudioClips(_audioManager, names);
  /// Plays clip on default source
  void playClip(String clipName) {
    _audioManager.playClipFromSource('default', clipName);
  }
}