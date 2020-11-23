import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'dart:web_gl';

import 'package:aspen_assets/aspen_assets.dart';
import 'package:dartemis/dartemis.dart';
import 'package:gamedev_helpers_core/gamedev_helpers_core.dart';

import 'game_helper.dart';
import 'internal/asset_loader.dart';
import 'internal/webgl_rendering_mixin.dart';
import 'sprite_sheet.dart';

abstract class GameBase {
  static const int rendering = 0;
  static const int physics = 1;

  final StreamController<bool> _pauseStreamController =
      StreamController<bool>();
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final RenderingContext gl;
  final GameHelper helper;
  final JsonAsset spriteSheetJson;
  final BinaryAsset spriteSheetImg;
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
      {this.spriteSheetJson,
      this.spriteSheetImg,
      this.bodyDefsName = 'assets',
      this.musicName,
      this.audioContext,
      this.webgl = false,
      bool depthTest = true,
      bool blending = true,
      this.useMaxDelta = true})
      : canvas = querySelector(canvasSelector) as CanvasElement,
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
        spriteSheetJson = null,
        spriteSheetImg = null,
        bodyDefsName = null,
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

  /// Do whatever you have to do before starting to create [int]s and
  /// [EntitySystem]s.
  Future onInit() async => null;

  /// Do whatever you have to do after world.initialize() was called.
  Future onInitDone() async => null;

  Future _assetsLoaded() {
    final loader = <Future>[];
    if (null != spriteSheetJson && null != spriteSheetImg) {
      loader.add(helper
          .loadSpritesheet(spriteSheetJson, spriteSheetImg)
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
      bodyDefs?.forEach((bodyId, shapes) {
        final offset = spriteSheet.sprites['$bodyId.png'].offset -
            spriteSheet.sprites['$bodyId.png'].trimmed;
        for (final shape in shapes) {
          shape.vertices =
              shape.vertices.map((vertex) => vertex + offset).toList();
        }
      });
    });
  }

  void _initGame() {
    createEntities();
    initSystems();
    world.initialize();
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

  void update({double time}) {
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
        ..process();
    }
    if (!webgl) {
      canvas.context2D
        ..textBaseline = 'top'
        ..font = '12px Verdana';
    } else {
      gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
    }
  }

  /// Create your entities
  void createEntities();

  /// Return a list of all the [EntitySystem]s required for this game.
  Map<int, List<EntitySystem>> getSystems();

  void initSystems() {
    getSystems().forEach((group, systems) {
      for (final system in systems) {
        world.addSystem(system, group: group);
        if (system is WebGlRenderingMixin) {
          final webglMixin = system as WebGlRenderingMixin;
          webglMixin.shaderSource = helper.loadShader(
              webglMixin.vShaderAsset, webglMixin.fShaderAsset);
        }
      }
    });
  }

  int addEntity<T extends Component>(List<T> components) =>
      world.createEntity(components);

  void resizeCanvas(CanvasElement canvas) {
    final camera = world.getManager<CameraManager>();
    canvas
      ..width = camera.clientWidth
      ..height = camera.clientHeight;
    canvas.style
      ..width = '${camera.clientWidth}px'
      ..height = '${camera.clientHeight}px';
  }
}
