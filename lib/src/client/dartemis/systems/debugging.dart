part of gamedev_helpers;

class FpsRenderingSystem extends VoidEntitySystem {
  static const _deltaCount = 20;
  final List<double> deltas = new List.generate(_deltaCount, (_) => 0.0, growable: false);
  final String fillStyle;

  CanvasRenderingContext2D ctx;
  FpsRenderingSystem(this.ctx, {this.fillStyle: 'black'});

  void processSystem() {
    deltas[world.frame % _deltaCount] = world.delta;

    var fps = _deltaCount / deltas.reduce((combined, current) => combined + current);

    ctx.fillStyle = fillStyle;
    ctx.fillText('FPS: ${fps.toStringAsFixed(2)}', 5, 5);
  }
}