// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedev_helpers;

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> renderableMapper;
  _$AnimationSystem() : super(Aspect.empty()..allOf([Renderable]));
  @override
  void initialize() {
    super.initialize();
    renderableMapper = Mapper<Renderable>(world);
  }
}

abstract class _$ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> positionMapper;
  Mapper<Particle> particleMapper;
  Mapper<Color> colorMapper;
  ViewProjectionMatrixManager viewProjectionMatrixManager;
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
    viewProjectionMatrixManager =
        world.getManager<ViewProjectionMatrixManager>();
    tagManager = world.getManager<TagManager>();
    cameraManager = world.getManager<CameraManager>();
  }
}

abstract class _$WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Orientation> orientationMapper;
  Mapper<Renderable> renderableMapper;
  Mapper<Position> positionMapper;
  Mapper<Camera> cameraMapper;
  TagManager tagManager;
  ViewProjectionMatrixManager viewProjectionMatrixManager;
  _$WebGlSpriteRenderingSystem(RenderingContext gl, Aspect aspect)
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
