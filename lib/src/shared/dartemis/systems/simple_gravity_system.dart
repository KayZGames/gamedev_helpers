part of gamedev_helpers_shared;

@Generate(EntityProcessingSystem, allOf: [Acceleration, Mass])
class SimpleGravitySystem extends _$SimpleGravitySystem {
  @override
  void processEntity(Entity entity) {
    accelerationMapper[entity].y += 9.81 * world.delta;
  }
}
