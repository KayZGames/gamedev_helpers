part of gamedev_helpers;

class FpsRenderingSystem extends VoidEntitySystem {
  static const _deltaCount = 20;
  final List<double> deltas =
      List.generate(_deltaCount, (_) => 0.0, growable: false);
  final String fillStyle;

  CanvasRenderingContext2D ctx;
  FpsRenderingSystem(this.ctx, {this.fillStyle = 'black'});

  @override
  void processSystem() {
    deltas[frame % _deltaCount] = world.delta;

    final fps =
        _deltaCount / deltas.reduce((combined, current) => combined + current);

    ctx
      ..save()
      ..font = '10px Verdana'
      ..textBaseline = 'top'
      ..fillStyle = fillStyle
      ..fillText('FPS: ${fps.toStringAsFixed(2)}', 5, 5)
      ..restore();
  }
}

class FpsPrintingSystem extends VoidEntitySystem {
  static const _deltaCount = 20;
  final List<double> deltas =
      List.generate(_deltaCount, (_) => 0.0, growable: false);

  FpsPrintingSystem();

  @override
  void processSystem() {
    deltas[frame % _deltaCount] = world.delta;

    final fps =
        _deltaCount / deltas.reduce((combined, current) => combined + current);

    print('FPS: ${fps.toStringAsFixed(2)}');
    print('Entities: ${world.entityManager.activeEntityCount}');
  }
}
