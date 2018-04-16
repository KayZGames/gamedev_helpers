// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedev_helpers;

// **************************************************************************
// Generator: SystemGenerator
// **************************************************************************

abstract class _$ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> positionMapper;
  Mapper<Particle> particleMapper;
  Mapper<Color> colorMapper;
  WebGlViewProjectionMatrixManager webGlViewProjectionMatrixManager;
  TagManager tagManager;
  _$ParticleRenderingSystem(RenderingContext2 gl)
      : super(gl, new Aspect.empty()..allOf([Position, Particle, Color]));
  @override
  void initialize() {
    super.initialize();
    positionMapper = new Mapper<Position>(Position, world);
    particleMapper = new Mapper<Particle>(Particle, world);
    colorMapper = new Mapper<Color>(Color, world);
    webGlViewProjectionMatrixManager =
        world.getManager(WebGlViewProjectionMatrixManager);
    tagManager = world.getManager(TagManager);
  }
}

abstract class _$WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Orientation> orientationMapper;
  Mapper<Renderable> renderableMapper;
  Mapper<Position> positionMapper;
  TagManager tagManager;
  WebGlViewProjectionMatrixManager webGlViewProjectionMatrixManager;
  _$WebGlSpriteRenderingSystem(RenderingContext2 gl, Aspect aspect)
      : super(gl, aspect..allOf([Orientation, Renderable]));
  @override
  void initialize() {
    super.initialize();
    orientationMapper = new Mapper<Orientation>(Orientation, world);
    renderableMapper = new Mapper<Renderable>(Renderable, world);
    positionMapper = new Mapper<Position>(Position, world);
    tagManager = world.getManager(TagManager);
    webGlViewProjectionMatrixManager =
        world.getManager(WebGlViewProjectionMatrixManager);
  }
}
