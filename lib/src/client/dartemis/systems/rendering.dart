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