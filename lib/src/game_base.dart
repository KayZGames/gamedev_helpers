import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'dart:web_gl';

import 'package:asset_data/asset_data.dart';
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
  final CanvasElement glCanvas;
  final CanvasElement hudCanvas;
  final CanvasRenderingContext2D ctx;
  final CanvasRenderingContext2D hudCtx;
  final RenderingContext2 gl;
  final GameHelper helper;
  final JsonAsset? spriteSheetJson;
  final BinaryAsset? spriteSheetImg;
  final String? bodyDefsName;
  final String? musicName;
  final bool useMaxDelta;
  late World world;
  Map<String, List<Polygon>>? bodyDefs;
  SpriteSheet? spriteSheet;
  AudioBuffer? music;
  AudioContext? audioContext;
  double _lastTime = 0;
  double _lastTimeP = 0;
  bool fullscreen = false;
  bool _stop = false;
  bool _pause = false;

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase(
    String appName, {
    this.spriteSheetJson,
    this.spriteSheetImg,
    this.bodyDefsName = 'assets',
    this.musicName,
    this.audioContext,
    bool depthTest = true,
    bool blending = true,
    this.useMaxDelta = true,
  })  : assert(
          querySelector('#game') is CanvasElement,
          'Canvas with id "canvas" required',
        ),
        assert(
          querySelector('#webgl') is CanvasElement,
          'Canvas with id "webgl" required',
        ),
        assert(
          querySelector('#hud') is CanvasElement,
          'Canvas with id "hud" required',
        ),
        canvas = querySelector('#game')! as CanvasElement,
        glCanvas = querySelector('#webgl')! as CanvasElement,
        hudCanvas = querySelector('#hud')! as CanvasElement,
        helper = GameHelper(appName, audioContext),
        ctx = (querySelector('#game')! as CanvasElement).context2D,
        hudCtx = (querySelector('#hud')! as CanvasElement).context2D,
        gl = (querySelector('#webgl')! as CanvasElement).getContext('webgl2')!
            as RenderingContext2 {
    ctx
      ..textBaseline = 'top'
      ..font = '12px Verdana';

    if (depthTest) {
      gl
        ..enable(WebGL.DEPTH_TEST)
        ..depthFunc(WebGL.LEQUAL);
    }
    if (blending) {
      gl
        ..enable(WebGL.BLEND)
        ..blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);
    }
    gl
      ..enable(WebGL.POLYGON_OFFSET_FILL)
      ..polygonOffset(1.0, 1.0);

    canvas.onFullscreenChange.listen(_handleFullscreen);
    world = createWorld()
      ..addManager(CameraManager(canvas.width!, canvas.height!));
    final fullscreenButton = querySelector('button#fullscreen');
    if (null != fullscreenButton) {
      fullscreenButton.onClick
          .listen((_) async => querySelector('canvas')!.requestFullscreen());
    }
  }

  /// [appName] is used to refernce assets and has to be the name of the library
  /// which contains the assets. Usually the game itself.
  GameBase.noAssets(
    String appName, {
    bool depthTest = true,
    bool blending = true,
    bool useMaxDelta = true,
  }) : this(
          appName,
          bodyDefsName: null,
          musicName: null,
          useMaxDelta: useMaxDelta,
          depthTest: depthTest,
          blending: blending,
        );

  World createWorld() => World();

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
    final localSpriteSheetJson = spriteSheetJson;
    final localSpriteSheetImg = spriteSheetImg;
    if (null != localSpriteSheetJson && null != localSpriteSheetImg) {
      loader.add(
        helper
            .loadSpritesheet(localSpriteSheetJson, localSpriteSheetImg)
            .then((result) => spriteSheet = result),
      );
    }
    final localBodyDefsName = bodyDefsName;
    if (null != localBodyDefsName) {
      loader.add(
        helper
            .loadPolygons(localBodyDefsName)
            .then((result) => bodyDefs = result),
      );
    }
    final localMusicName = musicName;
    if (null != localMusicName && null != audioContext) {
      loader.add(
        helper.loadMusic(localMusicName).then((result) => music = result),
      );
    }
    return Future.wait(loader).then((_) {
      bodyDefs?.forEach((bodyId, shapes) {
        final sprite = spriteSheet!.sprites['$bodyId.png']!;
        final offset = sprite.offset - sprite.trimmed;
        for (final shape in shapes) {
          shape.vertices =
              shape.vertices.map((vertex) => vertex + offset).toList();
        }
      });
    });
  }

  void _initGame() {
    _initSystems();
    _initManagers();
    world.initialize();
    createEntities();
  }

  Future<GameBase> start() => _init().then((_) {
        _startGameLoops();
        return this;
      });

  void _startGameLoops() {
    _lastTimeP = window.performance.now();

    if (world.systems.any((system) => system.group == 1)) {
      physicsLoop();
    }
    window.requestAnimationFrame(_firstUpdate);
  }

  Future<void> stop() async {
    _stop = true;
    await _pauseStreamController.close();
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
    final time = window.performance.now();
    world.delta = (time - _lastTimeP) / 1000;
    _lastTimeP = time;
    world.process(1);

    if (!_stop && !_pause) {
      Future.delayed(const Duration(milliseconds: 5), physicsLoop);
    }
  }

  Future<void> _firstUpdate(num time) async {
    _resize();
    _lastTime = time / 1000.0;
    world
      ..delta = 1 / 60
      ..process();
    await update(time: await window.animationFrame / 1000.0);
  }

  Future<void> update({required double time}) async {
    _resize();
    var delta = time - _lastTime;
    if (useMaxDelta) {
      delta = min(0.05, delta);
    }
    world.delta = delta;
    _lastTime = time;
    world.process();
    if (!_stop && !_pause) {
      await update(time: await window.animationFrame / 1000.0);
    }
  }

  void _handleFullscreen(Event e) {
    fullscreen = !fullscreen;
    _resize();
  }

  void _resize() {
    _updateCameraManager(
      document.body!.clientWidth,
      document.body!.clientHeight,
    );
    handleResize();
  }

  void _updateCameraManager(int width, int height) {
    (world.getManager<CameraManager>())
      ..clientWidth = width
      ..clientHeight = height;
  }

  void handleResize() {
    resizeCanvas(canvas);
    resizeCanvas(hudCanvas);
    resizeCanvas(glCanvas);
    if (paused || isStopped) {
      world
        ..delta = 0.0
        ..process();
    }
    ctx
      ..textBaseline = 'top'
      ..font = '12px Verdana';
    hudCtx
      ..textBaseline = 'top'
      ..font = '12px Verdana';
    gl.viewport(0, 0, gl.drawingBufferWidth!, gl.drawingBufferHeight!);
  }

  /// Create your entities
  void createEntities();

  /// Return a list of all the [EntitySystem]s required for this game.
  Map<int, List<EntitySystem>> getSystems();

  /// Return a list of all [Manager]s required for this game.
  List<Manager> getManagers();

  void _initSystems() {
    getSystems().forEach((group, systems) {
      for (final system in systems) {
        world.addSystem(system, group: group);
        if (system is WebGlRenderingMixin) {
          final webglMixin = system as WebGlRenderingMixin;
          webglMixin.shaderSource = helper.loadShader(
            webglMixin.vShaderAsset,
            webglMixin.fShaderAsset,
          );
        }
      }
    });
  }

  void _initManagers() {
    getManagers().forEach(world.addManager);
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
