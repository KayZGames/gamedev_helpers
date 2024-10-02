import 'dart:js_interop';

import 'package:dartemis/dartemis.dart';
import 'package:web/web.dart';

class CanvasCleaningSystem extends VoidEntitySystem {
  HTMLCanvasElement canvas;
  String fillStyle;

  CanvasCleaningSystem(this.canvas, {this.fillStyle = 'white'});

  @override
  void processSystem() {
    canvas.context2D
      ..fillStyle = fillStyle.toJS
      ..clearRect(0, 0, canvas.width, canvas.height);
  }
}
