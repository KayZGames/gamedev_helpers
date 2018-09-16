part of gamedev_helpers;

abstract class GameBase {
  static const int rendering = 0;
  static const int physics = 1;

  final StreamController<bool> _pauseStreamController =
      StreamController<bool>();
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final RenderingContext gl;
  final GameHelper helper;
  final String spriteSheetName;
  final String bodyDefsName;
  final String musicName;
  final bool webgl;
  final bool useMaxDelta;
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
  bool _errorInitializingWebGL = false;

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase(String appName, String canvasSelector,
      {this.spriteSheetName = 'assets',
      this.bodyDefsName = 'assets',
      this.musicName,
      this.audioContext,
      this.webgl = false,
      bool depthTest = true,
      bool blending = true,
      this.useMaxDelta = true})
      : canvas = querySelector(canvasSelector),
        helper = GameHelper(appName, audioContext),
        ctx = webgl
            ? null
            : (querySelector(canvasSelector) as CanvasElement).context2D,
        gl = webgl
            ? (querySelector(canvasSelector) as CanvasElement).getContext3d()
            : null {
    if (ctx != null) {
      ctx
        ..textBaseline = 'top'
        ..font = '12px Verdana';
    } else if (gl != null) {
      if (depthTest) {
        gl.enable(WebGL.DEPTH_TEST);
      }
      if (blending) {
        gl
          ..enable(WebGL.BLEND)
          ..blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
      }
//      (ctx as RenderingContext)
//                               ..enable(WebGL.POLYGON_OFFSET_FILL);
//                               ..polygonOffset(1.0, 1.0);
    } else {
      _errorInitializingWebGL = true;
    }
    canvas.onFullscreenChange.listen(_handleFullscreen);
    world = createWorld()
      ..addManager(CameraManager(canvas.width, canvas.height));
    final fullscreenButton = querySelector('button#fullscreen');
    if (null != fullscreenButton) {
      fullscreenButton.onClick
          .listen((_) => querySelector('canvas').requestFullscreen());
    }
  }

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase.noAssets(String appName, String canvasSelector,
      {bool webgl = false,
      bool depthTest = true,
      bool blending = true,
      bool useMaxDelta = true})
      : this(appName, canvasSelector,
            spriteSheetName: null,
            bodyDefsName: null,
            musicName: null,
            webgl: webgl,
            useMaxDelta: useMaxDelta,
            depthTest: depthTest,
            blending: blending);

  GameBase.noCanvas(String appNahme)
      : canvas = null,
        ctx = null,
        gl = null,
        useMaxDelta = true,
        helper = GameHelper(appNahme, null),
        bodyDefsName = null,
        spriteSheetName = null,
        musicName = null,
        webgl = false {
    world = createWorld();
  }

  World createWorld() => World();

  bool get webGlInitialized => webgl && !_errorInitializingWebGL;

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
    final loader = <Future>[];
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
    if (null != musicName && null != audioContext) {
      loader.add(helper.loadMusic(musicName).then((result) => music = result));
    }
    return Future.wait(loader).then((_) {
      if (null != bodyDefs) {
        bodyDefs.forEach((bodyId, shapes) {
          final offset = spriteSheet.sprites['$bodyId.png'].offset -
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

  Future<GameBase> start() => _init().then((_) {
        _startGameLoops();
        return this;
      });

  void _startGameLoops() {
    _lastTimeP = window.performance.now().toDouble();

    final physicsSystem = world.systems
        .firstWhere((system) => system.group == 1, orElse: () => null);
    if (null != physicsSystem) {
      physicsLoop();
    }
    window.requestAnimationFrame(_firstUpdate);
  }

  void stop() {
    _stop = true;
    _pauseStreamController.close();
  }

  bool get isStopped => _stop;

  void pause() {
    if (!_stop) {
      _pause = true;
      _pauseStreamController.add(true);
    }
  }

  Stream<bool> onPause() => _pauseStreamController.stream;

  bool get paused => _pause;

  void resume() {
    if (!_stop && _pause) {
      _pause = false;
      _pauseStreamController.add(false);
      _startGameLoops();
    }
  }

  void physicsLoop() {
    final time = window.performance.now().toDouble();
    world.delta = (time - _lastTimeP) / 1000;
    _lastTimeP = time;
    world.process(1);

    if (!_stop && !_pause) {
      Future.delayed(const Duration(milliseconds: 5), physicsLoop);
    }
  }

  void _firstUpdate(num time) {
    _resize();
    _lastTime = time / 1000.0;
    world
      ..delta = 1 / 60
      ..process();
    window.animationFrame.then((time) => update(time: time / 1000.0));
  }

  void update({num time}) {
    _resize();
    var delta = time - _lastTime;
    if (useMaxDelta) {
      delta = min(0.05, delta);
    }
    world.delta = delta;
    _lastTime = time;
    world.process();
    if (!_stop && !_pause) {
      window.animationFrame.then((time) => update(time: time / 1000.0));
    }
  }

  void _handleFullscreen(Event e) {
    fullscreen = !fullscreen;
    _resize();
  }

  void _resize() {
    if (null != canvas) {
      _updateCameraManager(
          document.body.clientWidth, document.body.clientHeight);
      handleResize();
    }
  }

  void _updateCameraManager(int width, int height) {
    (world.getManager<CameraManager>())
      ..clientWidth = width
      ..clientHeight = height;
  }

  void handleResize() {
    resizeCanvas(canvas);
    if (paused || isStopped) {
      world
        ..delta = 0.0
        ..process(GameBase.rendering);
    }
    if (!webgl) {
      canvas.context2D
        ..textBaseline = "top"
        ..font = '12px Verdana';
    } else {
      gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
    }
  }

  /// Create your entities
  void createEntities();

  /// Return a list of all the [EntitySystem]s required for this game.
  Map<int, List<EntitySystem>> getSystems();

  Future initSystems() {
    final List<Future> shaderSourceFutures = [];
    getSystems().forEach((group, systems) {
      for (EntitySystem system in systems) {
        world.addSystem(system, group: group);
        if (system is WebGlRenderingMixin) {
          final webglMixin = system as WebGlRenderingMixin;
          shaderSourceFutures.add(helper
              .loadShader(webglMixin.libName, webglMixin.vShaderFile,
                  webglMixin.fShaderFile)
              .then((shaderSource) {
            webglMixin.shaderSource = shaderSource;
          }));
        }
      }
    });
    return Future.wait(shaderSourceFutures);
  }

  Entity addEntity(List<Component> components) =>
      world.createAndAddEntity(components);

  void resizeCanvas(CanvasElement canvas, {bool useClientSize = false}) {
    final camera = world.getManager<CameraManager>();
    canvas
      ..width = useClientSize ? camera.clientWidth : camera.width
      ..height = useClientSize ? camera.clientHeight : camera.height;
    canvas.style
      ..width = '${camera.clientWidth}px'
      ..height = '${camera.clientHeight}px';
  }
}
