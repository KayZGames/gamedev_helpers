part of gamedev_helpers;

class CanvasCleaningSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  int width, height;

  CanvasCleaningSystem(CanvasElement canvas) : ctx = canvas.context2D,
                                               width = canvas.width,
                                               height = canvas.height;

  void processSystem() {
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, width, height);
  }
}

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