part of gamedev_helpers_shared;

class ResetAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  ResetAccelerationSystem() : super(new Aspect.forAllOf([Acceleration]));

  @override
  void processEntity(Entity entity) {
    accelerationMapper[entity]
      ..x = 0.0
      ..y = 0.0;
  }
}

class SimpleAccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  Mapper<Velocity> velocityMapper;
  SimpleAccelerationSystem()
      : super(new Aspect.forAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    final acceleration = accelerationMapper[entity];
    velocityMapper[entity]
      ..x += acceleration.x * world.delta
      ..y += acceleration.y * world.delta;
  }
}
