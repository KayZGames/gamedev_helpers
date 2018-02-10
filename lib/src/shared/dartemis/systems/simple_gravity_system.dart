part of gamedev_helpers_shared;

class SimpleGravitySystem extends EntityProcessingSystem {
  Mapper<Acceleration> accelerationMapper;
  SimpleGravitySystem() : super(new Aspect.forAllOf([Acceleration, Mass]));

  @override
  void processEntity(Entity entity) {
    accelerationMapper[entity].y += 9.81 * world.delta;
  }
}
