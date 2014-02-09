part of gamedev_helpers;

abstract class GameBase {

  final CanvasElement canvas;
  final CanvasRenderingContext ctx;
  final GameHelper helper;
  final String spriteSheetName;
  final String bodyDefsName;
  final int _width;
  final int _height;
  final bool webgl;
  World world;
  Map<String, List<Polygon>> bodyDefs;
  SpriteSheet spriteSheet;
  double _lastTime;
  var _initSuccess = false;
  var fullscreen = false;

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase(String appName, String canvasSelector, int width, int height, {this.spriteSheetName: 'assets', this.bodyDefsName: 'assets', bool webgl: false}) :
                                  canvas = querySelector(canvasSelector),
                                  helper = new GameHelper(appName),
                                  webgl = webgl,
                                  ctx = webgl ? (querySelector(canvasSelector) as CanvasElement).getContext3d() : (querySelector(canvasSelector) as CanvasElement).context2D,
                                  _width = width,
                                  _height = height {
    canvas.width = width;
    canvas.height = height;
    if (!webgl) {
      canvas.context2D..textBaseline = "top"
                      ..font = '12px Verdana';
    }
    canvas.onFullscreenChange.listen(_handleFullscreen);
    world = createWorld();
    var fullscreenButton = querySelector('button#fullscreen');
    if (null != fullscreenButton) {
      fullscreenButton.onClick.listen((_) => querySelector('canvas').requestFullscreen());
    }
  }

  World createWorld() => new World();
  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase.noAssets(String appName, String canvasSelector, int width, int height, {bool webgl: false}) :
                                  this(appName, canvasSelector, width, height, spriteSheetName: null, bodyDefsName: null, webgl: webgl);

  Future _init() => _assetsLoaded().then((_) => onInit())
                                 .then((_) => _initGame())
                                 .then((_) => onInitDone())
                                 .then((_) => _initSuccess = true);

  /// Do whatever you have to do before starting to create [Entity]s and
  /// [EntitySystem]s.
  Future onInit();
  /// Do whatever you have to do after world.initialize() was called.
  Future onInitDone();

  Future _assetsLoaded() {
    var loader = <Future>[];
    if (null != spriteSheetName) {
      loader.add(helper.loadSpritesheet(spriteSheetName).then((result) => spriteSheet = result));
    }
    if (null != bodyDefsName) {
      loader.add(helper.loadPolygons(bodyDefsName).then((result) => bodyDefs = result));
    }
    return Future.wait(loader).then((_) {
      if (null != bodyDefs) {
        bodyDefs.forEach((bodyId, shapes) {
          var offset = spriteSheet.sprites['$bodyId.png'].offset - spriteSheet.sprites['$bodyId.png'].trimmed;
          shapes.forEach((shape) {
            shape.vertices = shape.vertices.map((vertex) => vertex + offset).toList();
          });
        });
      }
    });
  }

  Future _initGame() {
    createEntities();
    initSystems();
    world.initialize();
  }

  void start() {
    _init().then((_) => window.requestAnimationFrame(_firstUpdate));
  }

  void _firstUpdate(double time) {
    _lastTime = time;
    world.delta = 16.66;
    world.process();
    window.requestAnimationFrame(_update);
  }

  void _update(double time) {
    world.delta = time - _lastTime;
    _lastTime = time;
    world.process();
    window.requestAnimationFrame(_update);
  }

  void _handleFullscreen(Event e) {
    fullscreen = !fullscreen;
    if (fullscreen) {
      canvas.width = window.screen.width;
      canvas.height = window.screen.height;
    } else {
      canvas.width = _width;
      canvas.height = _height;
    }
    if (!webgl) {
      canvas.context2D..textBaseline = "top"
                      ..font = '12px Verdana';
    }
    handleResize(canvas.width, canvas.height);
  }

  void handleResize(int width, int height) {}

  /// Create your entities
  void createEntities();
  /// Return a list of all the [EntitySystem]s required for this game.
  List<EntitySystem> getSystems();

  void initSystems() => getSystems().forEach((system) => world.addSystem(system));

  Entity addEntity(List<Component> components) => world.createAndAddEntity(components);
}
