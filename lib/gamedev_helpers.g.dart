// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedev_helpers;

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> positionMapper;
  Mapper<Particle> particleMapper;
  Mapper<Color> colorMapper;
  WebGlViewProjectionMatrixManager webGlViewProjectionMatrixManager;
  TagManager tagManager;
  CameraManager cameraManager;
  _$ParticleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.empty()..allOf([Position, Particle, Color]));
  @override
  void initialize() {
    super.initialize();
    positionMapper = Mapper<Position>(world);
    particleMapper = Mapper<Particle>(world);
    colorMapper = Mapper<Color>(world);
    webGlViewProjectionMatrixManager =
        world.getManager<WebGlViewProjectionMatrixManager>();
    tagManager = world.getManager<TagManager>();
    cameraManager = world.getManager<CameraManager>();
  }
}

abstract class _$WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Orientation> orientationMapper;
  Mapper<Renderable> renderableMapper;
  Mapper<Position> positionMapper;
  TagManager tagManager;
  WebGlViewProjectionMatrixManager webGlViewProjectionMatrixManager;
  _$WebGlSpriteRenderingSystem(RenderingContext gl, Aspect aspect)
      : super(gl, aspect..allOf([Orientation, Renderable]));
  @override
  void initialize() {
    super.initialize();
    orientationMapper = Mapper<Orientation>(world);
    renderableMapper = Mapper<Renderable>(world);
    positionMapper = Mapper<Position>(world);
    tagManager = world.getManager<TagManager>();
    webGlViewProjectionMatrixManager =
        world.getManager<WebGlViewProjectionMatrixManager>();
  }
}
