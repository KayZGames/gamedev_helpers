part of gamedev_helpers_shared;

class CameraManager extends Manager {
  int _viewportWidth, _viewportHeight;
  double _scalingFactor;
  bool lockCamera = false;
  final int maxViewportSize;
  double gameZoom;
  CameraManager(this._viewportWidth, this._viewportHeight,
      {this.maxViewportSize = 1000, this.gameZoom = 1.0}) {
    _calculateScalingFactor();
  }

  int get width => (_viewportWidth * _scalingFactor).ceil();
  int get height => (_viewportHeight * _scalingFactor).ceil();
  int get clientWidth => _viewportWidth;
  int get clientHeight => _viewportHeight;
  double get scalingFactor => _scalingFactor;

  set clientWidth(int value) {
    _viewportWidth = value;
    _calculateScalingFactor();
  }

  set clientHeight(int value) {
    _viewportHeight = value;
    _calculateScalingFactor();
  }

  void _calculateScalingFactor() {
    if (_viewportWidth > _viewportHeight) {
      _scalingFactor = maxViewportSize / _viewportWidth;
    } else if (_viewportHeight >= _viewportWidth) {
      _scalingFactor = maxViewportSize / _viewportHeight;
    }
    _scalingFactor = min(16 / 9, max(9 / 16, _scalingFactor));
  }
}
