part of gamedev_helpers_shared;

class SimpleMovementSystem extends EntityProcessingSystem {
  Mapper<Velocity> velocityMapper;
  Mapper<Position> positionMapper;
  SimpleMovementSystem() : super(new Aspect.forAllOf([Velocity, Position]));

  @override
  void processEntity(Entity entity) {
    final velocity = velocityMapper[entity];
    positionMapper[entity]
      ..x += velocity.x * world.delta
      ..y += velocity.y * world.delta;
  }
}
