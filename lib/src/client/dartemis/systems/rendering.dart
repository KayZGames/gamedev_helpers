part of gamedev_helpers;

class CanvasCleaningSystem extends VoidEntitySystem {
  CanvasElement canvas;

  CanvasCleaningSystem(this.canvas);

  void processSystem() {
    canvas.context2D..fillStyle = 'white'
                    ..fillRect(0, 0, canvas.width, canvas.height);
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

  var itemStart = new _MenuItem('green', 'lightgreen', 'Start');
  var itemControls = new _MenuItem('green', 'lightgreen', 'Controls');
  var itemCredits = new _MenuItem('green', 'lightgreen', 'Credits');
  var items = new Map<int, _MenuItem>();

  MenuRenderingSystem(this.canvas) {
    width = canvas.width;
    height = canvas.height;
    buffer = new CanvasElement(width: width, height: height);
    ctx = buffer.context2D;
    ctx..font = '26px Verdana'
       ..strokeStyle = 'navy'
       ..fillStyle = 'darkred'
       ..lineWidth = 3;
    items[itemStart.id] = itemStart;
    items[itemControls.id] = itemControls;
    items[itemCredits.id] = itemCredits;

    var hidden = new CanvasElement(width: width, height: height);
    var hiddenCtx = hidden.context2D;
    _drawTopLeft(hiddenCtx, itemStart.hiddenBgColor);
    _drawTopRight(hiddenCtx, itemControls.hiddenBgColor);
    _drawBottomRight(hiddenCtx, itemCredits.hiddenBgColor);
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
    _drawTopLeft(ctx, itemStart.fillStyle);
    _drawTopRight(ctx, itemControls.fillStyle);
    _drawBottomLeft();
    _drawBottomRight(ctx, itemCredits.fillStyle);

    ctx..font = itemStart.highlight ? '30px Verdana' : '26px Verdana'
       ..fillStyle = itemStart.highlight ? 'red' : 'darkred'
       ..strokeStyle = itemStart.highlight ? 'darkblue' : 'navy'
       ..strokeText('Start', width ~/ 10, height ~/ 4)
       ..fillText('Start', width ~/ 10, height ~/ 4);

    _drawContent();
  }

  void _drawTopLeft(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(middleLeftX, middleLeftY)
       // middle left to top left
       ..bezierCurveTo(40, BORDER_Y + height ~/ 4, 40, BORDER_Y + height ~/ 8, topLeftX, topLeftY)
       // top left to top center
       ..bezierCurveTo(BORDER_X + width ~/ 8, 40 * gRatio * 2, BORDER_X + width ~/ 4, 40, topCenterX, topCenterY)
       // top center to middle left
       ..bezierCurveTo(3/8 * width, 1/8 * height, 1/8 * width, 1/6 * height, middleLeftX, middleLeftY)
       ..fillStyle = fillStyle
       ..fill();
  }


  void _drawTopRight(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(topCenterX, topCenterY)
       // top center to top right
       ..bezierCurveTo(width - BORDER_X - width ~/ 4, 80, width - BORDER_X - width ~/ 8, 20, topRightX, topRightY)
       // top right to middle right
       ..bezierCurveTo(width - 20, BORDER_Y + height ~/ 8, width - 80, BORDER_Y + height ~/ 6, middleRightX, middleRightY)
       // middle right to top center
       ..bezierCurveTo(7/8 * width, 2/8 * height, 6/8 * width, 1/8 * height, topCenterX, topCenterY)
       ..fillStyle = fillStyle
       ..fill();
  }

  void _drawBottomLeft() {
    ctx..beginPath()
       ..moveTo(middleLeftX, middleLeftY)
       // middle left to bottom left
       ..bezierCurveTo(40, bottomRightY - height ~/ 4, 40, bottomRightY - height ~/ 8, bottomLeftX, bottomLeftY)
       // bottom left to bottom center
       ..bezierCurveTo(BORDER_X + width ~/ 8, height - 40, BORDER_X + width ~/ 5, height - 80, bottomCenterX, bottomCenterY)
       // bottom center to middle left
       ..bezierCurveTo(2/8 * width, 7/8 * height, 1/8 * width, 6/8 * height, middleLeftX, middleLeftY)
       ..fillStyle = 'green'
       ..fill();
  }

  void _drawBottomRight(CanvasRenderingContext2D ctx, String fillStyle) {
    ctx..beginPath()
       ..moveTo(bottomCenterX, bottomCenterY)
       // bottom center to bottom right
       ..bezierCurveTo(bottomRightX - width ~/ 4, height - 40, bottomRightX - width ~/ 8, height - 40, bottomRightX, bottomRightY)
       // bottom right to middle right
       ..bezierCurveTo(width - 30, height - BORDER_Y - height ~/ 9, width - 90, height - BORDER_Y - height ~/ 8, middleRightX, middleRightY)
       // middle right to bottom center
       ..bezierCurveTo(7/8 * width, 6/8 * height, 6/8 * width, 7/8 * height, bottomCenterX, bottomCenterY)
       ..fillStyle = fillStyle
       ..fill();
  }


  void _drawContent() {
    ctx..beginPath()
       ..moveTo(topCenterX, topCenterY)
       // top center to middle right
       ..bezierCurveTo(6/8 * width, 1/8 * height, 7/8 * width, 2/8 * height, middleRightX, middleRightY)
       // middle right to bottom center
       ..bezierCurveTo(7/8 * width, 6/8 * height, 6/8 * width, 7/8 * height, bottomCenterX, bottomCenterY)
       // bottom center to middle left
       ..bezierCurveTo(2/8 * width, 7/8 * height, 1/8 * width, 6/8 * height, middleLeftX, middleLeftY)
       // middle left to top center
       ..bezierCurveTo(1/8 * width, 1/6 * height, 3/8 * width, 1/8 * height, topCenterX, topCenterY)
       ..fillStyle = 'navy'
       ..fill();
  }


  void end() {
    canvas.context2D.drawImage(buffer, 0, 0);
  }


  num get topCenterX => 9/16 * width;
  num get topCenterY => BORDER_Y * gRatio;
  num get topRightX => width - BORDER_X;
  num get topRightY => BORDER_Y*2;
  num get middleRightX => width - BORDER_X * gRatio * 1.5;
  num get middleRightY => 9/16 * height;
  num get bottomRightX => width - BORDER_X * gRatio;
  num get bottomRightY => height - BORDER_Y * gRatio;
  num get bottomCenterX => 1/2 * width;
  num get bottomCenterY => height - BORDER_Y * gRatio;
  num get bottomLeftX => BORDER_X;
  num get bottomLeftY => height - BORDER_Y;
  num get middleLeftX => BORDER_X * gRatio * 1.5;
  num get middleLeftY => 1/2 * height;
  num get topLeftX => BORDER_X;
  num get topLeftY => BORDER_Y;


}

class _MenuItem {
  static int nextId = 1;
  int id;
  String bgColor, bgSelectedColor, hiddenBgColor;
  String initial;
  bool highlight = false;
  _MenuItem(this.bgColor, this.bgSelectedColor, this.initial) {
    id = nextId++;
    // should be changed if there ever is a reason to go beyond 256 menu items
    hiddenBgColor = 'rgb($id, 0, 0)';
  }
  String get fillStyle => highlight ? bgSelectedColor : bgColor;
}