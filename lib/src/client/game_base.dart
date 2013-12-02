part of gamedev_helpers;

abstract class GameBase {

  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final World world = new World();
  final GameHelper helper;
  final String spriteSheetName;
  final String bodyDefsName;
  Map<String, List<Polygon>> bodyDefs;
  SpriteSheet spriteSheet;
  double _lastTime;
  bool _initSuccess = false;

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase(String appName, String canvasSelector, int width, int height, {this.spriteSheetName: 'assets', this.bodyDefsName: 'assets'}) :
                                  canvas = querySelector(canvasSelector),
                                  helper = new GameHelper(appName),
                                  ctx = (querySelector(canvasSelector) as CanvasElement).context2D{
    canvas.width = width;
    canvas.height = height;
    canvas.context2D..textBaseline = "top"
                    ..font = '12px Verdana';
  }
  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase.noAssets(String appName, String canvasSelector, int width, int height) :
                                  this(appName, canvasSelector, width, height, spriteSheetName: null, bodyDefsName: null);

  Future _init() => _assetsLoaded().then((_) => onInit())
                                 .then((_) => _initGame())
                                 .then((_) => onInitDone())
                                 .then((_) => _initSuccess = true);

  /// Do whatever you have to do before starting to create [Entity]s and
  /// [EntitySystem]s.
  void onInit();
  /// Do whatever you have to do after world.initialize() was called.
  void onInitDone();

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

  void _initGame() {
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

  /// Create your entities
  void createEntities();
  /// Return a list of all the [EntitySystem]s required for this game.
  List<EntitySystem> getSystems();

  void initSystems() => getSystems().forEach((system) => world.addSystem(system));

  Entity addEntity(List<Component> components) {
    var entity = world.createEntity();
    components.forEach((component) => entity.addComponent(component));
    entity.addToWorld();
    return entity;
  }
}
