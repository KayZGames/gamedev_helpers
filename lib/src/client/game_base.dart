part of gamedev_helpers;

abstract class GameBase {
  static const int rendering = 0;
  static const int physics = 1;

  final CanvasElement canvas;
  final CanvasRenderingContext ctx;
  final GameHelper helper;
  final String spriteSheetName;
  final String bodyDefsName;
  final String musicName;
  final int _width;
  final int _height;
  final bool webgl;
  World world;
  Map<String, List<Polygon>> bodyDefs;
  SpriteSheet spriteSheet;
  AudioBuffer music;
  AudioContext audioContext;
  double _lastTime;
  double _lastTimeP;
  bool fullscreen = false;
  bool _stop = false;
  bool _pause = false;

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase(String appName, String canvasSelector, int width, int height,
      {this.spriteSheetName: 'assets',
      this.bodyDefsName: 'assets',
      this.musicName: null,
      AudioContext audioContext: null,
      bool webgl: false,
      bool depthTest: true,
      bool blending: true})
      : canvas = querySelector(canvasSelector),
        audioContext = audioContext,
        helper = new GameHelper(appName, audioContext),
        webgl = webgl,
        ctx = webgl
            ? (querySelector(canvasSelector) as CanvasElement).getContext3d()
            : (querySelector(canvasSelector) as CanvasElement).context2D
            as CanvasRenderingContext,
        _width = width,
        _height = height {
    canvas.width = width;
    canvas.height = height;
    if (!webgl) {
      (ctx as CanvasRenderingContext2D)
        ..textBaseline = "top"
        ..font = '12px Verdana';
    } else {
      if (depthTest) {
        (ctx as RenderingContext).enable(RenderingContext.DEPTH_TEST);
      }
      if (blending) {
        (ctx as RenderingContext)
          ..enable(BLEND)
          ..blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
      }
//      (ctx as RenderingContext)
//                               ..enable(RenderingContext.POLYGON_OFFSET_FILL);
//                               ..polygonOffset(1.0, 1.0);
      ;
    }
    canvas.onFullscreenChange.listen(_handleFullscreen);
    world = createWorld();
    var fullscreenButton = querySelector('button#fullscreen');
    if (null != fullscreenButton) {
      fullscreenButton.onClick
          .listen((_) => querySelector('canvas').requestFullscreen());
    }
  }

  World createWorld() => new World();

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase.noAssets(
      String appName, String canvasSelector, int width, int height,
      {bool webgl: false, bool depthTest: true, bool blending: true})
      : this(appName, canvasSelector, width, height,
            spriteSheetName: null,
            bodyDefsName: null,
            musicName: null,
            webgl: webgl,
            depthTest: depthTest,
            blending: blending);

  GameBase.noCanvas(String appNahme)
      : canvas = null,
        ctx = null,
        helper = new GameHelper(appNahme, null),
        bodyDefsName = null,
        spriteSheetName = null,
        musicName = null,
        _width = null,
        _height = null,
        webgl = false {
    world = createWorld();
  }

  Future _init() => _assetsLoaded()
      .then((_) => onInit())
      .then((_) => _initGame())
      .then((_) => onInitDone());

  /// Do whatever you have to do before starting to create [Entity]s and
  /// [EntitySystem]s.
  Future onInit() => null;

  /// Do whatever you have to do after world.initialize() was called.
  Future onInitDone() => null;

  Future _assetsLoaded() {
    var loader = <Future>[];
    if (null != spriteSheetName) {
      loader.add(helper
          .loadSpritesheet(spriteSheetName)
          .then((result) => spriteSheet = result));
    }
    if (null != bodyDefsName) {
      loader.add(helper
          .loadPolygons(bodyDefsName)
          .then((result) => bodyDefs = result));
    }
    if (null != musicName) {
      loader.add(helper.loadMusic(musicName).then((result) => music = result));
    }
    return Future.wait(loader).then((_) {
      if (null != bodyDefs) {
        bodyDefs.forEach((bodyId, shapes) {
          var offset = spriteSheet.sprites['$bodyId.png'].offset -
              spriteSheet.sprites['$bodyId.png'].trimmed;
          shapes.forEach((shape) {
            shape.vertices =
                shape.vertices.map((vertex) => vertex + offset).toList();
          });
        });
      }
    });
  }

  Future _initGame() {
    createEntities();
    return initSystems().then((_) {
      world.initialize();
    });
  }

  Future<GameBase> start() {
    return _init().then((_) {
      _startGameLoops();
      return this;
    });
  }

  void _startGameLoops() {
    _lastTimeP = window.performance.now().toDouble();

    var physicsSystem = world.systems
        .firstWhere((system) => system.group == 1, orElse: () => null);
    if (null != physicsSystem) {
      physicsLoop();
    }
    window.requestAnimationFrame(_firstUpdate);
  }

  void stop() {
    _stop = true;
  }

  bool get isStopped => _stop;

  void pause() {
    if (!_stop) {
      _pause = true;
    }
  }

  void resume() {
    if (!_stop) {
      _pause = false;
      _startGameLoops();
    }
  }

  void physicsLoop() {
    var time = window.performance.now().toDouble();
    world.delta = (time - _lastTimeP) / 1000;
    _lastTimeP = time;
    world.process(1);

    if (!_stop && !_pause) {
      new Future.delayed(new Duration(milliseconds: 5), physicsLoop);
    }
  }

  void _firstUpdate(double time) {
    _lastTime = time / 1000.0;
    world.delta = 1 / 60;
    world.process();
    window.animationFrame.then((time) => update(time: time / 1000.0));
  }

  void update({double time}) {
    var delta = time - _lastTime;
    delta = min(0.05, delta);
    world.delta = delta;
    _lastTime = time;
    world.process();
    if (!_stop && !_pause) {
      window.animationFrame.then((time) => update(time: time / 1000.0));
    }
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
      canvas.context2D
        ..textBaseline = "top"
        ..font = '12px Verdana';
    }
    handleResize(canvas.width, canvas.height);
  }

  void handleResize(int width, int height) {}

  /// Create your entities
  void createEntities();

  /// Return a list of all the [EntitySystem]s required for this game.
  Map<int, List<EntitySystem>> getSystems();

  Future initSystems() {
    List<Future> shaderSourceFutures = new List();
    getSystems().forEach((group, systems) {
      systems.forEach((system) {
        world.addSystem(system, group: group);
        if (system is WebGlRenderingMixin) {
          shaderSourceFutures.add(helper
              .loadShader(system.vShaderFile, system.fShaderFile)
              .then((shaderSource) {
            system.shaderSource = shaderSource;
          }));
        }
      });
    });
    return Future.wait(shaderSourceFutures);
  }

  Entity addEntity(List<Component> components) =>
      world.createAndAddEntity(components);
}
