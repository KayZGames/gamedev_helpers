import 'dart:js_interop';

import 'package:dartemis/dartemis.dart';
import 'package:web/web.dart';

class FpsRenderingSystem extends VoidEntitySystem {
  static const _deltaCount = 20;
  final List<double> deltas =
      List.generate(_deltaCount, (_) => 0.0, growable: false);
  final String fillStyle;

  CanvasRenderingContext2D ctx;
  FpsRenderingSystem(this.ctx, this.fillStyle);

  @override
  void processSystem() {
    deltas[frame % _deltaCount] = world.delta;

    final fps =
        _deltaCount / deltas.reduce((combined, current) => combined + current);

    ctx
      ..save()
      ..font = '10px Verdana'
      ..textBaseline = 'top'
      ..fillStyle = fillStyle.toJS
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

    // ignore: avoid_print
    print('FPS: ${fps.toStringAsFixed(2)}');
    // ignore: avoid_print
    print('Entities: ${world.entityManager.activeEntityCount}');
  }
}
