// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rendering_webgl.dart';

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$ParticleRenderingSystem extends WebGlRenderingSystem {
  late final Mapper<Position> positionMapper;
  late final Mapper<Particle> particleMapper;
  late final Mapper<Color> colorMapper;
  late final ViewProjectionMatrixManager viewProjectionMatrixManager;
  late final TagManager tagManager;
  late final CameraManager cameraManager;
  _$ParticleRenderingSystem(RenderingContext2 gl)
      : super(gl, Aspect.empty()..allOf([Position, Particle, Color]));
  @override
  void initialize() {
    super.initialize();
    positionMapper = Mapper<Position>(world);
    particleMapper = Mapper<Particle>(world);
    colorMapper = Mapper<Color>(world);
    viewProjectionMatrixManager =
        world.getManager<ViewProjectionMatrixManager>();
    tagManager = world.getManager<TagManager>();
    cameraManager = world.getManager<CameraManager>();
  }
}

abstract class _$WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  late final Mapper<Orientation> orientationMapper;
  late final Mapper<Renderable> renderableMapper;
  late final Mapper<Position> positionMapper;
  late final Mapper<Camera> cameraMapper;
  late final TagManager tagManager;
  late final ViewProjectionMatrixManager viewProjectionMatrixManager;
  _$WebGlSpriteRenderingSystem(RenderingContext2 gl, Aspect aspect)
      : super(gl, aspect..allOf([Orientation, Renderable]));
  @override
  void initialize() {
    super.initialize();
    orientationMapper = Mapper<Orientation>(world);
    renderableMapper = Mapper<Renderable>(world);
    positionMapper = Mapper<Position>(world);
    cameraMapper = Mapper<Camera>(world);
    tagManager = world.getManager<TagManager>();
    viewProjectionMatrixManager =
        world.getManager<ViewProjectionMatrixManager>();
  }
}
