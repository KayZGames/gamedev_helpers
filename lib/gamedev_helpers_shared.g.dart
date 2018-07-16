// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedev_helpers_shared;

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$ResetAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  _$ResetAccelerationSystem() : super(Aspect.empty()..allOf([Acceleration]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = Mapper<Acceleration>(world);
  }
}

abstract class _$SimpleAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  Mapper<Velocity> velocityMapper;
  _$SimpleAccelerationSystem()
      : super(Aspect.empty()..allOf([Acceleration, Velocity]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = Mapper<Acceleration>(world);
    velocityMapper = Mapper<Velocity>(world);
  }
}

abstract class _$SimpleGravitySystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  Mapper<Mass> massMapper;
  _$SimpleGravitySystem() : super(Aspect.empty()..allOf([Acceleration, Mass]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = Mapper<Acceleration>(world);
    massMapper = Mapper<Mass>(world);
  }
}

abstract class _$SimpleMovementSystem extends EntityProcessingSystem {
  Mapper<Velocity> velocityMapper;
  Mapper<Position> positionMapper;
  _$SimpleMovementSystem() : super(Aspect.empty()..allOf([Velocity, Position]));
  @override
  void initialize() {
    super.initialize();
    velocityMapper = Mapper<Velocity>(world);
    positionMapper = Mapper<Position>(world);
  }
}

abstract class _$AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> renderableMapper;
  _$AnimationSystem() : super(Aspect.empty()..allOf([Renderable]));
  @override
  void initialize() {
    super.initialize();
    renderableMapper = Mapper<Renderable>(world);
  }
}

abstract class _$WebGlViewProjectionMatrixManager extends Manager {
  Mapper<Position> positionMapper;
  Mapper<Orientation> orientationMapper;
  CameraManager cameraManager;
  TagManager tagManager;
  @override
  void initialize() {
    super.initialize();
    positionMapper = Mapper<Position>(world);
    orientationMapper = Mapper<Orientation>(world);
    cameraManager = world.getManager<CameraManager>();
    tagManager = world.getManager<TagManager>();
  }
}
