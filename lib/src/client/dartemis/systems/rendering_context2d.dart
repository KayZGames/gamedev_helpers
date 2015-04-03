part of gamedev_helpers;

class CanvasCleaningSystem extends VoidEntitySystem {
  CanvasElement canvas;
  String fillStyle;

  CanvasCleaningSystem(this.canvas, {this.fillStyle: 'white'});

  void processSystem() {
    canvas.context2D..fillStyle = fillStyle
                    ..clearRect(0, 0, canvas.width, canvas.height);
  }
}

