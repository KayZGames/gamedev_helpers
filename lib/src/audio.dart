part of gamedev_helpers;

/// Expects sound assets in /assets/sfx
AudioManager createAudioManager() {
  int webIndex = window.location.href.lastIndexOf('/web/');
  var baseUrl = window.location.href.substring(0, webIndex) + '/assets/sfx/';
  var manager;
  try {
    // AudioManager needs this but some versions of Firefox don't have the gain property.
    if (null == new AudioContext().createBufferSource().gain) throw 'this ain\'t no real AudioContext';
    manager = new AudioManager(baseUrl);
    var source = manager.makeSource('default');
    source.positional = false;
  } catch (e) {
    manager = new AudioElementManager(baseUrl);
  }

  return manager;
}

/// Loads AudioClips for the supported file format. ogg and mp3 files have to exist.
Future<List<AudioClip>> loadAudioClips(AudioManager audioManager, List<String> namesWithoutExtension) {
  var audio = new AudioElement();
  var fileExtension = 'ogg';
  var goodAnswer = ['probably', 'maybe'];
  if (goodAnswer.contains(audio.canPlayType('audio/ogg'))) {
    fileExtension = 'ogg';
  } else if (goodAnswer.contains(audio.canPlayType('audio/mpeg; codecs="mp3"'))) {
    fileExtension = 'mp3';
  } else if (goodAnswer.contains(audio.canPlayType('audio/mp3'))) {
    fileExtension = 'mp3';
  }
  return Future.wait(namesWithoutExtension.map((name) => audioManager.makeClip(name, '$name.$fileExtension').load()));
}

/// AudioManager for browsers that don't support AudioContext.
///
/// Only supports most basic usage of AudioManager.
class AudioElementManager implements AudioManager {
  String baseURL;
  AudioElementManager([this.baseURL = '/']);

  Map<String, AudiElementClip> _clips = new Map<String, AudiElementClip>();

  AudioClip makeClip(String name, String url) {
    AudioClip clip = _clips[name];
    if (clip != null) {
      return clip;
    }
    clip = new AudiElementClip._internal(this, name, "$baseURL$url");
    _clips[name] = clip;
    return clip;
  }

  AudioSound playClipFromSource(String sourceName, String clipName, [bool looped=false]) {
    _clips[clipName].play();
    return null;
  }

  dynamic noSuchMethod(Invocation im) {}
}

/// AudioClip for browsers that don't support AudioContext.
class AudiElementClip implements AudioClip {
  final AudioManager _manager;
  String _name;
  String _url;
  var audioElements = new List<AudioElement>();
  AudiElementClip._internal(this._manager, this._name, this._url);

  Future<AudioClip> load() {
    var audioElement = new AudioElement();
    var completer = new Completer<AudioClip>();
    audioElement.onCanPlay.first.then((_) {
      completer.complete(this);
    });
    audioElement.src = _url;
    audioElements.add(audioElement);
    return completer.future;
  }

  void play() {
    var playable = audioElements.where((element) => element.ended).iterator;
    var audioElement;
    if (playable.moveNext()) {
      audioElement = playable.current;
    } else {
      audioElement = audioElements[0].clone(false);
      audioElements.add(audioElement);
    }
    audioElement.play();
  }

  dynamic noSuchMethod(Invocation im) {}
}