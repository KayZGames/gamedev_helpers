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
  // random cool number
  double gRatio = 1.618;
  static const BORDER_X = 50;
  static const BORDER_Y = 50;

  var itemStart = new _MenuItem('green', 'lightgreen');
  var itemControls = new _MenuItem('green', 'lightgreen');
  var itemCredits = new _MenuItem('green', 'lightgreen');
  var items = new Map<int, _MenuItem>();

  MenuRenderingSystem(this.canvas) {
    width = canvas.width;
    height = canvas.height;
    buffer = new CanvasElement(width: width, height: height);
    ctx = buffer.context2D;
    ctx..font = 'Verdana 12px'
       ..strokeStyle = 'navy'
       ..fillStyle = 'darkred'
       ..lineWidth = 3;
    items[itemStart.id] = itemStart;
    items[itemControls.id] = itemControls;
    items[itemCredits.id] = itemCredits;

    var hidden = new CanvasElement(width: width, height: height);
    var hiddenCtx = hidden.context2D;
    _drawUpperLeft(hiddenCtx, itemStart.hiddenBgColor);
    _drawUpperRight(hiddenCtx, itemControls.hiddenBgColor);
    _drawLowerRight(hiddenCtx, itemCredits.hiddenBgColor);
    int idOfHighlighted;
    canvas.onMouseMove.listen((event) {
      var data = hiddenCtx.getImageData(event.offset.x, event.offset.y, 1, 1);
      print(data.data);
      if (data.data[3] == 255) {
        var id = data.data[0];
        var item = items[id];
        print(id);
        print(item);
        if (null != item) {
          item.highlight = true;
          idOfHighlighted = id;
        }
      } else if (idOfHighlighted != null) {
        print('losing highlight');
        var item = items[idOfHighlighted];
        item.highlight = false;
        idOfHighlighted = null;
      }
    });
  }

  void begin() {
    ctx.clearRect(0, 0, width, height);
  }

  void processSystem() {
//    ctx.beginPath();
//    ctx.fillStyle = 'darkred';
//    ctx.moveTo(BORDER_X, BORDER_Y);
//    ctx.quadraticCurveTo(0, height, width - BORDER_X, height - BORDER_Y);
//    ctx.quadraticCurveTo(width, 0, BORDER_X, BORDER_Y);
//    ctx.moveTo(BORDER_X, height - BORDER_Y);
//    ctx.quadraticCurveTo(width, height, width - BORDER_X, BORDER_Y);
//    ctx.quadraticCurveTo(0, 0, BORDER_Y, height - BORDER_Y);
//    ctx.stroke();
//    ctx.fill();

    _drawUpperLeft(ctx, itemStart.fillStyle);
    _drawUpperRight(ctx, itemControls.fillStyle);
    _drawLowerLeft();
    _drawLowerRight(ctx, itemCredits.fillStyle);
    _drawContent();
  }

  void _drawUpperLeft(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(BORDER_X * gRatio, height ~/ 2)
       // middle left to upper left
       ..bezierCurveTo(40, BORDER_Y + height ~/ 4, 40, BORDER_Y + height ~/ 8, BORDER_X, BORDER_Y)
       // upper left to upper center
       ..bezierCurveTo(BORDER_X + width ~/ 8, 40, BORDER_X + width ~/ 4, 40, width ~/ 2, BORDER_Y * gRatio)
       // upper center to middle left
       ..bezierCurveTo(3/8 * width, 1/8 * height, 1/8 * width, 3/8 * height, BORDER_X * gRatio, height ~/ 2)
//       ..stroke()
       ..fillStyle = fillStyle
       ..fill();
  }

  void _drawUpperRight(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(width ~/ 2, BORDER_Y * gRatio)
       // upper center to upper right
       ..bezierCurveTo(width - BORDER_X - width ~/ 4, 40, width - BORDER_X - width ~/ 8, 40, width - BORDER_X, BORDER_Y)
       // upper right to middle right
       ..bezierCurveTo(width - 40, BORDER_Y + height ~/ 8, width - 40, BORDER_Y + height ~/ 4, width - BORDER_X * gRatio, height ~/ 2)
       // middle right to upper center
       ..bezierCurveTo(7/8 * width, 3/8 * height, 5/8 * width, 1/8 * height, width ~/ 2, BORDER_Y * gRatio)
//     ..stroke()
       ..fillStyle = fillStyle
       ..fill();
  }

  void _drawLowerLeft() {
    ctx..beginPath()
       ..moveTo(BORDER_X * gRatio, height ~/ 2)
       // middle left to lower left
       ..bezierCurveTo(40, height - BORDER_Y - height ~/ 4, 40, height - BORDER_Y - height ~/ 8, BORDER_X, height - BORDER_Y)
       // lower left to lower center
       ..bezierCurveTo(BORDER_X + width ~/ 8, height - 40, BORDER_X + width ~/ 4, height - 40, width ~/ 2, height - BORDER_Y * gRatio)
       // lower center to middle left
       ..bezierCurveTo(3/8 * width, 7/8 * height, 1/8 * width, 5/8 * height, BORDER_X * gRatio, height ~/ 2)
//       ..stroke()
       ..fillStyle = 'green'
       ..fill();
  }

  void _drawLowerRight(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(width ~/ 2, height - BORDER_Y * gRatio)
       // lower center to lower right
       ..bezierCurveTo(width - BORDER_X - width ~/ 4, height - 40, width - BORDER_X - width ~/ 8, height - 40, width - BORDER_X, height - BORDER_Y)
       // lower right to middle right
       ..bezierCurveTo(width - 40, height - BORDER_Y - height ~/ 8, width - 40, height - BORDER_Y - height ~/ 4, width - BORDER_X * gRatio, height ~/ 2)
       // middle right to lower center
       ..bezierCurveTo(7/8 * width, 5/8 * height, 5/8 * width, 7/8 * height, width ~/ 2, height - BORDER_Y * gRatio)
//       ..stroke()
       ..fillStyle = fillStyle
       ..fill();
  }

  void _drawContent() {
    ctx..beginPath()
       ..moveTo(width ~/ 2, BORDER_Y * gRatio)
       // upper center to middle right
       ..bezierCurveTo(5/8 * width, 1/8 * height, 7/8 * width, 3/8 * height, width - BORDER_X * gRatio, height ~/ 2)
       // middle right to lower center
       ..bezierCurveTo(7/8 * width, 5/8 * height, 5/8 * width, 7/8 * height, width ~/ 2, height - BORDER_Y * gRatio)
       // lower center to middle left
       ..bezierCurveTo(3/8 * width, 7/8 * height, 1/8 * width, 5/8 * height, BORDER_X * gRatio, height ~/ 2)
       // middle left to upper center
       ..bezierCurveTo(1/8 * width, 3/8 * height, 3/8 * width, 1/8 * height, width ~/ 2, BORDER_Y * gRatio)
//       ..stroke()
       ..fillStyle = 'navy'
       ..fill();
  }

  void end() {
    canvas.context2D.drawImage(buffer, 0, 0);
  }
}

class _MenuItem {
  static int nextId = 1;
  int id;
  String bgColor, bgSelectedColor, hiddenBgColor;
  bool highlight = false;
  _MenuItem(this.bgColor, this.bgSelectedColor) {
    id = nextId++;
    // should be changed if there ever is a reason to go beyond 256 menu items
    hiddenBgColor = 'rgb($id, 0, 0)';
  }
  String get fillStyle => highlight ? bgSelectedColor : bgColor;
}