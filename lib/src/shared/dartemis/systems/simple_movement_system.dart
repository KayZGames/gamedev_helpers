part of gamedev_helpers_shared;

@Generate(EntityProcessingSystem, allOf: [Velocity, Position])
class SimpleMovementSystem extends _$SimpleMovementSystem {
  @override
  void processEntity(Entity entity) {
    final velocity = velocityMapper[entity];
    positionMapper[entity]
      ..x += velocity.x * world.delta
      ..y += velocity.y * world.delta;
  }
}
