import 'package:dartemis/dartemis.dart';

import '../sprite_sheet.dart';

class Renderable extends Component {
  final SpriteSheet _sheet;
  String _name;
  int _maxFrames;
  double _timePerFrame;
  double _time;
  double scale;
  bool facesRight;
  late Sprite _sprite;
  bool _spriteNeedsUpdate = true;
  Renderable(
    this._sheet,
    this._name, {
    int maxFrames = 1,
    double timePerFrame = 0.2,
    this.facesRight = true,
    double time = 0.0,
    this.scale = 1.0,
  })  : _maxFrames = maxFrames,
        _timePerFrame = timePerFrame,
        _time = time;

  Renderable.fromRenderable(Renderable other, this._time, this.scale)
      : _name = other._name,
        _sheet = other._sheet,
        _maxFrames = other._maxFrames,
        _timePerFrame = other._timePerFrame,
        facesRight = other.facesRight;

  Sprite get sprite {
    if (_spriteNeedsUpdate) {
      _sprite = _sheet[_spriteName];
      _spriteNeedsUpdate = false;
    }
    return _sprite;
  }

  String get _spriteName =>
      '''${_name}_${_maxFrames - (_time / _timePerFrame % _maxFrames).toInt() - 1}''';

  double get time => _time;

  set time(double value) {
    _time = value;
    _spriteNeedsUpdate = true;
  }

  double get timePerFrame => _timePerFrame;

  set timePerFrame(double value) {
    _timePerFrame = value;
    _spriteNeedsUpdate = true;
  }

  int get maxFrames => _maxFrames;

  set maxFrames(int value) {
    _maxFrames = value;
    _spriteNeedsUpdate = true;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
    _spriteNeedsUpdate = true;
  }
}
