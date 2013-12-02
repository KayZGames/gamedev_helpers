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

class MenuRenderingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  CanvasElement buffer;
  CanvasRenderingContext2D ctx;
  int width, height;
  double gRatio = 1.618;
  static const BORDER_X = 50;
  static const BORDER_Y = 50;

  MenuRenderingSystem(this.canvas) {
    width = canvas.width;
    height = canvas.height;
    buffer = new CanvasElement(width: width, height: height);
    ctx = buffer.context2D;
    ctx..font = 'Verdana 12px'
       ..strokeStyle = 'navy'
       ..fillStyle = 'darkred'
       ..lineWidth = 3;
  }

  void processSystem() {
    ctx.beginPath();
    ctx.moveTo(BORDER_X, BORDER_Y);
    ctx.quadraticCurveTo(0, height, width - BORDER_X, height - BORDER_Y);
    ctx.quadraticCurveTo(width, 0, BORDER_X, BORDER_Y);
    ctx.moveTo(BORDER_X, height - BORDER_Y);
    ctx.quadraticCurveTo(width, height, width - BORDER_X, BORDER_Y);
    ctx.quadraticCurveTo(0, 0, BORDER_Y, height - BORDER_Y);
    ctx.stroke();
    ctx.fill();

    ctx..beginPath()
       ..moveTo(BORDER_X, BORDER_Y)
       // upper left to middle left
       ..bezierCurveTo(40, BORDER_Y + height ~/ 8, 40, BORDER_Y + height ~/ 4, BORDER_X * gRatio, height ~/ 2)
       // middle left to lower left
       ..bezierCurveTo(40, height - BORDER_Y - height ~/ 4, 40, height - BORDER_Y - height ~/ 8, BORDER_X, height - BORDER_Y)
       // lower left to lower center
       ..bezierCurveTo(BORDER_X + width ~/ 8, height - 40, BORDER_X + width ~/ 4, height - 40, width ~/ 2, height - BORDER_Y * gRatio)
       // lower center to lower right
       ..bezierCurveTo(width - BORDER_X - width ~/ 4, height - 40, width - BORDER_X - width ~/ 8, height - 40, width - BORDER_X, height - BORDER_Y)
       // lower right to middle right
       ..bezierCurveTo(width - 40, height - BORDER_Y - height ~/ 8, width - 40, height - BORDER_Y - height ~/ 4, width - BORDER_X * gRatio, height ~/ 2)
       // middle right to upper right
       ..bezierCurveTo(width - 40, BORDER_Y + height ~/ 4, width - 40, BORDER_Y + height ~/ 8, width - BORDER_X, BORDER_Y)
       // upper right to upper center
       ..bezierCurveTo(width - BORDER_X - width ~/ 8, 40, width - BORDER_X - width ~/ 4, 40, width ~/ 2, BORDER_Y * gRatio)
       // upper center to upper left
       ..bezierCurveTo(BORDER_X + width ~/ 4, 40, BORDER_X + width ~/ 8, 40, BORDER_X, BORDER_Y)
       ..stroke();
  }

  void end() {
    canvas.context2D.drawImage(buffer, 0, 0);
  }
}