// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedev_helpers_shared;

// **************************************************************************
// Generator: SystemGenerator
// **************************************************************************

abstract class _$ResetAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  _$ResetAccelerationSystem()
      : super(new Aspect.empty()..allOf([Acceleration]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = new Mapper<Acceleration>(Acceleration, world);
  }
}

abstract class _$SimpleAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  Mapper<Velocity> velocityMapper;
  _$SimpleAccelerationSystem()
      : super(new Aspect.empty()..allOf([Acceleration, Velocity]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = new Mapper<Acceleration>(Acceleration, world);
    velocityMapper = new Mapper<Velocity>(Velocity, world);
  }
}

abstract class _$SimpleGravitySystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  Mapper<Mass> massMapper;
  _$SimpleGravitySystem()
      : super(new Aspect.empty()..allOf([Acceleration, Mass]));
  @override
  void initialize() {
    super.initialize();
    accelerationMapper = new Mapper<Acceleration>(Acceleration, world);
    massMapper = new Mapper<Mass>(Mass, world);
  }
}

abstract class _$SimpleMovementSystem extends EntityProcessingSystem {
  Mapper<Velocity> velocityMapper;
  Mapper<Position> positionMapper;
  _$SimpleMovementSystem()
      : super(new Aspect.empty()..allOf([Velocity, Position]));
  @override
  void initialize() {
    super.initialize();
    velocityMapper = new Mapper<Velocity>(Velocity, world);
    positionMapper = new Mapper<Position>(Position, world);
  }
}

abstract class _$AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> renderableMapper;
  _$AnimationSystem() : super(new Aspect.empty()..allOf([Renderable]));
  @override
  void initialize() {
    super.initialize();
    renderableMapper = new Mapper<Renderable>(Renderable, world);
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
    positionMapper = new Mapper<Position>(Position, world);
    orientationMapper = new Mapper<Orientation>(Orientation, world);
    cameraManager = world.getManager(CameraManager);
    tagManager = world.getManager(TagManager);
  }
}
