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

abstract class _$ViewProjectionMatrixManager extends Manager {
  Mapper<Position> positionMapper;
  Mapper<Camera> cameraMapper;
  CameraManager cameraManager;
  @override
  void initialize() {
    super.initialize();
    positionMapper = Mapper<Position>(world);
    cameraMapper = Mapper<Camera>(world);
    cameraManager = world.getManager<CameraManager>();
  }
}
