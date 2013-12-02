part of gamedev_helpers;

class FpsRenderingSystem extends VoidEntitySystem {
  static const _deltaCount = 20;
  static const _dividend = _deltaCount * 1000;
  List<double> deltas = new List.generate(_deltaCount, (_) => 0.0, growable: false);

  CanvasRenderingContext2D ctx;
  FpsRenderingSystem(this.ctx);

  void processSystem() {
    deltas[world.frame % _deltaCount] = world.delta;

    var fps = _dividend / deltas.reduce((combined, current) => combined + current);

    ctx.fillStyle = 'black';
    ctx.fillText('FPS: ${fps.toStringAsFixed(2)}', 5, 5);
  }
}